function Export-EnumReport {
    param(
        [object[]]$Data,
        [ValidateSet('JSON','CSV','HTML','PDF')]
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

        # HTML et PDF partagent la meme generation HTML.
        { $_ -in @('HTML','PDF') } {

            # --- Echappement HTML ---
            function Escape-Html($texte) {
                return ($texte -replace '&', '&amp;' -replace '<', '&lt;' -replace '>', '&gt;')
            }

            # --- Transforme une valeur en HTML lisible ---
            function Format-Valeur($valeur, $nomColonne) {
                if ($null -eq $valeur) { return '' }

                if ($valeur -is [array]) {
                    $nb = $valeur.Count
                    $lignes = $valeur | ForEach-Object {
                        $texte = ($_.PSObject.Properties | ForEach-Object { $_.Value }) -join ' | '
                        Escape-Html $texte
                    }
                    $contenu = $lignes -join '<br>'
                    return "<details><summary>$nomColonne ($nb)</summary>$contenu</details>"
                }

                return Escape-Html $valeur.ToString()
            }

            # --- CSS : theme sombre + onglets + regles impression ---
            $css = @'
<style>
    body {
        font-family: "Segoe UI", Tahoma, sans-serif;
        background-color: #1a1a1a;
        color: #e0e0e0;
        margin: 0;
        padding: 30px;
        -webkit-print-color-adjust: exact;
        print-color-adjust: exact;
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
        margin-bottom: 20px;
    }
    h2 {
        color: #d4af37;
        margin-top: 10px;
        font-size: 19px;
        border-left: 4px solid #d4af37;
        padding-left: 12px;
    }
    .tabs {
        position: sticky;
        top: 0;
        background-color: #1a1a1a;
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
        padding: 12px 0;
        border-bottom: 1px solid #333;
        margin-bottom: 20px;
        z-index: 10;
    }
    .tab-btn {
        background-color: #242424;
        color: #e0e0e0;
        border: 1px solid #3a3a3a;
        border-radius: 6px;
        padding: 8px 14px;
        cursor: pointer;
        font-size: 13px;
        font-family: inherit;
    }
    .tab-btn:hover {
        border-color: #d4af37;
        color: #d4af37;
    }
    .tab-btn.active {
        background-color: #d4af37;
        color: #1a1a1a;
        border-color: #d4af37;
        font-weight: 600;
    }
    .tab-btn .badge {
        display: inline-block;
        margin-left: 6px;
        background-color: rgba(0,0,0,0.25);
        border-radius: 10px;
        padding: 1px 7px;
        font-size: 11px;
    }
    .tab-btn.active .badge {
        background-color: #1a1a1a;
        color: #d4af37;
    }
    .tab-panel { display: none; }
    .tab-panel.active { display: block; }
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
    tr:hover td { background-color: #2c2c2c; }
    details summary {
        cursor: pointer;
        color: #d4af37;
        font-weight: 600;
        padding: 2px 0;
    }
    details summary:hover { color: #e6c860; }
    details[open] summary { margin-bottom: 8px; }
    details > *:not(summary) {
        color: #c0c0c0;
        font-size: 12px;
        line-height: 1.7;
    }
    @media print {
        .tabs { display: none; }
        .tab-panel { display: block !important; page-break-before: always; }
        .tab-panel:first-of-type { page-break-before: avoid; }
        body { padding: 20px; }
    }
</style>
'@

            # --- JavaScript : navigation par onglets ---
            $scriptJs = @'
function showTab(id, btn) {
    document.querySelectorAll('.tab-panel').forEach(function (p) { p.classList.remove('active'); });
    document.getElementById(id).classList.add('active');
    document.querySelectorAll('.tab-btn').forEach(function (b) { b.classList.remove('active'); });
    btn.classList.add('active');
}
window.addEventListener('beforeprint', function () {
    document.querySelectorAll('details').forEach(function (d) { d.open = true; });
});
'@

            $groupes = $Data | Group-Object Category

            # --- Barre d'onglets ---
            $i = 0
            $onglets = ''
            foreach ($g in $groupes) {
                $actif = if ($i -eq 0) { ' active' } else { '' }
                $onglets += "<button class=""tab-btn$actif"" onclick=""showTab('cat-$i', this)"">$($g.Name)<span class=""badge"">$($g.Count)</span></button>"
                $i++
            }

            # --- Panneaux ---
            $i = 0
            $panneaux = ''
            foreach ($g in $groupes) {
                $actif = if ($i -eq 0) { ' active' } else { '' }
                $panneaux += "<section id=""cat-$i"" class=""tab-panel$actif"">"
                $panneaux += "<h2>$($g.Name)</h2><table>"

                $colonnes = $g.Group[0].PSObject.Properties.Name | Where-Object { $_ -ne 'Category' }
                $panneaux += "<tr>" + (($colonnes | ForEach-Object { "<th>$_</th>" }) -join '') + "</tr>"

                foreach ($item in $g.Group) {
                    $panneaux += "<tr>"
                    foreach ($col in $colonnes) {
                        $panneaux += "<td>$(Format-Valeur $item.$col $col)</td>"
                    }
                    $panneaux += "</tr>"
                }

                $panneaux += "</table></section>"
                $i++
            }

            # --- Assemblage ---
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
<nav class="tabs">$onglets</nav>
$panneaux
<script>
$scriptJs
</script>
</body>
</html>
"@

            $html | Out-File "$fichier.html" -Encoding UTF8

            # --- Conversion PDF via Edge/Chrome headless ---
            if ($Format -eq 'PDF') {
                $cheminHtml = (Resolve-Path "$fichier.html").Path
                $cheminPdf  = Join-Path (Split-Path $cheminHtml -Parent) ((Split-Path $cheminHtml -Leaf) -replace '\.html$', '.pdf')
                $uriHtml    = ([System.Uri]$cheminHtml).AbsoluteUri

                $candidats = @(
                    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
                    "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe",
                    "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
                    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
                )
                $navigateur = $candidats | Where-Object { Test-Path $_ } | Select-Object -First 1

                if (-not $navigateur) {
                    Write-Warning "Edge/Chrome introuvable : PDF non genere. HTML disponible : $cheminHtml"
                }
                else {
                    $profilTemp = Join-Path $env:TEMP "psenum_pdf_$horodatage"

                    Start-Process -FilePath $navigateur -ArgumentList @(
                        '--headless=new',
                        '--disable-gpu',
                        '--no-pdf-header-footer',
                        "--user-data-dir=$profilTemp",
                        "--print-to-pdf=$cheminPdf",
                        $uriHtml
                    ) -Wait -WindowStyle Hidden

                    # Attente active : jusqu'a 30 s, et on verifie que la taille
                    # se stabilise (fichier entierement ecrit, pas en cours d'ecriture)
                    $tailleAvant = -1
                    $essais = 0
                    while ($essais -lt 60) {
                        Start-Sleep -Milliseconds 500
                        if (Test-Path $cheminPdf) {
                            $tailleActuelle = (Get-Item $cheminPdf).Length
                            if ($tailleActuelle -gt 0 -and $tailleActuelle -eq $tailleAvant) { break }
                            $tailleAvant = $tailleActuelle
                        }
                        $essais++
                    }

                    Start-Sleep -Seconds 3                    
                    if (Test-Path $cheminPdf) {
                        $ko = [math]::Round((Get-Item $cheminPdf).Length / 1KB)
                        Write-Host "PDF genere : $cheminPdf ($ko Ko)" -ForegroundColor Green
                    }
                    else {
                        Write-Warning "Conversion PDF echouee. HTML disponible : $cheminHtml"
                    }
                }
                }
            }
        }
    }

