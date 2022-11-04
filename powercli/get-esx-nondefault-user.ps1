# Quick and dirty
# Will list any non-default account and non-default role assignments on an ESXi host

$output = @()
ForEach ($esxhost in $(get-vmhost)) {
    $esxcli = Get-EsxCli -v2 -VMHost $esxhost -ErrorAction Ignore
    if ($esxcli) {

    
    $users = $esxcli.system.account.list.Invoke()
    $permissions = $esxcli.system.permission.list.Invoke()
    [int]$usercount = ($users.Userid).count
    
    if ($usercount -gt 3) {
        $esxinfo = $null
        $roleAssignment = $null
        $userlist = @()
        $roles = @()

        $esxinfo = [PSCustomObject]@{
            Hostname     =  $esxhost.name
            Default_Usercount = 3
            System_Usercount =  $usercount
        }
        # Add non-default users to a list
        ForEach ($username in  $users.UseriD  | where { ($_ -ne "root") -and ($_ -ne "dcui") -and ($_ -ne "vpxuser") }) {
            $userlist += $username
        }
       $esxinfo | add-member -type NoteProperty -Name nonDefaultUsers -Value $userlist
       # Add non-default permission assignments to a list
       ForEach ($permission in  $permissions | where { ($_.Principal -ne "root") -and ($_.Principal -ne "dcui") -and ($_.Principal -ne "vpxuser") }) {
        $roleAssignment = [PSCustomObject]@{
            Username     =  $permission.Principal
            Role =  $permission.Role
        }
        $roles += $roleAssignment
    }
    $esxinfo | add-member -type NoteProperty -Name nonDefaultPermissions -Value $roles
    $output += $esxinfo
    }
    

}}
$output | convertto-json
