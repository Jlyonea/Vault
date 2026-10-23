# Runs a potentially long command in a hidden detached process so the agent terminal never blocks.
# Output goes to a log file that can be read without the terminal. A watchdog kills the process tree on timeout or inactivity.
# Usage: & <vault>\run-safe.ps1 -Command '<command>' [-TimeoutSec 180] [-IdleSec 60]
# Prints 'RUN-SAFE pid=<pid> log=<path>' and returns immediately. The log ends with '[run-safe] END', 'KILLED' or 'EXITED'.
# Syntax errors in the command are reported at once as 'RUN-SAFE PARSE ERROR'.
param(
	[string]$Command,
	[int]$TimeoutSec = 180,
	[int]$IdleSec = 60,
	[int]$WatchPid = 0,
	[string]$LogPath
)
$ErrorActionPreference = 'Stop'

function Write-Log([string]$path, [string]$message) {
	Add-Content -LiteralPath $path -Value ('[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $message) -Encoding UTF8
}

function ConvertTo-EncodedCommand([string]$script) {
	[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))
}

if ($WatchPid -gt 0) {
	# Watchdog mode: started by the launcher below.
	$start = Get-Date
	while ($true) {
		Start-Sleep -Seconds 5
		$process = Get-Process -Id $WatchPid -ErrorAction SilentlyContinue
		if (-not $process -or $process.HasExited) {
			if (-not (Select-String -LiteralPath $LogPath -Pattern '\[run-safe\] (END|KILLED)' -Quiet)) {
				Write-Log $LogPath '[run-safe] EXITED without END marker (crash or killed externally)'
			}
			exit 0
		}
		$elapsed = ((Get-Date) - $start).TotalSeconds
		$idle = ((Get-Date) - (Get-Item -LiteralPath $LogPath).LastWriteTime).TotalSeconds
		$reason = if ($elapsed -gt $TimeoutSec) { "timeout of $TimeoutSec s" } elseif ($idle -gt $IdleSec) { "no output for $IdleSec s" }
		if ($reason) {
			& taskkill.exe /PID $WatchPid /T /F 2>&1 | Out-Null
			Write-Log $LogPath "[run-safe] KILLED: $reason"
			exit 0
		}
	}
}

if (-not $Command) { throw "Missing -Command. Usage: run-safe.ps1 -Command '<command>' [-TimeoutSec 180] [-IdleSec 60]" }

if (-not $LogPath) {
	$logDir = Join-Path $env:TEMP 'vault-run'
	[IO.Directory]::CreateDirectory($logDir) | Out-Null
	$LogPath = Join-Path $logDir ('run-{0}.log' -f (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
}
Write-Log $LogPath "[run-safe] START timeout=$TimeoutSec s idle=$IdleSec s: $Command"

$childScript = @'
$ErrorActionPreference = 'Continue'
$log = '__LOG__'
function Write-Line([string]$message) { Add-Content -LiteralPath $log -Value ('[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $message) -Encoding UTF8 }
try {
	& {
__COMMAND__
	} *>&1 | ForEach-Object { Write-Line "$_" }
} catch {
	Write-Line "[run-safe] ERROR: $($_.Exception.Message)"
}
Write-Line "[run-safe] END lastExitCode=$LASTEXITCODE"
'@
$childScript = $childScript.Replace('__LOG__', ($LogPath -replace "'", "''")).Replace('__COMMAND__', $Command)

$parseErrors = $null
[void][System.Management.Automation.Language.Parser]::ParseInput($childScript, [ref]$null, [ref]$parseErrors)
if ($parseErrors) {
	$details = ($parseErrors | ForEach-Object { $_.Message }) -join ' | '
	Write-Log $LogPath "[run-safe] PARSE ERROR: $details"
	"RUN-SAFE PARSE ERROR: $details (log=$LogPath)"
	exit 1
}

$child = Start-Process powershell.exe -WindowStyle Hidden -PassThru -WorkingDirectory (Get-Location).Path `
	-ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', (ConvertTo-EncodedCommand $childScript)

$watchArgs = '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-WatchPid', $child.Id, '-LogPath', "`"$LogPath`"", '-TimeoutSec', $TimeoutSec, '-IdleSec', $IdleSec
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList $watchArgs | Out-Null

"RUN-SAFE pid=$($child.Id) log=$LogPath"
