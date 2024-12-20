from time import sleep, time
import serial
import os

portwrite = "/dev/ttyUSB3"
port = "/dev/ttyUSB1"
shell_script_path = "/opt/aikaan/scripts/gps-location.sh"  # Path to the shell script

def parseGPS(data):
    if data[0:6] == "$GPRMC":
        sdata = data.split(",")
        
        # Check for valid GPS data (if V is found, it means no GPS data is available)
        if sdata[2] == 'V':
            print("\nNo satellite data available.\n")
            return

        # Parse latitude and longitude data
        lat = decode(sdata[3])  # Latitude
        dirLat = sdata[4]      # Latitude direction (N/S)
        lon = decode(sdata[5])  # Longitude
        dirLon = sdata[6]      # Longitude direction (E/W)

        # Convert latitude and longitude
        latitude = lat.split()  # Parsing latitude
        longitude = lon.split()  # Parsing longitude

        lat_value = str(int(latitude[0]) + (float(latitude[2])/60))  # Remove the direction (N/S)
        lon_value = str(int(longitude[0]) + (float(longitude[2])/60))  # Remove the direction (E/W)

        # Output 'lat=' and 'lon=' without directions
        print(f"lat={lat_value}")
        print(f"lon={lon_value}")

        # Write the data to the shell script
        write_to_shell_script(lat_value, lon_value)

        # Exit the script after writing the data
        exit(0)

def decode(coord):
    # Converts DDDMM.MMMMM -> DD deg MM.MMMMM min
    x = coord.split(".")
    head = x[0]
    tail = x[1]
    deg = head[0:-2]
    min = head[-2:]
    return deg + " deg " + min + "." + tail + " min"

def write_to_shell_script(lat, lon):
    # Open the shell script and update the lat and lon values
    try:
        with open(shell_script_path, 'r+') as file:
            lines = file.readlines()
            
            # Modify the 'lat' and 'lon' lines
            for i, line in enumerate(lines):
                if line.startswith("echo lat="):
                    lines[i] = f"echo lat={lat}\n"
                elif line.startswith("echo lon="):
                    lines[i] = f"echo lon={lon}\n"
            
            # Go back to the beginning of the file and rewrite it
            file.seek(0)
            file.writelines(lines)
            file.truncate()  # Ensure the file is truncated if it was previously larger
            
        print(f"Shell script updated at {shell_script_path}")
    except Exception as e:
        print(f"Error updating shell script: {e}")

print("Connecting Port..")
try:
    serw = serial.Serial(portwrite, baudrate=115200, timeout=1, rtscts=True, dsrdtr=True)
    serw.write('AT+QGPS=1\r'.encode())
    serw.close()
    sleep(1)
except Exception as e:
    print("Serial port connection failed.")
    print(e)

# Track the start time
start_time = time()

print("Receiving GPS data\n")
ser = serial.Serial(port, baudrate=115200, timeout=0.5, rtscts=True, dsrdtr=True)

# Run for 60 minutes (3600 seconds)
while True:
    current_time = time()
    elapsed_time = current_time - start_time
    
    if elapsed_time > 3600:
        print("60 minutes elapsed, stopping the script.")
        break  # Exit the loop after 60 minutes

    data = ser.readline().decode('utf-8')
    parseGPS(data)
    sleep(2)
