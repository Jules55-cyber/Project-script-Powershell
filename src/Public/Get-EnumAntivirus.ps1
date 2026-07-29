function Get-EnumAntivirus {
<#
.SYNOPSIS
    Énumère les antivirus enregistrés sur la machine Windows.
.DESCRIPTION
    Interroge le namespace CIM root/SecurityCenter2 (Windows Security Center)
    pour lister les produits antivirus détectés et leur état, et retourne un
    objet standardisé par antivirus.
.EXAMPLE
    Get-EnumAntivirus
#>
    [CmdletBinding()]
    param()

    Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct -ErrorAction SilentlyContinue |
        ForEach-Object {
            [PSCustomObject]@{
                Category    = 'Antivirus'
                Name        = $_.displayName
                State       = $_.productState
                ExePath     = $_.pathToSignedProductExe
                Timestamp   = $_.timestamp
            }
        }
}