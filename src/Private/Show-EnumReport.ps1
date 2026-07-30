function Show-EnumReport {
<#
.SYNOPSIS
    Affiche les résultats d'énumération groupés par catégorie, avec des en-têtes.
.EXAMPLE
    Show-EnumReport -Data $resultats
#>
    [CmdletBinding()]
    param(
        [object[]]$Data
    )

    # En-tete general du rapport
    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "        RAPPORT D'ENUMERATION - PSEnum" -ForegroundColor Cyan
    Write-Host "  $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')  -  Machine : $env:COMPUTERNAME" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan

    # On regroupe les resultats par categorie
    $groupes = $Data | Group-Object Category

    foreach ($groupe in $groupes) {
        # En-tete de section
        Write-Host ""
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "  [ $($groupe.Name.ToUpper()) ]  ($($groupe.Count) element(s))" -ForegroundColor Yellow
        Write-Host "--------------------------------------------------" -ForegroundColor DarkGray

        # Le contenu de la section, en tableau
        $groupe.Group | Format-Table -AutoSize
    }
}