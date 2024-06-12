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

# ---------------------------------------

sudo apt install curl -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install all pre-required Linux packages
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release cargo unzip unrar docker.io python3-pip expect docker-compose docker-compose-plugin -y

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

# Download docker version of plaso
docker pull log2timeline/plaso
 
#add-apt-repository ppa:gift/stable -y
#apt-get update
#apt-get install plaso-tools -y

# Install Timesketch import client to assist with larger plaso uploads
pip3 install timesketch-import-client

sudo mkdir $CASES_DIR
sudo mkdir $DATA_DIR
sudo mkdir $PLASO_DIR
sudo mkdir $PROCESSOR_DIR
sudo mkdir $EVTXPROC
sudo chmod -R 777 $CASES_DIR
sudo chmod -R 777 $DATA_DIR


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
cd /opt 
git clone https://github.com/WithSecureLabs/chainsaw.git
cd chainsaw
cargo build --release

# Install Hayabusa
sudo mkdir /opt/hayabusa
sudo chmod 777 -R /opt/hayabusa
cd /opt/hayabusa/
sudo wget https://github.com/Yamato-Security/hayabusa/releases/download/v2.15.0/hayabusa-2.15.0-all-platforms.zip
sudo unzip hayabusa-2.15.0-all-platforms.zip
sudo chmod 777 -R $OPT
sudo mv /opt/hayabusa/hayabusa-2.15.0-lin-x64-musl /opt/hayabusa/hayabusa
sudo chmod +x /opt/hayabusa/hayabusa

# Download the loop.sh file for the plaso container
sudo wget -Nq https://raw.githubusercontent.com/dterrey/AllthingsTimesketch/master/loop.sh -O /opt/timesketch/loop.sh

# Create the first user account
sudo docker-compose exec timesketch-web tsctl create-user $USER1_NAME --password $USER1_PASSWORD


# Install Poetry 
#sudo curl -sSL https://install.python-poetry.org | python3 -
#echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
#source ~/.bashrc
#sudo apt install python3-poetry -y

# Install dftimewolf
#sudo mkdir /opt/dftimewolf
#sudo chmod 777 -R /opt/
#cd /opt
#sudo git clone https://github.com/log2timeline/dftimewolf.git
#cd dftimewolf
#sudo curl -sSL https://install.python-poetry.org | python3 -
#echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
#echo 'export PATH="$HOME/.poetry/bin:$PATH"' >> ~/.bashrc
#source ~/.bashrc
#pip install poetry
#poetry install



# Get the username of the user who invoked sudo
current_user="$SUDO_USER"

# Check if SUDO_USER is empty (script was not invoked with sudo)
if [ -z "$current_user" ]; then
    echo "Please run this script with sudo."
    exit 1
fi

# Move the file using the current username
sudo chmod 777 -R /home/$current_user/AllthingsTimesketch
#sudo curl -sSL https://install.python-poetry.org | python3 -
#echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
#echo 'export PATH="$HOME/.poetry/bin:$PATH"' >> ~/.bashrc
#source ~/.bashrc
#sudo chmod 777 -R /opt/dftimewolf
#pip install poetry
#poetry install
#mv /home/$current_user/AllthingsTimesketch/dftimewolf_csv.sh /opt/dftimewolf/dftimewolf_csv.sh
#mv /home/$current_user/AllthingsTimesketch/dftimewolf_csv.py /opt/dftimewolf/dftimewolf_csv.py
#mv /home/$current_user/AllthingsTimesketch/dftimewolf_plaso.sh /opt/dftimewolf/dftimewolf_plaso.sh
#mv /home/$current_user//AllthingsTimesketch/dftimewolf_plaso.py /opt/dftimewolf/dftimewolf_plaso.py
#sudo chmod 777 -R /opt/dftimewolf

#!/bin/bash

# Install Node-Red as the user "ubuntu"
sudo -u ubuntu bash -c '

# Download the script
curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered > /tmp/update_script.sh

# Execute the downloaded script
bash /tmp/update_script.sh
'

sudo systemctl enable nodered.service
sudo systemctl start nodered.service


#Increase the CSRF token time limit
# OLD --> sudo echo -e '\nWTF_CSRF_TIME_LIMIT = 3600' >> /opt/timesketch/etc/timesketch/timesketch.conf
sudo sh -c "echo -e '\nWTF_CSRF_TIME_LIMIT = 3600' >> /opt/timesketch/timesketch/etc/timesketch/timesketch.conf"



# Ingesting Plaso Logs into Elastic/Kibana
#sudo pip install pyelasticsearch

#Source - https://github.com/deviantony/docker-elk?tab=readme-ov-file#injecting-data



echo "\n"
echo "******************************************************************************************"
printf "To Access Node-Red: localhost:1880 \n"
printf "To Access Timesketch: https://localhost \n"
printf "To Access Portainer via IP:9000 \n"
printf "For KAPE Collection to work with Elastic - SOF ELK is required and to be running on specific ip \n"
echo "*****************************************************************************************\n"

