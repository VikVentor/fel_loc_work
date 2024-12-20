#!/bin/bash

# Define the current user
USER_NAME=$(whoami)

# Define the path to the shell script directory
SCRIPTS_DIR="/home/$USER_NAME/opt/aikaan/scripts"

# Create the 'scripts' directory if it doesn't exist
mkdir -p $SCRIPTS_DIR

# Define the shell script path
SHELL_SCRIPT_PATH="$SCRIPTS_DIR/gps-location.sh"

# Create the shell script with initial content
cat << EOF > $SHELL_SCRIPT_PATH
#!/bin/sh
echo lat=26.002258133942785
echo lon=92.8513598078571
EOF

# Make the shell script executable
chmod +x $SHELL_SCRIPT_PATH

# Confirm the script has been created and made executable
echo "Shell script created and set as executable at $SHELL_SCRIPT_PATH"

# Define the cron job to be added (will run as the current user, not root)
cron_job="@reboot /usr/bin/python3 /home/$USER_NAME/gps_loc.py >> /home/$USER_NAME/gps_loc.log 2>&1"

# Check if the cron job is already in the crontab
crontab -l | grep -F "$cron_job" > /dev/null
if [ $? -eq 0 ]; then
  echo "Cron job already exists."
else
  # Add the cron job to the user's crontab (no sudo)
  (crontab -l; echo "$cron_job") | crontab -
  echo "Cron job added successfully."
fi

# (Optional) Modify sudoers to allow password-less sudo for the script if needed (for specific tasks like accessing serial ports)
# This step will allow the current user to run the Python script without a password, but only for the specific script.
echo "$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/python3 /home/$USER_NAME/gps_loc.py" | sudo tee -a /etc/sudoers > /dev/null

# Confirm that sudoers modification was successful (only if needed)
echo "Sudoers file updated to allow password-less sudo for the script (if needed)."
