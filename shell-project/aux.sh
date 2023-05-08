#!/bin/bash
groupadd developers
for name in $(ls /home/vagrant/shell/names.csv)
do 
   if [[ -z $name in $(cat /etc/passwd) ]]
   then 
       break
   else
        useradd $name -g developers -m -d /home/$name
        mkdir /home/$name/.ssh/authorized_keys
        cat ~/id_rsa.pub > /home/$name/.ssh/authorized_keys  
   fi
done  
                                                                    
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