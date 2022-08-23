#Requires -Modules @{ ModuleName="VMware.VimAutomation.Core"; ModuleVersion="12.0.0" }
#Requires -Version 6.0

<# 
.SYNOPSIS 
    Writes basic configuration information of an ESXi host to StdOut

.DESCRIPTION 

.NOTES 
    This PowerShell script uses vCenter and ESXCLI to provide basic configuration information for an ESXI host

.COMPONENT 
    Requires Module PowerCLI

.LINK 
    https://github.com/dominikzorgnotti/script-junkyard

.Parameter vcenter 
    Specifies the vCenter that manages the host 

.Parameter hostname 
    The hostname of the ESXi server from which you want to connect the informations 
#>



param(
    [Parameter()]
    [string]$vcenter = "xxx",

    [Parameter()]
    [string]$hostname
)

Write-Host "Checking for a valid vCenter connection..."
Write-Host ""
if ($global:DefaultVIServers) {
    Write-Host -ForegroundColor Green "✔ Connected to vCenter" $global:DefaultVIServers.Name
}
else {
    Write-Host -ForegroundColor Red "❌ No vCenter connection found."
    Start-Sleep 2
    Write-Host ""
    $vcname = Read-Host "vCenter FQDN or IP or press Enter for default [$($vcenter)]"
    $vcname = ($vcenter, $prompt)[[bool]$prompt]
    Connect-VIServer -Server $vcname -ErrorAction Stop
}

if ([String]::IsNullOrEmpty($hostname)) { 
    Write-Host "Please provide an ESXi hostname..."
    Start-Sleep 2
    $hostname = Read-Host -Prompt "ESXi FQDN or IP"
}

try { 
    $esxhost = get-vmhost $hostname 
}
catch { 
    Write-Host "An error occurred:"
    Write-Host $_.ScriptStackTrace
}


## Connection established, now gathering information

$esxcli = Get-EsxCli -VMhost $esxhost -V2

$esx_basicinfo = [PSCustomObject]@{
    esxi_bi_fqdn             = $esxhost.name
    esxi_bi_vsphere_cluster  = $esxhost.Parent.Name
    esxi_bi_esxversion_build = $esxhost.Version + " (" + $esxhost.Build + ")" 
    esxi_bi_hw_vendor_model  = $esxhost.Manufacturer + " " + $esxhost.Model
    esxi_bi_hw_serial_number = $esxhost.ExtensionData.Hardware.SystemInfo.SerialNumber
}

$esx_hosthba_info = @()

foreach ($vmhba in $(get-vmhosthba -VMHost $esxhost)) {
    $esx_hbainfo = [PSCustomObject]@{
        esxi_hba_name    = $vmhba.Device
        esxi_hba_type    = [string]$vmhba.Type
        esxi_hba_status  = $vmhba.Status
        esxi_hba_fc_wwpn = $vmhba.PortWorldWideName
    }
    $esx_hosthba_info += $esx_hbainfo
    $esx_hbainfo = $null
}

$esx_nwbasic_info = Get-VMHostNetwork -VMHost $esxhost
$esx_nw_gateway = 
$esx_nw_syslog = Get-VMHostSysLogServer -VMHost $esxhost


$esx_nwinfo = [PSCustomObject]@{
    esxi_nwinfo_dnsdomainname = $esx_nwbasic_info.SearchDomain
    esxi_nwinfo_dnsserver  = $esx_nwbasic_info.DnsAddress
    esxi_nwinfo_syslog = $esx_nw_syslog
    esxi_nwinfo_defaultgw = $esx_nwbasic_info.VMKernelGateway
}


$esx_hostvmk_info = @()
foreach ($vmk in $(Get-VMHostNetworkAdapter -VMHost $esxhost -VMKernel)) {
    $esx_vmkinfo = [PSCustomObject]@{
        esxi_vmk_name      = $vmk.Name
        esxi_vmk_portgroup = $vmk.PortGroupName
        esxi_vmk_mtu       = $vmk.Mtu
        esxi_vmk_ip        = $vmk.IP
        esxi_vmk_subnet    = $vmk.SubnetMask
        esxi_vmk_mgmt      = $vmk.ManagementTrafficEnabled
        esxi_vmk_vmotion   = $vmk.VMotionEnabled
        esxi_vmk_vsan      = $vmk.VsanTrafficEnabled
    }
    $esx_hostvmk_info += $esx_vmkinfo
    $esx_vmkinfo = $null
}

# Need View and ESXCLI to build the config map for CDP and HW information
$esxhost_networksystem = Get-View $esxhost.ExtensionData.ConfigManager.NetworkSystem
$esxhost_niclist = $esxcli.network.nic.list.Invoke()

$esx_hostpnic_info = @()
foreach ($pnic in $(Get-VMHostNetworkAdapter -VMHost $esxhost -Physical)) {
    $esx_pnicinfo = [PSCustomObject]@{
        esxi_pnic_name           = $pnic.Name
        esxi_pnic_model          = ($esxhost_niclist | where { $_.Name -match $pnic.Name }).Description
        esxi_pnic_driver         = $pnic.ExtensionData.Driver
        esxi_pnic_mac            = $pnic.Mac
        esxi_pnic_speed          = $pnic.ExtensionData.LinkSpeed.SpeedMb
        esxi_pnic_cdpswitch_name = $esxhost_networksystem.QueryNetworkHint($pnic).ConnectedSwitchPort.SystemName
        esxi_pnic_cdpswitch_port = $esxhost_networksystem.QueryNetworkHint($pnic).ConnectedSwitchPort.PortId
    }
    $esx_hostpnic_info += $esx_pnicinfo
    $esx_pnicinfo = $null
}


# Disconnect after gathering the infos
Disconnect-VIServer -Confirm:$false


# Dump info with JSON formatting
Write-Output ""
Write-Output "General information about the ESXi host"
Write-Output $esx_basicinfo | ConvertTo-Json
Write-Output ""
Write-Output ""
Write-Output "Storage information about the ESXi host"
Write-Output $esx_hosthba_info | ConvertTo-Json
Write-Output ""
Write-Output ""
Write-Output "General network information of the ESXi host"
Write-Output $esx_nwinfo | ConvertTo-Json
Write-Output ""
Write-Output ""
Write-Output "VMKernel network information about the ESXi host"
Write-Output $esx_hostvmk_info | ConvertTo-Json
Write-Output ""
Write-Output "Physical network card information about the ESXi host"
Write-Output ""
Write-Output $esx_hostpnic_info | ConvertTo-Json
Write-Output ""



