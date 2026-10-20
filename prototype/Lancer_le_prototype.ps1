param([string]$EnginePath = '')
$ErrorActionPreference = 'Stop'
if (-not $EnginePath) {
    $EnginePath = Join-Path $PSScriptRoot '..\..\.tools\Godot-4.7.2\Godot_v4.7.2-stable_win64.exe'
}
if (-not (Test-Path -LiteralPath $EnginePath -PathType Leaf)) {
    throw 'Godot 4.7.2 est introuvable. Consultez le README du prototype ou fournissez -EnginePath avec le chemin du moteur.'
}
& $EnginePath --path $PSScriptRoot
