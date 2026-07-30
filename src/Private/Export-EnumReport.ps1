function Export-EnumReport {
    param(
        [object[]]$Data,
        [ValidateSet('JSON','CSV','HTML')]
        [string]$Format = 'JSON',
        [string]$OutputPath = '.\output'
    )

     if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }

    $horodatage = Get-Date -Format 'yyyyMMdd_HHmmss'
    $fichier = Join-Path $OutputPath "rapport_$horodatage"

    switch ($Format) {
        'JSON' { $Data | ConvertTo-Json -Depth 5 | Out-File "$fichier.json" }
        'CSV'  { $Data | Export-Csv "$fichier.csv" -NoTypeInformation }
        'HTML' { $Data | ConvertTo-Html | Out-File "$fichier.html" }
    }
}