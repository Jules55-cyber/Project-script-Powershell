function Test-IsAdmin {
<#
.SYNOPSIS
    Vérifie si la session PowerShell courante est exécutée en administrateur.
.DESCRIPTION
    Retourne $true si l'utilisateur courant dispose des droits administrateur,
    $false sinon. Utilisé en interne par les fonctions d'énumération qui
    nécessitent une élévation de privilèges.
.EXAMPLE
    if (Test-IsAdmin) { "Je suis admin" } else { "Droits limités" }
#>
    [CmdletBinding()]
    param()

    # 1. On récupère l'identité de l'utilisateur Windows courant
    $identite = [Security.Principal.WindowsIdentity]::GetCurrent()

    # 2. On la transforme en "principal" (objet qui connaît les rôles/droits)
    $principal = [Security.Principal.WindowsPrincipal]::new($identite)

    # 3. On teste s'il possède le rôle Administrateur → renvoie $true ou $false
    $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}