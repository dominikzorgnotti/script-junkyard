
#Disable Admission Control for 2 Node Clusters (in this instance when using vSAN)
foreach ($cluster in $(get-cluster)) {
    if ((2 -eq ($cluster | get-vmhost).count) -and ($cluster.HAEnabled) -and ($cluster.VsanEnabled) -and ($cluster.HAAdmissionControlEnabled)) {
        Write-Host "Current HA Policy: HA is $($cluster.HAEnabled) and Admission Control is $($cluster.HAAdmissionControlEnabled)"
        Set-Cluster -Cluster $cluster -HAAdmissionControlEnabled $false
    }
}
