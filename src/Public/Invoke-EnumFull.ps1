function Invoke-EnumFull {
<#
.SYNOPSIS
    Orchestre l'énumération complète et exporte un rapport.
.DESCRIPTION
    Exécute toutes les fonctions Get-Enum* du module, regroupe les résultats,
    puis délègue l'export à Export-EnumReport. Utilise Write-EnumLog pour le
    suivi et Test-IsAdmin pour avertir si les privilèges sont insuffisants.
.EXAMPLE
    Invoke-EnumFull -Format JSON
#>
    [CmdletBinding()]
    param(
        [ValidateSet('JSON','CSV','HTML','PDF')]
        [string]$Format = 'JSON',

        [string]$OutputPath = '.\output'
    )
    # Force l'affichage UTF-8 dans la console (evite les accents casses)
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    Write-EnumLog "Démarrage de l'énumération complète" -Level INFO

    # Avertissement si la session n'est pas administrateur
    if (-not (Test-IsAdmin)) {
        Write-EnumLog "Session non administrateur : résultats possiblement incomplets." -Level WARN
    }

    # 1. On lance toutes les fonctions et on empile les résultats
    $resultats = @()
    $resultats += Get-EnumSystemInfo
    $resultats += Get-EnumLocalUsers
    $resultats += Get-EnumLocalGroups
    $resultats += Get-EnumNetworkConfig
    $resultats += Get-EnumInstalledSoftware
    $resultats += Get-EnumServices
    $resultats += Get-EnumAntivirus
    $resultats += Get-EnumPasswordPolicy
    $resultats += Get-EnumDefenderExclusions
    $resultats += Get-EnumActiveSessions
    $resultats += Get-EnumPrivilegesUsers   

    Write-EnumLog "Collecte terminée : $($resultats.Count) éléments." -Level INFO

    # 2. On délègue l'export au helper dédié
    Export-EnumReport -Data $resultats -Format $Format -OutputPath $OutputPath

    Write-EnumLog "Rapport exporté au format $Format." -Level INFO

    # Affichage formaté et lisible, groupé par section
    Show-EnumReport -Data $resultats

    # On renvoie quand même les objets (pour un usage éventuel : $x = Invoke-EnumFull)
    return $resultats
}