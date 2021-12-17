#!/bin/bash

#The following parametrs can be changed
countOfPhotos=(1 2 3 4 5 6 7 8 9 10)
sleepTime=0
resolution="1920x1080"
frameToSkip=20
isSettingUpNeeded=1

# Common path for all GPIO access
BASE_GPIO_PATH=/sys/class/gpio

# Assign names to GPIO pin numbers for each light
PIN_1=9

# Assign names to states
ON="1"
OFF="2"

exportPin()
{
  if [ ! -e $BASE_GPIO_PATH/gpio$1 ]; then
    echo "$1" > $BASE_GPIO_PATH/export
  fi
}

# Utility function to set a pin as an output
setOutput()
{
  echo "out" > $BASE_GPIO_PATH/gpio$1/direction
}

# Utility function to change state of a light
setLightState()
{
  echo $2 > $BASE_GPIO_PATH/gpio$1/value
}

# Utility function to turn all lights off
allLightsOff()
{
  setLightState $PIN_1 $OFF
}

# Ctrl-C handler for clean shutdown
shutdown()
{
  allLightsOff
  exit 0
}

trap shutdown SIGINT

# Export pins so that we can use them
exportPin $PIN_1

# Set pins as outputs
setOutput $PIN_1

# Turn lights off to begin
allLightsOff



settingUp(){
	sudo apt update
	sudo apt install fswebcam
	cd ~
	mkdir project_photos
	cd project_photos
}

takePhoto() {
	fswebcam --line-colour \#FFFFFFFF --banner-colour \#FFFFFFFF --timestamp "$i photo %Y-%m-%d %H:%M:%S" $i
	sleep $sleepTime
}

if [[isSettingUpNeeded]]
then
	settingUp
fi
# Loop forever until user presses Ctrl-C

for i in ${countOfPhotos[*]}
do
  setLightState $PIN_1 $ON
  sleep 2
  takePhoto
  setLightState $PIN_1 $OFF

done


