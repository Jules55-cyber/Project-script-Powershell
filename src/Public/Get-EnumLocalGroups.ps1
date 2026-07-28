function Get-EnumLocalGroups {
<#
.SYNOPSIS
    Énumère les groupes locaux de la machine Windows.
.DESCRIPTION
    Récupère tous les groupes locaux (nom, description, SID) via la
    cmdlet native Get-LocalGroup, et retourne un objet standardisé
    par groupe pour l'intégration au rapport d'énumération.
.EXAMPLE
    Get-EnumLocalGroups
#>
    [cmdletbinding()]
    param ()
    # On "pipe" (|) le résultat vers ForEach-Object pour traiter chaque groupe un parn un.
    GET-LocalGroup | ForEach-Object {
        [PSCustomObject]@{
            Category = 'Local Groups'
            GroupName = $_.Name
            Description = $_.Description
            SID = $_.SID
        }
    }
return $localGroups
}    