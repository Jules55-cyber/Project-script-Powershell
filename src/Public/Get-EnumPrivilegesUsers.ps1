function Get-EnumPrivilegesUsers {
    <#
    .DESCRIPTION
        Énumère l'identité de l'utilisateur courant : ses groupes d'appartenance
        et les privilèges de son token. Récupère la sortie de "whoami" au format CSV
        et la parse dans un objet structuré.
    .EXAMPLE
        Get-EnumPrivilegesUsers
    #>
    [cmdletbinding()]
    param ()

    # NOTE machine FR : "whoami /fo csv" renvoie des EN-TÊTES traduits
    # ("Nom de privilège", "État"...). Donc on SAUTE la ligne d'en-tête
    # (Select-Object -Skip 1) et on impose nos propres noms de colonnes
    # (-Header). Résultat : le parsing est indépendant de la langue de Windows.

    # --- Identité : nom + SID de l'utilisateur courant (2 colonnes) ---
    $user = whoami /user /fo csv |
        Select-Object -Skip 1 |
        ConvertFrom-Csv -Header 'UserName', 'SID'

    # --- Groupes d'appartenance (4 colonnes) ---
    $groupes = whoami /groups /fo csv |
        Select-Object -Skip 1 |
        ConvertFrom-Csv -Header 'Group', 'Type', 'SID', 'Attributes' |
        ForEach-Object {
            [PSCustomObject]@{
                Group = $_.Group
                Type  = $_.Type
                SID   = $_.SID
            }
        }

    # --- Privilèges du token (3 colonnes) ---
    $privileges = whoami /priv /fo csv |
        Select-Object -Skip 1 |
        ConvertFrom-Csv -Header 'Privilege', 'Description', 'State' |
        ForEach-Object {
            [PSCustomObject]@{
                Privilege = $_.Privilege
                State     = $_.State
            }
        }

    # --- IsAdmin : test réel de l'ÉLÉVATION du token (pas juste l'appartenance) ---
    # --- IsAdmin : on réutilise le helper Private du module ---
    $isAdmin = Test-IsAdmin

    # --- On construit l'objet final ---
    [PSCustomObject]@{
        Category   = 'User Privileges'
        UserName   = $user.UserName
        SID        = $user.SID
        IsAdmin    = $isAdmin
        Groups     = $groupes
        Privileges = $privileges
    }
}