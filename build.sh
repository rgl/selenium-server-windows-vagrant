#!/bin/bash
set -x # show all commands
set -e # bail on command errors

# make sure the artefacts are available locally.
make

# clean the environment.
vagrant destroy -f || true
rm -f setup-finished.txt

# provision the machine.
# NB we are using Boxstarter to provision the applications, unfortunately, this
#    is not yet integrated in vagrant. thats why we loop waiting for the
#    boxstarter script to create the setup-finished.txt file.
vagrant up || true

# wait for the setup to finish.
echo 'waiting for the setup to finish...'
bash -c 'while [ ! -f setup-finished.txt ]; do sleep 5; done'
echo 'setup finished!'

# reboot the machine (because the Selenium Server Hub/Node only runs after a
# reboot / logon on the selenium-server account).
echo 'Rebooting to start Selenium Server Hub and Node...'
vagrant halt
vagrant up

# check whether things are running successfully by running a test against google.com.
echo 'Running test...'
SELENIUM_SERVER_HUB_PORT=$(VBoxManage showvminfo $(cat .vagrant/machines/*/virtualbox/id) --details --machinereadable | grep -E '^Forwarding\([0-9]+\)\=\"(.+),,4444\"$' | cut -d, -f4)
java -cp 'selenium-server.jar;.' Test $SELENIUM_SERVER_HUB_PORT
echo 'DONE!'

echo 'You can now use vagrant halt and vagrant up as you normally would!'

