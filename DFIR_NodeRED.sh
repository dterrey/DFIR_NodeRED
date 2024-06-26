#!/bin/bash
# Description: This helper script will bring up Timesketch, Kibana (separate) and Plaso dockerised versions for rapid deployment. Further, it will set up InsaneTechnologies elastic pipelines so that relevant embedded fields can be extracted and mapped to fields in ES.
# Tested on Ubuntu 22.04 LTS Server Edition
# Created by Janantha Marasinghe
# Completely Re-written by David Terrey, 20240301
#
# Usage: sudo ./tsplaso_docker_install.sh
#
# CONSTANTS
# ---------------------------------------
#Setting default user creds
USER1_NAME=dfir
USER1_PASSWORD=admin

# DATA DIRS
CASES_DIR="/cases"
DATA_DIR="/data"
PLASO_DIR="/cases/plaso"
PROCESSOR_DIR="/cases/processor"
HOST_TRIAGE_DIR="/cases/processor/host-triage"
EVTXPROC="/cases/evtxproc"
OPT="/opt"
CAPA="/opt/capa"
CHAINSAW="/cases/evtxproc/chainsaw"
MALWARE="/cases/malware"
MALWAREHASHES="/cases/malware/hashes"
TRIAGEHASHES="/cases/processor/hashes"
MALWARELOG="/cases/malware/logfile"
TRIAGELOG="/cases/processor/logfile"


# ---------------------------------------

sudo apt install curl -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install all pre-required Linux packages
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release cargo unzip unrar docker.io python3-pip expect docker-compose docker-compose-plugin -y

# Install Portainer for easier container management
#sudo systemctl start docker
#sudo systemctl enable docker
#sudo docker pull portainer/portainer-ce:latest
#sudo docker run -d -p 9000:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce:latest

echo "\n"
echo "******************************************************************************************"
printf "When prompted \n"
printf "Type Y to start the containers \n"
printf "Type Y to create a new user \n"
printf "Username: dfir \n"
printf "Password: admin \n"
printf "If you do change the username and password, you will need to update Node-Red WorkFlow \n"
echo "***************************************************************************************** \n"
sleep 15

# Download and install Timesketch
sudo curl -s -O https://raw.githubusercontent.com/google/timesketch/master/contrib/deploy_timesketch.sh
sudo chmod 755 deploy_timesketch.sh
sudo mkdir /opt/timesketch
sudo chmod 755 -R /opt/timesketch
sudo mv deploy_timesketch.sh /opt/timesketch
cd /opt/timesketch
sudo ./deploy_timesketch.sh

sudo mkdir $CASES_DIR
sudo mkdir $DATA_DIR
sudo mkdir $PLASO_DIR
sudo mkdir $PROCESSOR_DIR
sudo mkdir $EVTXPROC
sudo mkdir $CAPA
sudo mkdir $APTHUNTER
sudo mkdir $MALWARE
sudo mkdir $RESULTS
sudo mkdir $TRIAGEHASHES
sudo mkdir $TRIAGELOG
sudo mkdir $MALWAREHASHES
sudo mkdir $MALWARELOG
sudo mkdir $CHAINSAW
sudo chmod -R 777 $CASES_DIR
sudo chmod -R 777 $DATA_DIR

touch /cases/malware/hashes/hashes.txt
touch /cases/processor/hashes/hashes.txt
touch /cases/malware/logfile/logfile.txt
touch /cases/processor/logfile/logfile.txt


# Native Install Commented Out
sudo add-apt-repository universe -y
add-apt-repository ppa:gift/stable -y
apt-get update
apt-get install plaso-tools -y

# Install Timesketch import client to assist with larger plaso uploads
pip3 install timesketch-import-client

# Download the latest tags file from dterrey forked repo
sudo wget -Nq https://raw.githubusercontent.com/dterrey/AllthingsTimesketch/master/tags.yaml -O /opt/timesketch/etc/timesketch/tags.yaml

# Install Chainsaw
cd /opt/
sudo wget https://github.com/WithSecureLabs/chainsaw/releases/download/v2.9.0/chainsaw_all_platforms+rules.zip
sudo unzip chainsaw_all_platforms+rules.zip
sudo mv /opt/chainsaw/chainsaw_x86_64-unknown-linux-gnu /opt/chainsaw/chainsaw
sudo chmod 777 -R $OPT
sudo chmod +x /opt/chainsaw/chainsaw

# Install Hayabusa
sudo mkdir /opt/hayabusa
sudo chmod 777 -R /opt/hayabusa
cd /opt/hayabusa/
sudo wget https://github.com/Yamato-Security/hayabusa/releases/download/v2.15.0/hayabusa-2.15.0-all-platforms.zip
sudo unzip hayabusa-2.15.0-all-platforms.zip
sudo chmod 777 -R $OPT
sudo mv /opt/hayabusa/hayabusa-2.15.0-lin-x64-musl /opt/hayabusa/hayabusa
sudo chmod +x /opt/hayabusa/hayabusa

# Install Capa
sudo mkdir /opt/capa
sudo chmod 777 -R /opt/capa
cd /opt/capa/
sudo wget https://github.com/mandiant/capa/releases/download/v7.0.1/capa-v7.0.1-linux.zip
sudo unzip capa-v7.0.1-linux.zip
sudo chmod 777 -R $OPT
sudo chmod +x /opt/capa


# Download the loop.sh file for the plaso container
sudo wget -Nq https://raw.githubusercontent.com/dterrey/DFIR_NodeRED/master/loop.sh -O /opt/timesketch/loop.sh

# Create the first user account
sudo docker-compose exec timesketch-web tsctl create-user $USER1_NAME --password $USER1_PASSWORD


# Install ClamAV
sudo apt install clamav
sudo mkdir /cases/malware/results
sudo chmod 777 -R $OPT


# Download the script
curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered > /tmp/update_script.sh

bash /tmp/update_script.sh

sudo systemctl enable nodered.service
sudo systemctl start nodered.service

sudo chmod 777 -R /cases/malware/results/

#Increase the CSRF token time limit
# OLD --> sudo echo -e '\nWTF_CSRF_TIME_LIMIT = 3600' >> /opt/timesketch/etc/timesketch/timesketch.conf
sudo sh -c "echo -e '\nWTF_CSRF_TIME_LIMIT = 3600' >> /opt/timesketch/timesketch/etc/timesketch/timesketch.conf"

sudo sh -c "echo 'PATH=\$PATH:\$HOME/.local/bin' >> $HOME/.bashrc"
source ~/.bashrc

pip3 install --upgrade pip

pip3 install notebook

cd ~/Downloads
git clone https://github.com/dterrey/JupPlas_lib


echo "\n"
echo "******************************************************************************************"
printf "To Access Node-Red: localhost:1880 \n"
printf "To Access Timesketch: https://localhost \n"
printf "To Access Portainer via IP:9000 \n"
printf "For KAPE Collection to work with Elastic - SOF ELK is required and to be running on specific ip \n"
echo "*****************************************************************************************\n"

