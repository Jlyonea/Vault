# PostToolUse: anexa o payload recebido em audit.log (ignorado no git).
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()
$log = Join-Path $PSScriptRoot 'audit.log'
$line = "{0}`t{1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), ($raw -replace '\r?\n', ' ')
Add-Content -Path $log -Value $line -Encoding UTF8
exit 0
