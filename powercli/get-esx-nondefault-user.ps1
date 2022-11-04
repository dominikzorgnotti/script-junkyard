# Quick and dirty
# Will list any non-default account on an ESXi host

ForEach ($esxhost in $(get-vmhost)) {
    $esxcli = Get-EsxCli -v2 -VMHost $esxhost -ErrorAction Ignore
    if ($esxcli) {

    
    $users = $esxcli.system.account.list.Invoke()
    [int]$usercount = ($users.Userid).count
    
    if ($usercount -gt 3) {
    Write-host $esxhost.name " - non-default local user count: " $usercount "(normal: 3)"
    Write-host "non default users: " ($users.UseriD  | where { ($_ -ne "root") -and ($_ -ne "dcui") -and ($_ -ne "vpxuser") })
    }
}
}
