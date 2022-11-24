# Quick and dirty
# Will list Likewise and Domain join status on an ESXi host

$output = @()
ForEach ($esxhost in $(get-vmhost -State Connected)) {
    # PS object to hold the data
    $esxinfo = $null
    $esxinfo = [PSCustomObject]@{
        Hostname     =  $esxhost.name
    }
    # Caputres the service state of a host
    $esxSvcs = $esxhost | Get-VMHostService
    # Caputures the Domain status 
    $esxAuthState = $esxhost | Get-VMHostAuthentication

    # Add a boolean instead of a null value
    if ($esxAuthState.Domain) {
        $esxinfo | add-member -type NoteProperty -Name activeDirectoryMembership -Value [string]$esxAuthState.Domain
    } else {
        $esxinfo | add-member -type NoteProperty -Name activeDirectoryMembership -Value $false
    }

    # Make is more readable
    $sshRunning = [string]($esxSvcs | where Key -eq "TSM-SSH").Running
    $sshPolicy = [string]($esxSvcs | where Key -eq "TSM-SSH").Policy
    $likewiseRunning = [string]($esxSvcs | where Key -eq "lwsmd").Running
    $likewisePolicy = [string]($esxSvcs | where Key -eq "lwsmd").Policy

    # Status of SSH
    $esxinfo | add-member -type NoteProperty -Name serviceStatusSSH -Value $sshRunning 
    $esxinfo | add-member -type NoteProperty -Name servicePolicySSH -Value  $sshPolicy
    # Status of Likewise
    $esxinfo | add-member -type NoteProperty -Name serviceStatusActiveDirectory -Value $likewiseRunning 
    $esxinfo | add-member -type NoteProperty -Name servicePolicyActiveDirectory -Value $likewisePolicy 

    $output += $esxinfo
}
$output | convertto-json
