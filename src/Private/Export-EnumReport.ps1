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
        'HTML' {

            # --- Fonction interne : transforme une valeur en texte lisible ---
            # Les champs imbriqués (Groups, Privileges) sont des tableaux d'objets.
            # Sans ça, ConvertTo-Html afficherait "System.Object[]".
            function Format-Valeur($valeur) {
                if ($null -eq $valeur) { return '' }

                # Si c'est une collection d'objets (ex : Groups, Privileges)
                if ($valeur -is [array]) {
                    $lignes = $valeur | ForEach-Object {
                        # On concatène les propriétés de chaque sous-objet
                        ($_.PSObject.Properties | ForEach-Object { $_.Value }) -join ' | '
                    }
                    return ($lignes -join "`n")
                }

                return $valeur.ToString()
            }

            # --- CSS : thème sombre + accent doré (identité de la présentation) ---
            $css = @'
<style>
    body {
        font-family: "Segoe UI", Tahoma, sans-serif;
        background-color: #1a1a1a;
        color: #e0e0e0;
        margin: 0;
        padding: 30px;
    }
    h1 {
        color: #d4af37;
        border-bottom: 2px solid #d4af37;
        padding-bottom: 10px;
        font-size: 26px;
    }
    .meta {
        color: #888;
        font-size: 13px;
        margin-bottom: 30px;
    }
    h2 {
        color: #d4af37;
        margin-top: 35px;
        font-size: 19px;
        border-left: 4px solid #d4af37;
        padding-left: 12px;
    }
    table {
        border-collapse: collapse;
        width: 100%;
        margin-top: 12px;
        background-color: #242424;
    }
    th {
        background-color: #333;
        color: #d4af37;
        text-align: left;
        padding: 10px 14px;
        font-size: 14px;
    }
    td {
        padding: 8px 14px;
        border-top: 1px solid #3a3a3a;
        font-size: 13px;
        white-space: pre-line;
        vertical-align: top;
    }
    tr:hover td {
        background-color: #2c2c2c;
    }
</style>
'@

            # --- En-tête du document ---
            $date = Get-Date -Format 'dd/MM/yyyy HH:mm:ss'
            $html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Rapport PSEnum</title>
$css
</head>
<body>
<h1>Rapport d'enumeration PSEnum</h1>
<div class="meta">Genere le $date &bull; Machine : $env:COMPUTERNAME</div>
"@

            # --- Une section <h2> + table par Category ---
            $Data | Group-Object Category | ForEach-Object {
                $html += "<h2>$($_.Name)</h2>"
                $html += "<table>"

                # En-têtes = toutes les propriétés sauf Category (deja dans le titre)
                $colonnes = $_.Group[0].PSObject.Properties.Name | Where-Object { $_ -ne 'Category' }
                $html += "<tr>" + (($colonnes | ForEach-Object { "<th>$_</th>" }) -join '') + "</tr>"

                # Lignes de données
                foreach ($item in $_.Group) {
                    $html += "<tr>"
                    foreach ($col in $colonnes) {
                        $valeur = Format-Valeur $item.$col
                        # On echappe les < > pour ne pas casser le HTML
                        $valeur = $valeur -replace '<', '&lt;' -replace '>', '&gt;'
                        $html += "<td>$valeur</td>"
                    }
                    $html += "</tr>"
                }

                $html += "</table>"
            }

            $html += "</body></html>"

            # --- Écriture (UTF8 pour les accents) ---
            $html | Out-File "$fichier.html" -Encoding UTF8
        }
    }
}