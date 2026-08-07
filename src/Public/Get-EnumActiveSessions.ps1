function Get-EnumActiveSessions {
    <#
    .DESCRIPTION
        Énumère les sessions utilisateurs (actives / déconnectées) sur la machine locale.
        Récupère la sortie de "quser" (texte brut) et la parse pour en extraire
        chaque session dans un objet structuré.
    .EXAMPLE
        Get-EnumActiveSessions
    #>
    [cmdletbinding()]
    param ()

    # Récupération de la sortie de "quser" (texte brut)
    # 2>$null : on masque l'erreur si aucune session n'est ouverte
    $raw = quser 2>$null

    # Si quser ne renvoie rien, on s'arrête proprement
    if (-not $raw) {
        Write-Warning "Aucune session active trouvée."
        return
    }

    # --- On parse chaque ligne (on saute la 1ère = en-tête) ---
    $raw | Select-Object -Skip 1 | ForEach-Object {

        # Le '>' marque la session courante : on le retire.
        # Puis on découpe sur 2 espaces ou plus (les colonnes sont alignées).
        $champs = ($_ -replace '^\s*>', '').Trim() -split '\s{2,}'

        # 6 champs = session avec un SESSIONNAME (console, rdp-tcp#0...)
        # 5 champs = session déconnectée (la colonne SESSIONNAME est vide)
        if ($champs.Count -eq 6) {
            $user = $champs[0]; $session = $champs[1]; $id = $champs[2]
            $etat = $champs[3]; $idle    = $champs[4]; $logon = $champs[5]
        }
        else {
            $user = $champs[0]; $session = $null;      $id = $champs[1]
            $etat = $champs[2]; $idle    = $champs[3]; $logon = $champs[4]
        }

        # --- On construit l'objet final pour cette session ---
        [PSCustomObject]@{
            Category    = 'Active Sessions'
            UserName    = $user
            SessionName = $session
            Id          = $id
            State       = $etat
            IdleTime    = $idle
            LogonTime   = $logon
        }
    }
}