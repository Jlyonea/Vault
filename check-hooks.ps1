# Checks that the vault git guardrails are working.
# Prints exactly 'VAULT HOOKS: OK' (exit 0) or 'VAULT HOOKS: FALHA - <motivos>' (exit 1).
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File <vault>\check-hooks.ps1 [-RepoPath <repositorio aberto>]
param([string]$RepoPath = (Get-Location).Path)
$ErrorActionPreference = 'Continue'
$problems = [System.Collections.Generic.List[string]]::new()

function Format-HooksPath([string]$path) { ($path -replace '\\', '/').TrimEnd('/') }

try {
	$copilotDir = Join-Path $env:USERPROFILE '.copilot'
	$hooksDir = Join-Path $copilotDir 'vault\git-hooks'
	$expectedHooksPath = Format-HooksPath $hooksDir

	$links = [ordered]@{
		(Join-Path $copilotDir 'vault')        = $PSScriptRoot
		(Join-Path $copilotDir 'skills\vault') = Join-Path $PSScriptRoot 'skills\vault'
		(Join-Path $copilotDir 'hooks')        = Join-Path $PSScriptRoot '.github\hooks'
	}
	foreach ($link in $links.Keys) {
		$item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
		if (-not $item -or $item.LinkType -ne 'Junction' -or ($item.Target | Select-Object -First 1) -ne $links[$link]) {
			$problems.Add("junction ausente ou incorreta: $link -> $($links[$link])")
		}
	}

	foreach ($file in '_common.sh', 'protected-branches.txt', 'pre-commit', 'pre-merge-commit', 'pre-push') {
		$hookFile = Join-Path $hooksDir $file
		if (-not (Test-Path -LiteralPath $hookFile)) { $problems.Add("arquivo de hook ausente: $hookFile") }
	}

	# Git used by the terminal (PATH) and by every Visual Studio installation.
	$gits = @()
	$pathGit = Get-Command git.exe -ErrorAction SilentlyContinue | Select-Object -First 1
	if ($pathGit) { $gits += $pathGit.Source }
	$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
	if (Test-Path -LiteralPath $vswhere) {
		foreach ($vs in & $vswhere -products '*' -property installationPath) {
			$vsGit = Join-Path $vs 'Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer\Git\cmd\git.exe'
			if (Test-Path -LiteralPath $vsGit) { $gits += $vsGit }
		}
	}
	$gits = @($gits | Select-Object -Unique)

	if ($gits.Count -eq 0) {
		$problems.Add('git nao encontrado (PATH ou Visual Studio)')
	} else {
		$firstGit = $gits[0]
		$globalHooksPath = Format-HooksPath (& $firstGit config --global --get core.hooksPath)
		if ($globalHooksPath -ne $expectedHooksPath) { $problems.Add("core.hooksPath global = '$globalHooksPath' (esperado '$expectedHooksPath')") }

		if (Test-Path -LiteralPath $RepoPath) {
			$repoHooksPath = Format-HooksPath (& $firstGit -C $RepoPath config --get core.hooksPath 2>$null)
			if ($LASTEXITCODE -gt 1) { $problems.Add("nao foi possivel ler a configuracao git de '$RepoPath'") }
			elseif ($repoHooksPath -ne $globalHooksPath) { $problems.Add("core.hooksPath em '$RepoPath' = '$repoHooksPath' (sobrescreve o global)") }
		}

		# Functional test: a commit on main in a scratch repository must be blocked by the vault hook.
		$testRepo = Join-Path $env:TEMP 'vault-hooks-check'
		$mutex = [System.Threading.Mutex]::new($false, 'Local\VaultHooksCheck')
		try { $owned = $mutex.WaitOne(60000) } catch [System.Threading.AbandonedMutexException] { $owned = $true }
		try {
			foreach ($git in $gits) {
				& $git init -q $testRepo 2>&1 | Out-Null
				& $git -C $testRepo symbolic-ref HEAD refs/heads/main 2>&1 | Out-Null
				Remove-Item -LiteralPath (Join-Path $testRepo '.git\index.lock') -ErrorAction SilentlyContinue
				$output = (& $git -C $testRepo -c user.name=vault -c user.email=vault@localhost commit -q --allow-empty -m 'vault hooks check' 2>&1 | ForEach-Object { "$_" }) -join ' '
				if ($LASTEXITCODE -eq 0) { $problems.Add("commit em main NAO foi bloqueado ($git)") }
				elseif ($output -notmatch '\[vault guardrail\] BLOCKED') { $problems.Add("hook nao bloqueou o commit em main ($git): $output") }
			}
		} finally {
			if ($owned) { $mutex.ReleaseMutex() }
			$mutex.Dispose()
		}
	}
} catch {
	$problems.Add("erro na verificacao: $($_.Exception.Message)")
}

if ($problems.Count -gt 0) {
	"VAULT HOOKS: FALHA - $($problems -join '; ')"
	exit 1
}
'VAULT HOOKS: OK'
exit 0
