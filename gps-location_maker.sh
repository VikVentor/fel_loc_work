#!/bin/bash

# Define the current user
USER_NAME=$(whoami)

# Define the path to the shell script

# Create the 'scripts' directory if it doesn't exist
mkdir -p /home/$USER_NAME/opt/aikaan/scripts

SHELL_SCRIPT_PATH="/home/$USER_NAME/opt/aikaan/scripts/gps-location.sh"

# Create the shell script with the initial content
cat << EOF > $SHELL_SCRIPT_PATH
#!/bin/sh
echo lat=26.002258133942785
echo lon=92.8513598078571
EOF

# Make the shell script executable
chmod +x $SHELL_SCRIPT_PATH

# Confirm the script has been created and made executable
echo "Shell script created and set as executable at $SHELL_SCRIPT_PATH"

# Define the cron job to be added (no need for 'sudo' if not running as root)
cron_job="@reboot /usr/bin/python3 /home/$USER_NAME/gps_loc.py >> /home/$USER_NAME/gps_loc.log 2>&1"

# Check if the cron job is already in the crontab
crontab -l | grep -F "$cron_job" > /dev/null
if [ $? -eq 0 ]; then
  echo "Cron job already exists."
else
  # Add the cron job to the crontab
  (crontab -l; echo "$cron_job") | crontab -
  echo "Cron job added successfully."
fi

# Modify sudoers to allow password-less sudo for the script (optional, if needed for specific tasks like serial access)
# This step will allow the current user to run the python script without a password, but only for the specific script.
echo "$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/python3 /home/$USER_NAME/gps_loc.py" | sudo tee -a /etc/sudoers > /dev/null

# Confirm that sudoers modification was successful
echo "Sudoers file updated to allow password-less sudo for the script (if needed)."
