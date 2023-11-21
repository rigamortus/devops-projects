#!/bin/bash
resourceGroupName="my-f22-rg"
scriptPath="vmname.ps1"

# Get the instance IDs for the VMSS
vmNames=($(az vm list --resource-group my-f22-rg --query '[].name' --output tsv))

# Loop through each instance and run the command
for vmName in "${vmNames[@]}"; do
    echo "Running command on vm instances"
    # Run the command on each instance
    az vm run-command invoke --resource-group $resourceGroupName --name $vmName --command-id RunPowerShellScript --scripts @$scriptPath 
done
