function Get-EnumInstalledSoftware {
<#
.SYNOPSIS
    Énumère les logiciels installés sur la machine Windows.
.DESCRIPTION
    Lit les clés "Uninstall" du registre (64 bits et 32 bits) pour lister
    les logiciels installés (nom, version, éditeur, date), et retourne un
    objet standardisé par logiciel.
.EXAMPLE
    Get-EnumInstalledSoftware
#>
    [CmdletBinding()]
    param()

    # Les deux emplacements du registre : 64 bits ET 32 bits (WOW6432Node)
    $chemins = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    Get-ItemProperty -Path $chemins -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |          # on ignore les entrées sans nom
        ForEach-Object {
            [PSCustomObject]@{
                Category    = 'Installed Software'
                Name        = $_.DisplayName
                Version     = $_.DisplayVersion
                Publisher   = $_.Publisher
                InstallDate = $_.InstallDate
            }
        }
}