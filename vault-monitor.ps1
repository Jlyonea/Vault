# Background monitor started at logon (HKCU Run 'VaultHooksMonitor', created by install.ps1).
# Runs check-hooks.ps1 whenever a new Visual Studio (devenv.exe) starts and shows a modal alert if the hooks are not working.
$mutex = [System.Threading.Mutex]::new($false, 'Local\VaultHooksMonitor')
try { $owned = $mutex.WaitOne(0) } catch [System.Threading.AbandonedMutexException] { $owned = $true }
if (-not $owned) { exit }

Add-Type -AssemblyName System.Windows.Forms
$check = Join-Path $PSScriptRoot 'check-hooks.ps1'

function Show-Alert([string]$message) {
	$owner = New-Object System.Windows.Forms.Form -Property @{ TopMost = $true }
	[void][System.Windows.Forms.MessageBox]::Show($owner, $message, 'Vault - hooks', 'OK', 'Error')
	$owner.Dispose()
}

$known = @()
try {
	while ($true) {
		$running = @(Get-Process devenv -ErrorAction SilentlyContinue | ForEach-Object Id)
		if ($running | Where-Object { $_ -notin $known }) {
			$result = if (Test-Path -LiteralPath $check) { (& $check | Out-String).Trim() } else { "VAULT HOOKS: FALHA - script nao encontrado: $check" }
			if ($result -ne 'VAULT HOOKS: OK') {
				Show-Alert "$result`n`nOs guardrails de master/main podem estar desativados. Nao faca commit, merge ou push ate resolver (rode install.ps1 do Vault)."
			}
		}
		$known = $running
		Start-Sleep -Seconds 3
	}
} catch {
	Show-Alert "VAULT HOOKS: o monitor parou ($($_.Exception.Message)). Nao havera aviso ao abrir o Visual Studio ate o proximo logon ou ate rodar install.ps1."
}
