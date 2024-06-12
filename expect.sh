#!/usr/bin/expect -f

# Set timeout for expect
set timeout -1

# Spawn the process that prompts for user input
spawn /home/$USER/AllthingsTimesketch/1-TS-Plaso-DFTimewolf_script.sh

# Expect the message "Would you like to start the containers? [Y/n] (default:no)"
expect "Would you like to start the containers? \[Y/n\] (default:no)"

# Send "Y" to indicate yes
send "Y\r"

# Expect other prompts and provide appropriate responses as needed
# For example:
# expect "Please enter username:"
# send "dfir\r"
# expect "Please enter password:"
# send "admin\r"
# expect "Confirm password:"
# send "admin\r"

# Wait for the script to finish
expect eof