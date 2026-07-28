function Get-EnumServices {
<#
.SYNOPSIS
    Énumère les services Windows de la machine.
.DESCRIPTION
    Liste tous les services (nom, état, type de démarrage) via la cmdlet
    native Get-Service, et retourne un objet standardisé par service.
.EXAMPLE
    Get-EnumServices
#>
    [CmdletBinding()]
    param()

    Get-Service | ForEach-Object {
        [PSCustomObject]@{
            Category    = 'Services'
            Name        = $_.Name
            DisplayName = $_.DisplayName
            Status      = $_.Status
            StartType   = $_.StartType
        }
    }
}