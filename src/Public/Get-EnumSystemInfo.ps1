function GET-EnumSystemInfo {
<#
.SYNOPSIS
    Collecte les informations système de la machine Windows.
.DESCRIPTION
    Récupère l'OS, sa version, le nom de la machine, l'utilisateur courant
    et l'appartenance au domaine via les classes CIM Win32.
.EXAMPLE
    Get-EnumSystemInfo
#>
    [CmdletBinding()]
    param ()

    # Récupération des informations système via les classes CIM Win32
    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem

    # Création d'un objet personnalisé pour stocker les informations
    $systemInfo = [PSCustomObject]@{
        Category        ='System Info'
        OSName          = $osInfo.Caption
        OSVersion       = $osInfo.Version
        ComputerName    = $computerSystem.Name
        CurrentUser    = $env:USERNAME
        IsDomainJoined  = $computerSystem.PartOfDomain
        Domain          = $computerSystem.Domain
    }

    # Retourne l'objet contenant les informations système
    return $systemInfo
}