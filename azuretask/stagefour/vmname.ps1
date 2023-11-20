$endpoint = "http://169.254.169.254/metadata/instance?api-version=2021-01-01"
$header = @{"Metadata"="true"}

# Invoke the REST API and convert the JSON response to a PowerShell object
$response = Invoke-RestMethod -Method Get -Uri $endpoint -Headers $header
#$response = $response | ConvertFrom-Json

# Display the VM name and location
Write-Output "VM Name: $($response.compute.name)"
Write-Output "VM Location: $($response.compute.location)"

$vmLocation = $($response.compute.location)
$vmName = $($response.compute.name)

$htmlFilePath = "C:\inetpub\wwwroot\iisstart.htm"
$htmlContent = Get-Content $htmlFilePath

$htmlContent = $htmlContent -replace "%VM_NAME%", $vmName
$htmlContent = $htmlContent -replace "%VM_LOCATION%", $vmLocation

$htmlContent | Set-Content $htmlFilePath
