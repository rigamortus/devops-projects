#!/bin/bash
resourceGroupName="my-f22-rg"
vmssName="my-vmss"
scriptPath="./vname.ps1"

# Get the instance IDs for the VMSS
instanceIds=($(az vmss list-instances --resource-group $resourceGroupName --name $vmssName --query '[].instanceId' --output tsv))

# Loop through each instance and run the command
for instanceId in "${instanceIds[@]}"; do
    echo "Running command on VMSS instance $instanceId"
    # Run the command on each instance
    az vmss run-command invoke --resource-group $resourceGroupName --name $vmssName --command-id RunPowerShellScript --scripts "$scriptPath" --instance-id $instanceId
done
