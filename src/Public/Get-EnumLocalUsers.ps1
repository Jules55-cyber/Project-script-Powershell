function GET-EnumLocalUsers {
    [cmdletbinding()]
    param ()

    GET-LocalUser | ForEach-Object {
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
