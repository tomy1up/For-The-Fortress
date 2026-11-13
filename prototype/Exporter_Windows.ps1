param(
    [string]$EnginePath = '',
    [ValidatePattern('^\d+\.\d+(\.\d+)?$')][string]$Version = '0.189',
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
$sourcePaths = @('project.godot','export_presets.cfg','scenes\main.tscn','scripts\main.gd','scripts\valley_model.gd','scripts\valley_view.gd','scripts\campaign_data.gd','scripts\progression_data.gd','scripts\run_report.gd','scripts\combat_metrics.gd','scripts\horde_art.gd','assets\units\horde\troll_v001.png','assets\units\horde\gobelin_v001.png','assets\units\horde\chaman_v001.png','assets\units\horde\troll_v001.png.import','assets\units\horde\gobelin_v001.png.import','assets\units\horde\chaman_v001.png.import','scripts\alliance_art.gd','assets\units\alliance\archer_v001.png','assets\units\alliance\arbaletrier_v001.png','assets\units\alliance\mage_v001.png','assets\units\alliance\archer_v001.png.import','assets\units\alliance\arbaletrier_v001.png.import','assets\units\alliance\mage_v001.png.import','scripts\enemy_art.gd','assets\enemies\rosters\neutres_v001.png','assets\enemies\rosters\alliance_v002.png','assets\enemies\rosters\horde_v003.png','assets\enemies\rosters\neutres_v001.png.import','assets\enemies\rosters\alliance_v002.png.import','assets\enemies\rosters\horde_v003.png.import','scripts\enemy_catalogue.gd','scripts\meta_talents.gd','scripts\meta_profile.gd','scripts\meta_screen.gd','scripts\meta_talents_v067.gd','scripts\profile_codec.gd','scripts\map_definition.gd','scripts\mission_progress.gd','scripts\meta_talents_expanded.gd','scripts\meta_talents_v068.gd','scripts\talent_experience.gd','scripts\meta_talents_linked.gd','scripts\campaign_catalogue.gd','scripts\campaign_screen.gd','scripts\shop_catalogue.gd','scripts\shop_screen.gd','scripts\shop_art.gd','assets\units\shop\rodeur_v001.png','assets\units\shop\rodeur_v001.png.import','assets\units\shop\mousquetaire_v002.png','assets\units\shop\mousquetaire_v002.png.import','assets\units\shop\traqueur_v001.png','assets\units\shop\traqueur_v001.png.import','assets\units\shop\grenadier_v001.png','assets\units\shop\grenadier_v001.png.import')
$sourcePaths += @('scripts\bank_encounters.gd','assets\enemies\rosters\tortue_gardienne_v001.png','assets\enemies\rosters\tortue_gardienne_v001.png.import')
foreach ($pose in @('lacher','rearmement','encochage')) {
    $asset = "assets\units\alliance\archer_${pose}_v001.png"
    $sourcePaths += @($asset, "$asset.import")
}
$sourcePaths += @('assets\units\alliance\arbaletrier_rearmement_v001.png','assets\units\alliance\arbaletrier_rearmement_v001.png.import')
$sourcePaths += @('scripts\fortress_art.gd','assets\fortresses\forteresse_alliance_v001.png','assets\fortresses\forteresse_alliance_v001.png.import','assets\fortresses\forteresse_horde_v001.png','assets\fortresses\forteresse_horde_v001.png.import','assets\fortresses\roi_alliance_v001.png','assets\fortresses\roi_alliance_v001.png.import','assets\fortresses\roi_horde_v001.png','assets\fortresses\roi_horde_v001.png.import')
$sourcePaths += @('scripts\enemy_walk_art.gd','assets\enemies\animations\loup_corps_v002.png','assets\enemies\animations\loup_corps_v002.png.import')
$sourcePaths += @('assets\enemies\animations\loup_marche_v002.bin','scripts\route_geometry.gd')
$sourcePaths += @('scripts\mission_scout.gd','distribution\Lancer_atelier_routes.cmd')
$sourcePaths += @('scripts\marsh_art.gd','scripts\drowned_encounters.gd','scripts\drowned_maps.gd','scripts\volcanic_maps.gd','scripts\citadel_maps.gd','scripts\garrison_encounters.gd','scripts\animation_library.gd','scripts\decor_art.gd','scripts\desert_maps.gd','scripts\mine_maps.gd','scripts\sky_maps.gd','scripts\eagle_encounters.gd','scripts\coast_maps.gd','scripts\necro_maps.gd')
$sourcePaths += @('assets\enemies\rosters\capitaine_humain_v001.png','assets\enemies\rosters\capitaine_humain_v001.png.import','assets\enemies\rosters\gueule_de_vase_v001.png','assets\enemies\rosters\gueule_de_vase_v001.png.import')
# Every declared runtime resource must be selected explicitly by this preset.
$presetText = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'export_presets.cfg'))
foreach ($resourcePath in $sourcePaths) {
    if ([IO.Path]::GetExtension($resourcePath) -in @('.gd','.tscn','.png')) {
        $selectedResource = '"res://' + $resourcePath.Replace('\','/') + '"'
        if (-not $presetText.Contains($selectedResource)) {
            throw "Ressource absente de la selection d'export : $resourcePath"
        }
    }
}
# Animations (Codex) et decors : PNG et JSON de assets\animations et assets\decor, inclus tels quels (include_filter).
foreach ($rawRoot in @('assets\animations','assets\decor')) {
    $rawFolder = Join-Path $PSScriptRoot $rawRoot
    if (Test-Path $rawFolder) {
        foreach ($rawFile in (Get-ChildItem -Path $rawFolder -Recurse -File | Where-Object { $_.Extension -in @('.png','.json') } | Sort-Object FullName)) {
            $sourcePaths += $rawFile.FullName.Substring($PSScriptRoot.Length + 1)
        }
    }
}
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
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'distribution\Lancer_atelier_routes.cmd') -Destination $artifactFolder
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'distribution\LICENCES_GODOT.txt') -Destination $artifactFolder
Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\design\Fiche_essai_joueur.md') -Destination $artifactFolder
$manifest = [ordered]@{
    version = $Version
    date = (Get-Date -Format 'yyyy-MM-dd')
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
