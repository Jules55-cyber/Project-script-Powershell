function Get-EnumPasswordPolicy {
    <#
.SYNOPSIS
    Énumère la politique de mots de passe locale de la machine.
.DESCRIPTION
    Récupère la sortie de "net accounts" (texte brut) et la parse
    pour en extraire les valeurs clés dans un objet structuré.
.EXAMPLE
    Get-EnumPasswordPolicy
#>
    [cmdletbinding()]
    param ()
    # Récupération de la sortie de "net accounts" (texte brut)
    $raw= net accounts

    # --- Fonction interne de parsing ---
    # Elle prend un mot-clé, trouve la ligne correspondante,
    # et en extrait la valeur (ce qui est après les ":").
    function Get-Value($motcle){
        #on garde la ligne qui contient le mot-clé
        $ligne = $raw | Where-Object {$_ -match $motcle}
        # Si on a trouvé la ligne, on extrait la valeur
        if ($ligne) {
             ($ligne -split ":")[-1].Trim()
        }
    }

    # --- On construit l'objet final avec les valeurs parsées ---
    [PSCustomObject]@{
     Category = 'Password Policy'
     MinPasswordAge   = Get-Value 'Dur.e de vie minimale'
        MaxPasswordAge   = Get-Value 'Dur.e de vie maximale'
        MinPasswordLen   = Get-Value 'Longueur minimale'
        PasswordHistory  = Get-Value 'Nombre de mots de passe'
        LockoutThreshold = Get-Value 'Seuil de verrouillage'
        LockoutDuration  = Get-Value 'Dur.e du verrouillage'
        LockoutWindow    = Get-Value "Fen.tre d.observation"
    }
}