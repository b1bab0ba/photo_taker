#!/bin/bash

takePhoto() {
	fswebcam --line-colour \#FFFFFFFF --banner-colour \#FFFFFFFF --timestamp "$i photo %Y-%m-%d %H:%M:%S" $i
	sleep $sleepTime
}

#sudo apt update
#sudo apt install fswebcam

countOfPhotos=(1 2 3 4 5 6 7 8 9 10)
sleepTime=0

cd ~
mkdir project_photos
cd project_photos

for i in ${countOfPhotos[*]}
do
	takePhoto
done


