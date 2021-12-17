#!/bin/bash

# The following parametrs can be changed

# Count of photos to take
countOfPhotos=(1 2 3 4 5 6 7 8 9 10)

# Time to wait before camera focused, adapted and etc.
cameraSleepTime=0

# Time to wait before/after lights are on
lightSleepTime=1
# Camera resolution
resolution="1920x1080"

# If camera has auto-brigthness, this parametr needed to be at least 20
framesToSkip=20

# Needed to be 1 if script will be run at the first time
isSettingUpNeeded=0

# Name of directory to save photos
dirToSave=project_photos
# Common path for all GPIO access. DO NOT CHANGE IF YOU HAVE STOCK RASPBERRY PI OS!
BASE_GPIO_PATH=/sys/class/gpio

# Assign names to GPIO pin numbers for each light.
PIN_1=9

# Assign names to states
ON="1"
OFF="0"

# Function to export pin to GPIO path
exportPin()
{
  if [ ! -e $BASE_GPIO_PATH/gpio$1 ]; then
    echo "$1" > $BASE_GPIO_PATH/export
  fi
}

# Function to set a pin as an output
setOutput()
{
  echo "out" > $BASE_GPIO_PATH/gpio$1/direction
}

# Function to change state of a light
setLightState()
{
  echo $2 > $BASE_GPIO_PATH/gpio$1/value
}

# Function to turn all lights off
allLightsOff()
{
  setLightState $PIN_1 $OFF
}

# Export pins so that we can use them
exportPin $PIN_1

# Set pins as outputs
setOutput $PIN_1

# Turn lights off to begin
allLightsOff

# Function to prepare for run main part of script
# This function include installations, creating folders, tests & etc
settingUp(){
  sudo apt update
  sudo apt install fswebcam
  isDirExist='find ~ -type d -name "$dirToSave"'
  if [ -z isDirExist  && $? -eq 0 ]
  then
       mkdir ~/$dirToSave
  fi
} 

# Function to take one formatted picture
takePhoto() {
	fswebcam --line-colour \#FFFFFFFF --banner-colour \#FFFFFFFF --timestamp "$i photo %Y-%m-%d %H:%M:%S" -r $resolution -S $framesToSkip --font sans:20 $i
	sleep $cameraSleepTime
}

# Checking for setting up condition
if [ $isSettingUpNeeded -eq 1 ]
then
	settingUp
fi

# Main part of script

cd ~/$dirToSave
for i in ${countOfPhotos[*]}
do
  setLightState $PIN_1 $ON
  sleep $lightSleepTime
  takePhoto
  setLightState $PIN_1 $OFF
  sleep $lightSleepTime

done


