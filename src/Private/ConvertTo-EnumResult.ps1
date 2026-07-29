function ConvertTo-EnumResult {
    param(
        [string]$Category,
        [hashtable]$Data
    )

    # Fusionne la catégorie + un timestamp + les données fournies
    $base = @{
        Category  = $Category
        Timestamp = Get-Date
    }
    # On ajoute les données spécifiques à chaque fonction
    $Data.GetEnumerator() | ForEach-Object { $base[$_.Key] = $_.Value }

    [PSCustomObject]$base
}