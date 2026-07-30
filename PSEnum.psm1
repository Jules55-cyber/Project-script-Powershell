# On récupère la liste de tous les fichiers .ps1 des deux dossiers
$Public  = @( Get-ChildItem -Path "$PSScriptRoot\src\Public\*.ps1"  -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\src\Private\*.ps1" -ErrorAction SilentlyContinue )

# On charge (dot-source) chaque fichier dans la session du module
foreach ($file in @($Public + $Private)) {
    try {
        . $file.FullName
    }
    catch {
        Write-Error "Échec du chargement de $($file.FullName) : $_"
    }
}

# On exporte UNIQUEMENT les fonctions publiques (les Private restent internes)
Export-ModuleMember -Function $Public.BaseName