# A quick one-liner to get all the CPU cores (Packages multiplied by number of cores) of all ESXi hosts in a vCenter

govc object.collect -s -type HostSystem -json - hardware | jq '[.ChangeSet[].Val | .SystemInfo.Vendor, .SystemInfo.Model, .CpuInfo.NumCpuPackages, .CpuInfo.NumCpuCores, (.CpuInfo.NumCpuPackages)*(.CpuInfo.NumCpuCores)] '

# This just prints out the total sum of all CPU cores

govc object.collect -s -type HostSystem -json - hardware | jq '(.ChangeSet[].Val.CpuInfo.NumCpuPackages * .ChangeSet[].Val.CpuInfo.NumCpuCores)' | jq -s 'add'
