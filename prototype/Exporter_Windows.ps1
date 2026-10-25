param(
    [string]$EnginePath = '',
    [ValidatePattern('^\d+\.\d+(\.\d+)?$')][string]$Version = '0.49',
    [string]$OutputRoot = ''
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'build\SourceSnapshot.ps1')
$projectText = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'project.godot'))
if ($projectText -notmatch 'config/version="([^"]+)"' -or $Matches[1] -ne $Version) {
    throw 'La version demandee doit correspondre a application/config/version dans project.godot.'
}
if (-not $EnginePath) {
    $EnginePath = Join-Path $PSScriptRoot '..\..\.tools\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
}
if (-not (Test-Path -LiteralPath $EnginePath -PathType Leaf)) {
    throw 'Moteur absent : fournir -EnginePath avec Godot 4.7.2 standard.'
}
if (-not $OutputRoot) { $OutputRoot = Join-Path $PSScriptRoot '..\dist' }
$OutputRoot = [IO.Path]::GetFullPath($OutputRoot)
$artifactName = "For_the_Fortress_v${Version}_Windows_x64"
$artifactFolder = Join-Path $OutputRoot $artifactName
$archivePath = Join-Path $OutputRoot "$artifactName.zip"
if (Test-Path -LiteralPath $archivePath) {
    throw "Archive deja presente : $archivePath. Choisir une autre version ou un autre OutputRoot."
}
$engineVersion = (& $EnginePath --version | Out-String).Trim()
if ($engineVersion -ne '4.7.2.stable.official.ed1daf0bf') {
    throw "Moteur inattendu : $engineVersion. Utiliser la version documentee."
}
$licenseLog = (& $EnginePath --headless --path $PSScriptRoot --script res://tests/export_licenses.gd | Out-String)
if ($LASTEXITCODE -ne 0 -or $licenseLog -notmatch 'LICENSES_GENERATED=') {
    throw 'Generation des notices de licences incorrecte.'
}
$templates = Join-Path $env:APPDATA 'Godot\export_templates\4.7.2.stable'
foreach ($template in @('windows_release_x86_64.exe','windows_debug_x86_64.exe')) {
    if (-not (Test-Path -LiteralPath (Join-Path $templates $template))) {
        throw 'Templates 4.7.2 standard absents. Les installer avec le gestionnaire de templates Godot.'
    }
}
New-Item -ItemType Directory -Force -Path $artifactFolder | Out-Null
$executable = Join-Path $artifactFolder 'For_the_Fortress.exe'
$stdoutPath = Join-Path $OutputRoot "export_v${Version}.log"
$stderrPath = Join-Path $OutputRoot "export_v${Version}.err"
$arguments = @('--headless','--path',('"'+$PSScriptRoot+'"'),'--export-release','"Windows x86_64"',('"'+$executable+'"'))
$sourcePaths = @('project.godot','export_presets.cfg','scenes\main.tscn','scripts\main.gd','scripts\valley_model.gd','scripts\valley_view.gd','scripts\campaign_data.gd','scripts\progression_data.gd','scripts\run_report.gd','scripts\combat_metrics.gd')
$sources = Get-FortressSourceSnapshot -ProjectRoot $PSScriptRoot -RelativePaths $sourcePaths
if ([IO.File]::ReadAllText((Join-Path $PSScriptRoot 'project.godot')) -notmatch 'config/version="([^"]+)"' -or $Matches[1] -ne $Version) {
    throw 'La version du projet a change avant le lancement de la compilation.'
}
$process = Start-Process -FilePath $EnginePath -ArgumentList $arguments -WindowStyle Hidden -PassThru -Wait -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
$log = [IO.File]::ReadAllText($stdoutPath) + [IO.File]::ReadAllText($stderrPath)
if ($process.ExitCode -ne 0 -or $log -match 'ERROR:|SCRIPT ERROR') {
    throw "Export incorrect. Consulter $stdoutPath et $stderrPath."
}
if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) { throw 'Executable non produit.' }
Assert-FortressSourceSnapshot -Expected $sources -Actual (Get-FortressSourceSnapshot -ProjectRoot $PSScriptRoot -RelativePaths $sourcePaths)
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'distribution\LIRE_MOI.txt') -Destination $artifactFolder
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'distribution\LICENCES_GODOT.txt') -Destination $artifactFolder
Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\design\Fiche_essai_joueur.md') -Destination $artifactFolder
$manifest = [ordered]@{
    version = $Version
    date = '2026-10-26'
    platform = 'Windows x86_64'
    engine = $engineVersion
    executable = 'For_the_Fortress.exe'
    executable_sha256 = (Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash.ToLowerInvariant()
    embedded_data = $true
    signed = $false
    source_sha256 = $sources
}
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $artifactFolder 'VERSION.json') -Encoding UTF8
Assert-FortressSourceSnapshot -Expected $sources -Actual (Get-FortressSourceSnapshot -ProjectRoot $PSScriptRoot -RelativePaths $sourcePaths)
Compress-Archive -LiteralPath $artifactFolder -DestinationPath $archivePath -CompressionLevel Optimal
$archiveHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
"$archiveHash  $artifactName.zip" | Set-Content -LiteralPath (Join-Path $OutputRoot "$artifactName.sha256") -Encoding ASCII
Write-Output "EXPORT_READY=$artifactFolder"
Write-Output "ARCHIVE_READY=$archivePath"
Write-Output "ARCHIVE_SHA256=$archiveHash"
