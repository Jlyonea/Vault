# PreToolUse: bloqueia comandos perigosos. Le o payload JSON do stdin.
$ErrorActionPreference = 'Stop'
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { exit 0 }

# Checa so o input da ferramenta, para evitar falso positivo em outros campos.
# Ajuste os nomes de campo conforme o audit.log (tool_input / toolInput / input).
$text = $raw
try {
	$payload = $raw | ConvertFrom-Json
	foreach ($field in 'tool_input', 'toolInput', 'input') {
		if ($payload.PSObject.Properties.Name -contains $field) {
			$text = $payload.$field | ConvertTo-Json -Depth 20 -Compress
			break
		}
	}
} catch { }

$rules = [ordered]@{
	'git\s+push'                 = 'git push requer pedido explicito do usuario'
	'rm\s+-(rf|fr)\b'            = 'rm -rf bloqueado'
	'Remove-Item\b.*-Recurse'    = 'Remove-Item -Recurse bloqueado'
	'drop\s+table'               = 'DROP TABLE bloqueado'
	'(^|[^\w])-{0,2}force\b'     = 'operacao com force bloqueada'
}

foreach ($pattern in $rules.Keys) {
	if ($text -imatch $pattern) {
		$result = @{
			hookSpecificOutput = @{
				hookEventName            = 'PreToolUse'
				permissionDecision       = 'deny'
				permissionDecisionReason = "Bloqueado pelo guard do vault: $($rules[$pattern]) (padrao: $pattern)"
			}
		}
		$result | ConvertTo-Json -Depth 5 -Compress
		exit 0
	}
}

exit 0
