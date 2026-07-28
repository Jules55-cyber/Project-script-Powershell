function Get-EnumLocalGroups {
    [cmdletbinding()]
    param ()
    GET-LocalGroup | ForEach-Object {
        [PSCustomObject]@{
            Category = 'Local Groups'
            GroupName = $_.Name
            Description = $_.Description
            SID = $_.SID
        }
    }
return $localGroups
}    