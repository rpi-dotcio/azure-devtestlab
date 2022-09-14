#!/bin/bash
#
# Script to debugging and testing
#
# NOTE: Intended for use by the Azure DevTest Lab artifact system.
#

# output environment vars
mkdir /testing

env > /testing/ENV.txt
ls -la /home > /testing/home.txt
cat /etc/passwd > /testing/passwd.txt

firstUser=$(id -nu 1000)

echo "$(whoami)" > /testing/userswitch.txt
runuser -u $firstUser -- whoami >> /testing/userswitch.txt