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

            # --- Echappement HTML (pour ne pas casser le rendu avec < > &) ---
            function Escape-Html($texte) {
                return ($texte -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;')
            }

            # --- Transforme une valeur en HTML lisible ---
            # Les champs imbriques (Groups, Privileges) sont des tableaux d'objets.
            # On les met dans un bloc repliable <details> avec un compteur.
            function Format-Valeur($valeur, $nomColonne) {
                if ($null -eq $valeur) { return '' }

                if ($valeur -is [array]) {
                    $nb = $valeur.Count
                    $lignes = $valeur | ForEach-Object {
                        $texte = ($_.PSObject.Properties | ForEach-Object { $_.Value }) -join ' | '
                        Escape-Html $texte
                    }
                    $contenu = $lignes -join '<br>'
                    # <details>/<summary> = repliable natif HTML (aucun JavaScript)
                    return "<details><summary>$nomColonne ($nb)</summary>$contenu</details>"
                }

                return Escape-Html $valeur.ToString()
            }

            # --- CSS : theme sombre + accent dore ---
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
    details summary {
        cursor: pointer;
        color: #d4af37;
        font-weight: 600;
        padding: 2px 0;
    }
    details summary:hover {
        color: #e6c860;
    }
    details[open] summary {
        margin-bottom: 8px;
    }
    details > *:not(summary) {
        color: #c0c0c0;
        font-size: 12px;
        line-height: 1.7;
    }
</style>
'@

            # --- En-tete du document (date de generation retiree) ---
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
<div class="meta">Machine : $env:COMPUTERNAME</div>
"@

            # --- Une section <h2> + table par Category ---
            $Data | Group-Object Category | ForEach-Object {
                $html += "<h2>$($_.Name)</h2>"
                $html += "<table>"

                $colonnes = $_.Group[0].PSObject.Properties.Name | Where-Object { $_ -ne 'Category' }
                $html += "<tr>" + (($colonnes | ForEach-Object { "<th>$_</th>" }) -join '') + "</tr>"

                foreach ($item in $_.Group) {
                    $html += "<tr>"
                    foreach ($col in $colonnes) {
                        $html += "<td>$(Format-Valeur $item.$col $col)</td>"
                    }
                    $html += "</tr>"
                }

                $html += "</table>"
            }

            $html += "</body></html>"

            $html | Out-File "$fichier.html" -Encoding UTF8
        }
    }
}