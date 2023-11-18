Install-WindowsFeature Web-Server

Start-Service W3SVC

Set-Service W3SVC -StartupType 'Automatic'

# Generate the HTML content
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>VM Information</title>
</head>
<body>
    <h1>VM Information</h1>
    <p>My Name: David Akalugo</p>
    <p>VM Name: %VM_NAME%</p>
    <p>Location: %VM_LOCATION%</p>
</body>
</html>
"@

# Save the HTML content to a file
$htmlContent | Out-File -FilePath "C:\inetpub\wwwroot\iisstart.htm" -Force

#Remove-Item -Path C:\Path\To\File.txt

# Restart IIS to apply the changes
Restart-Service -Name "W3SVC"

# %windir%\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /quiet /mode:vm

#openssl pkcs12 -export -out yourdomain.pfx -inkey /etc/letsencrypt/live/yourdomain.com/privkey.pem -in /etc/letsencrypt/live/yourdomain.com/cert.pem -certfile /etc/letsencrypt/live/yourdomain.com/chain.pem
#openssl rsa -in myapp01.key -outform PEM -out myapp01.pem

#openssl pkcs12 -export -out davidcloud.pfx -inkey myapp01.key -in myapp01.crt
