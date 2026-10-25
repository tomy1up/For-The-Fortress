function Get-FortressSourceSnapshot {
    param([string]$ProjectRoot, [string[]]$RelativePaths)
    $sourceRoot = [IO.Path]::GetFullPath($ProjectRoot).TrimEnd('\','/') + [IO.Path]::DirectorySeparatorChar
    $snapshot = [ordered]@{}
    foreach ($relative in $RelativePaths) {
        $absolute = [IO.Path]::GetFullPath((Join-Path $sourceRoot $relative))
        if (-not $absolute.StartsWith($sourceRoot, [StringComparison]::OrdinalIgnoreCase)) {
            throw "SOURCE_OUTSIDE: Source hors du projet : $relative"
        }
        $key = $relative.Replace('\','/')
        if ($snapshot.Contains($key)) { throw "SOURCE_DUPLICATE: Source dupliquee : $relative" }
        if (-not (Test-Path -LiteralPath $absolute -PathType Leaf)) { throw "SOURCE_MISSING: Source absente : $relative" }
        $snapshot[$key] = (Get-FileHash -LiteralPath $absolute -Algorithm SHA256 -ErrorAction Stop).Hash.ToLowerInvariant()
    }
    return $snapshot
}

function Assert-FortressSourceSnapshot {
    param([System.Collections.IDictionary]$Expected, [System.Collections.IDictionary]$Actual)
    if ($Expected.Count -ne $Actual.Count) { throw 'SOURCE_CHANGED: La liste des sources a change pendant la compilation.' }
    foreach ($key in $Expected.Keys) {
        if (-not $Actual.Contains($key) -or $Actual[$key] -cne $Expected[$key]) {
            throw "SOURCE_CHANGED: Source modifiee pendant la compilation : $key. Relancer l'export dans un nouveau dossier."
        }
    }
}
