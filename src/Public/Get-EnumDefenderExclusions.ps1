function Get-EnumDefenderExclusions {
<#
.SYNOPSIS
    Énumère les exclusions configurées dans Windows Defender.
.DESCRIPTION
    Liste les chemins, extensions et processus exclus de l'analyse antivirus
    via Get-MpPreference. Permet de repérer les angles morts de la protection
    où un fichier malveillant pourrait échapper à la détection.
.EXAMPLE
    Get-EnumDefenderExclusions
#>
    [CmdletBinding()]
    param()

    # Get-MpPreference lit la configuration de Windows Defender (lecture seule)
    $prefs = Get-MpPreference -ErrorAction SilentlyContinue

    [PSCustomObject]@{
        Category           = 'Defender Exclusions'
        ExcludedPaths      = ($prefs.ExclusionPath      -join ' | ')
        ExcludedExtensions = ($prefs.ExclusionExtension -join ' | ')
        ExcludedProcesses  = ($prefs.ExclusionProcess   -join ' | ')
    }
}