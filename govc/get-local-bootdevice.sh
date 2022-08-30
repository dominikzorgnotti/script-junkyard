#!/bin/bash
# For a given ESXi host this commands prints out the device path of the boot device
# A stripped down version of Williams PowerCLI script here: https://github.com/lamw/vmware-scripts/blob/master/powershell/ESXiBootDevice.ps1
$dc = "dc-cgn-01"
$esxhost = "cube-esx-02.lab.why-did-it.fail"
govc host.esxcli -json -dc $dc -host $esxhost storage core device list -o false | jq '.Values[] | select(.IsBootDevice[0] == "true") | .DevfsPath[0]'
