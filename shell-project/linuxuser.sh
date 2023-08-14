#!/bin/bash
if [ $(id -u) -eq 0 ]; then
   read -p "Enter your username : " username
   read -s -p "Enter your password : " password
   egrep "^$username" /etc/passwd > /dev/null
   if [ $? -eq 0 ]; then
      echo "username exists!"
      exit 1
   else
      useradd -m -p $password -s /bin/bash/
      [ $? -eq 0 ] && echo "User has been added to the system!" || echo "Failed to add user!"
    fi
fi
