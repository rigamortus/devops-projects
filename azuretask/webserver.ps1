C:\Windows\system32\sysprep\sysprep.exe /generalize /oobe /shutdown /mode:vm -Wait

#openssl pkcs12 -export -out yourdomain.pfx -inkey /etc/letsencrypt/live/yourdomain.com/privkey.pem -in /etc/letsencrypt/live/yourdomain.com/cert.pem -certfile /etc/letsencrypt/live/yourdomain.com/chain.pem
#openssl rsa -in myapp01.key -outform PEM -out myapp01.pem

#openssl pkcs12 -export -out davidcloud.pfx -inkey myapp01.key -in myapp01.crt
