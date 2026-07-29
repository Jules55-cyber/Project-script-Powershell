function Get-EnumNetworkConfig {
<#
.SYNOPSIS
    Énumère la configuration réseau de la machine Windows.
.DESCRIPTION
    Récupère par interface l'adresse IP, le masque (prefix), l'adresse MAC,
    la passerelle et les serveurs DNS via Get-NetIPConfiguration.
.EXAMPLE
    Get-EnumNetworkConfig
#>
    [CmdletBinding()]
    param()

    Get-NetIPConfiguration | ForEach-Object {
        [PSCustomObject]@{
            Category       = 'Network Config'
            InterfaceAlias = $_.InterfaceAlias
            IPv4Address    = $_.IPv4Address.IPAddress
            PrefixLength   = $_.IPv4Address.PrefixLength    # ← le masque (/24, /16...)
            MACAddress     = $_.NetAdapter.MacAddress
            Gateway        = $_.IPv4DefaultGateway.NextHop
            DNSServer      = ($_.DNSServer.ServerAddresses -join ', ')
        }
    }
}