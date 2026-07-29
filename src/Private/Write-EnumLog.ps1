function Write-EnumLog {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Level = 'INFO'
    )

    $horodatage = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Host "[$horodatage] [$Level] $Message"
}