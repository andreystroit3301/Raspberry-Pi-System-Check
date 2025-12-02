# System Check Script For Raspberry Pi 5
In this repository there are 2 basic bash scripts for checking the status of your raspberry pi system.

These scripts just make it easier to check things like temperatures, voltages, and throttle status.

I made these scripts for my Raspberry Pi 5, so I'm not sure if these scripts will work correctly on other raspberry pi models.

Parts of the system-status script use some packages that don't come with the raspberry pi OS. To get the full functionality of the script
you should install lm-sensors and nvme-cli. The install-recommended.sh file is a simple bash script that can install these for you. The
script will still run without these packages, but certain information will just not be printed.

This repository is mainly for the system-status script, but there are also a few standalone scripts that do one specific check.
Some of these scripts are used by the system-status script, but you can also use them on their own. The description for those 
standalone scripts will be bellow the system-status script description.

All of these scripts also have a sigint function in them. If for whatever reason the script is crawling or is frozen you can just
press "Ctrl+C" which will trigger the signal interrupt to immidiately abort the script.

<br>

## system-status
The system status script will print a list of usefull information about the raspberry pi hardware status. This script will print out the 
current status of the core hardware such as the CPU, GPU, PMIC, Power Supply, RP1 Chip, NVMe SSD, and the RTC. For information on the RP1 
chip, and any connected NVMe SSD, additional packages are required. 

By default this script will print "==== System Status ====" along with a timestamp at the beginning of the output. You can optionally disable this by just passing the integer 1 as an argument to the script such as ```system-status 1```.

The script will start by printing the output from the check-throttles script in this repo. After printing that it will print the 2
default available temperatures which is the CPU/SOC temperature and the PMIC temperature. After this it will print the ARM frequency
for the CPU along with the clock frequency for the GPU. Next it will print the CPU voltage and current along with the GPU voltage(current not available).
The script will also print the supply voltage which is just the external usb-c power supply voltage. After the supply voltage the script
will then check the Raspberry Pi 5 RTC driver to see if an RTC battery is connected. If the battery is connected, and above the minimum
2.5v required by the RTC(aka not dead), then it will output the current RTC battery voltage. If it passed the previous check it will then
also check if the trickle charging feature is enabled, and if so it will then also print the current set trickle charge voltage. 
(Also the RTC check uses a hard coded file path for the RTC battery info, so it may not work on some systems at the moment. I will 
eventually change this. If the file path exists on your system, but the script still can't find the RTC info then that means there is
an issue with your RTC driver.)

After the script will try to print temperature of the RP1 southbridge chip on the Raspberry Pi 5. The script uses the lm-sensors package
to read the RP1 temperature and print it. The temperature I beleive will always be in celcius.

At the end of the script it will use the nvme-cli package if installed to make a list of all NVMe devices that are connected. The script
will then go through every NVMe device and check the smart-log if available(indicating it's an SSD). From the S.M.A.R.T log it will extract
the read values for any available temperature sensors. If there are no available temperature sensors then it will try retrieving the main
temperature field. The script will then print the read temperatures from each sensor along with the device path of the NVMe device.

<br>
<br>

## How To Use + Example Output
To use this script first create a folder called "bin" in your home folder if you don't already have one. Once this folder is initially
created you will need to reboot the Rasbperry Pi. Doing this will create a variable path for the terminal, so any terminal utility you put
in that bin folder you can just run without having to type the whole file path. For example if the system-status file is just in your home
folder you would have to type ```./system-status``` into terminal to run the script, but when in the /home/usr/bin folder you can just type
```system-status``` into terminal and it will work. There is also the /bin folder in the root directory, but it is not recomended to put 
it there. To get full functionality of the script you can also run the install-recommended.sh script which is included in this repo.
You can also manually install the required packages with ```sudo apt install lm-sensors``` and ```sudo apt install nvme-cli```.


At the top of the script's output it will show
```
==== System Status ====
Timestamp: Mon 24 Nov 21:45:20 CST 2025
```
which you can disable by just typing 1 as the script parameter like so: ```system-status 1```

Example output of the system-status script:
```
==== System Status ====
Timestamp: Mon  1 Dec 20:45:33 CST 2025
Throttle status: Not Throttled
SOC Temp: 48.8°C
PMIC Temp: 45.3°C
CPU Clock: 1500 mHz
GPU Clock: 500 mHz
CPU Voltage: 0.89181840V
CPU Current: 0.75012000A
GPU Voltage: 0.8864V
Supply voltage: 5.11880000V
RTC Battery present. Voltage: 3.26068 V
RTC trickle charging enabled. Charging voltage: 3.3 V
RP1 southbridge Temp: 56.6°C  
SSD0 /dev/nvme0n1 Temp1: 29°C
SSD0 /dev/nvme0n1 Temp2: 38°C
SSD1 /dev/nvme1n1 Temp1: 32°C
SSD1 /dev/nvme1n1 Temp2: 40°C
```

Example output when using ```system-status 1```:
```
Throttle status: Not Throttled
SOC Temp: 48.8°C
PMIC Temp: 46.2°C
CPU Clock: 2400 mHz
GPU Clock: 910 mHz
CPU Voltage: 0.89181840V
CPU Current: 0.83942000A
GPU Voltage: 0.8864V
Supply voltage: 5.07056000V
RTC Battery present. Voltage: 3.26153 V
RTC trickle charging enabled. Charging voltage: 3.3 V
RP1 southbridge Temp: 57.2°C  
SSD0 /dev/nvme0n1 Temp1: 29°C
SSD0 /dev/nvme0n1 Temp2: 38°C
SSD1 /dev/nvme1n1 Temp1: 32°C
SSD1 /dev/nvme1n1 Temp2: 40°C
```

<br>
<br>

## check-throttles
the check-throttles scripts is a simple script that just decodes the hexadecimal value returned when checking the throttle status using
``` vcgencmd get_throttled ```.

This command returns a hexadecimal represintation of a binary number. In that binary number the bits 0, 1, 2, and 3 are flipped if the
Raspberry Pi is currently throttling in some way. The bits 16, 17, 18, and 19 are flipped if there is any history of throttling in the
current boot session. This will show if the Raspberry pi is currently or has previously been undervolted, had the ARM freq capped, had 
the CPU throttle, and/or hit the soft temperature limit(which I believe is 85°C).

If no bits are flipped then the script will just return "Not Throttled", otherwise it will print what is currently or has been throttled.
The script will decode the hexadecimal and print a message in the terminal showing what bits are flipped and what they mean.

This script can be used on it's own, but it is meant for the main system-status script.

<br>
<br>

## rtc-check
This is a simple standalone script that uses the RTC driver to see if there is an RTC battery connected. This script is just an exact 
copy of the RTC section of the main system-status script, but it gives a more wordy and verbose output.

This will first check if the hard coded file path to the data in the RTC driver is present. There are 2 file paths it checks for. The 
first being the battery voltage and the second being the charging voltage. If the RTC driver is present and working properly these files 
should be present even if you have never connected and RTC battery or used the RTC.

If the RTC info is present then it will first read the RTC battery voltage which is read in microvolts. It will then convert the 
microvolts to normal volts and check if the resulting voltage is greater than or equal to 2.5V which is the minimum Vin specified 
for the Raspberry Pi 5 RTC. If the read voltage is less than 2.5V it will be considered dead or disconnected, but it will still print
the read voltage.

If the read battery voltage is at or above the 2.5V threshold then the script will also check the currently set RTC trickle charge 
voltage. The available charging voltage range from the PMIC is 1.3V - 4.4V. If the set trickle charge voltage is at or above the minimum
charging voltage then it will be considered to be enabled, otherwise it will be considered disabled. Regardless of wether its enabled or 
disabled, this standalone script will still print the value it read for the charging voltage.

If the hard coded file path exists on your system, but the battery_voltage and charging_voltage files dont exist then there is an issue
with your RTC driver. I'm also not sure if the hard coded file path will be the same on everyone's system, so I will try to update the 
script to check through the file system for the appropriate path regardless of random numbers of jibberish in the names of some folders 
like '/soc@107c000000/soc@107c000000:rpi_rtc'.

<br>

Example Output:
```
RTC Battery is connected. Current voltage: 3.26153 V
RTC trickle charging enabled. Charging voltage: 3.3 V
```

<br>
<br>

## check-pmic-power
This is a random misc script that I added which just takes the 11 voltage/current pairs that are read when you run the 
```vcgencmd pmic_read_adc``` terminal command. This command only provides the current readings for the lower power logic level circuits
which sometimes arent on at all. This script will just take all of the available current values with their corresponding voltage values
and calculate the total combined power consumption from them. This DOES NOT measure the total power consumption of your raspberry pi, 
only the power rails read by the PMIC ADC. Since a bunch of these voltage rails will switch the current on and off frequently, the printed
power consumption can vary alot. I made this script purely out of curiosity, so it doesn't have much use. Because of this I also wont
incorporate this into the main system-status script.

<br>

Example output:
```
Read PMIC Power: 1.954447842608943002 W
```
