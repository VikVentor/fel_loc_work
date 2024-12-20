#!/bin/bash

# Define the path to the shell script
SHELL_SCRIPT_PATH="/opt/aikaan/scripts/gps_script.sh"

# Create the directory if it doesn't exist
mkdir -p /opt/aikaan/scripts

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
