function GET-EnumLocalUsers {
<#
.SYNOPSIS
    Énumère les comptes utilisateurs locaux de la machine Windows.
.DESCRIPTION
    Récupère tous les comptes locaux (nom, état, dernière connexion, etc.)
    via la cmdlet native Get-LocalUser, et retourne un objet standardisé
    par utilisateur pour l'intégration au rapport d'énumération.
.EXAMPLE
    Get-EnumLocalUsers
#>
    [cmdletbinding()]
    param ()
    # Get-LocalUser renvoie TOUS les comptes locaux de la machine.
    GET-LocalUser | ForEach-Object {
        # Pour chaque compte, on construit un objet propre et uniforme.
        [PSCustomObject]@{
            Category = 'Local Users'
            UserName = $_.Name
            FullName = $_.FullName
            Description = $_.Description
            Enabled = $_.Enabled
            LastLogon = $_.LastLogon
        }
    } 
 return $localUsers
}
