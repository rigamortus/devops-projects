#!/bin/bash
groupadd developers
for name in $(cat /home/ubuntu/shell/names.csv)
do
   if grep -Fxq "$name" $(cat /etc/passwd)
   then
       break
   else
        useradd $name -g developers -m -d /home/$name -s /bin/bash
        mkdir /home/$name/.ssh
        cat /home/davidakalugo/shell/id_rsa.pub > /home/$name/.ssh/authorized_keys
   fi
done
