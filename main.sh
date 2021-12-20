#!/bin/bash

# The following parametrs can be changed

# Count of photos to take
countOfPhotos=(1 2 3 4 5 6 7 8 9 10)

# Time to wait before camera focused, adapted and etc.
cameraSleepTime=0

# Time to wait before/after lights are on
lightSleepTime=1
# Camera resolution
resolution="1600x1200"

# If camera has auto-brigthness, this parametr needed to be at least 20
framesToSkip=20

# Needed to be 1 if script will be run at the first time
isSettingUpNeeded=1

# Name of directory to save photos
dirToSave=project_photos
# Common path for all GPIO access. DO NOT CHANGE IF YOU HAVE STOCK RASPBERRY PI OS!
BASE_GPIO_PATH=/sys/class/gpio

# Assign names to GPIO pin numbers for each light.
PIN_1=10
PIN_2=14
PIN_3=16
PIN_4=15
PIN_5=3
PIN_6=0
PIN_7=1
PIN_8=6
PIN_9=11
PIN_10=12
CONFIG_PIN=6

listOfPins=($PIN_1 $PIN_2 $PIN_3 $PIN_4 $PIN_5 $PIN_6 $PIN_7 $PIN_8 $PIN_9 $PIN_10) 

# Assign name to input GPIO pin for button
BUTTON=13
# Assign names to states
ON="1"
OFF="0"

# Function to export pin to GPIO path
exportPin()
{
  	if [ ! -e $BASE_GPIO_PATH/gpio$1 ]; then
   		sudo echo "$1" > $BASE_GPIO_PATH/export
  	fi
}

# Function to set a pin as an output
setOutput()
{
  	sudo echo "out" > $BASE_GPIO_PATH/gpio$1/direction
}

# Function to set a pin as an input
setInput()
{
	sudo echo "in" > $BASE_GPIO_PATH/gpio$1/direction
}

# Function to change state of a light
setLightState()
{
  	sudo echo $2 > $BASE_GPIO_PATH/gpio$1/value
}

# Function to get value from input pin
getValue()
{
	sudo cat $BASE_GPIO_PATH/gpio$1/value
	
}

# Function to turn all lights off
allLightsOff()
{
	for i in ${listOfPins[*]}
	do	
		setLightState $i $OFF
	done
}

# Export output pins
for i in ${listOfPins[*]}
do	
	exportPin $i
done

# Export input pins 
exportPin $BUTTON

# Set pins as outputs
for i in ${listOfPins[*]}
do	
	setOutput $i
done

# Set pins as inputs
setInput $BUTTON

# Turn lights off to begin
allLightsOff

# Function to prepare for run main part of script
# This function include installations, creating folders, tests & etc

# Variables to indicate setting up errors

isUpdateOk=1
isFswebcamOk=1
isSambaOk=1
isDirOk=1

settingUp(){
  	
	sudo apt update
  	sudo apt install -y fswebcam
	sudo apt install -y samba samba-common-bin smbclient cifs-utils
  	isDirExist=`find ~ -type d -name "$dirToSave"`
  	if [ -z $isDirExist && $? -eq 0 ]
	then
       	mkdir ~/$dirToSave
	fi
	sudo chmod 0777 ~/$dirToSave
	sudo smbpasswd -n pi
	sudo chmod 0777 /etc/samba/smb.conf
	sudo printf "[share]\npath = /home/pi/$dirToSave\nread only = no\npublic = yes\nwritable = yes\nguest ok = yes\nguest only = yes\nguest account = nobody\nbrowsable = yes" > /etc/samba/smb.conf
	sudo /etc/init.d/smbd restart

} 



# Function to take one formatted picture
takePhoto() {
	fswebcam --line-colour \#FFFFFFFF --banner-colour \#FFFFFFFF --no-timestamp -r $resolution -S $framesToSkip --font sans:20 --png $(( $i + 1 ))
	sleep $cameraSleepTime
}

# Checking for setting up condition
if [ $isSettingUpNeeded -eq 1 ]
then
	settingUp
fi

# Main part of script

cd ~/$dirToSave
while [ 1 ]
do
	if [ $(getValue $BUTTON) -eq 1 ]
	then
		for i in ${!listOfPins[*]}
		do
		setLightState ${listOfPins[$i]} $ON
  		sleep $lightSleepTime
  		takePhoto
		setLightState ${listOfPins[$i]} $OFF
 		sleep $lightSleepTime
		done
	fi
done


