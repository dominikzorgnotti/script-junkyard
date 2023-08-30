
# This just prints out the total sum of all CPU core license packs, see https://kb.vmware.com/s/article/89116

govc object.collect -s -type HostSystem -json - hardware | jq -r '{Sockets: .ChangeSet[].Val.CpuInfo.NumCpuPackages, CoresPerSocket: .ChangeSet[].Val.CpuInfo.NumCpuCores, LicensePacks: ((.ChangeSet[].Val.CpuInfo.NumCpuCores / 16 | ceil ) * .ChangeSet[].Val.CpuInfo.NumCpuPackages)}' | jq -s '[.[].LicensePacks] | add'


# A quick one-liner to get all the CPU cores (Packages multiplied by number of cores) of all ESXi hosts in a vCenter

govc object.collect -s -type HostSystem -json - hardware | jq '[.ChangeSet[].Val | .SystemInfo.Vendor, .SystemInfo.Model, .CpuInfo.NumCpuPackages, .CpuInfo.NumCpuCores, (.CpuInfo.NumCpuPackages)*(.CpuInfo.NumCpuCores)] '

# This just prints out the total sum of all CPU cores

govc object.collect -s -type HostSystem -json - hardware | jq '(.ChangeSet[].Val.CpuInfo.NumCpuPackages * .ChangeSet[].Val.CpuInfo.NumCpuCores)' | jq -s 'add'
