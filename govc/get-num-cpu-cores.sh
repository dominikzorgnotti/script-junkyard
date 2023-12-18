
# This just prints out the total sum of all CPU core license packs, see https://kb.vmware.com/s/article/89116

# Updated for breaking changes in GOVC, now the JSON keys are in camelCase.
govc object.collect -s -type HostSystem -json - hardware | jq -r '{Sockets: .changeSet[].val.cpuInfo.numCpuPackages, CoresPerSocket: .changeSet[].val.cpuInfo.numCpuCores, LicensePacks: ((.changeSet[].val.cpuInfo.numCpuCores / 16 | ceil ) * .changeSet[].val.cpuInfo.numCpuPackages)}' | jq -s '[.[].LicensePacks] | add'

