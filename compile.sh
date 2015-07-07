#!/bin/sh
############################################################


echo "THIS WILL NO COMPILE FFMPEG, SORRY"
echo "ready to go?"
read ASDFGH
echo "THIS WILL COPY THE NEEDED FILES TO A PUBLIC DIRECTORY"
echo "MAKING THE COMPILATION OF THE PLUGIN 'EASY'"
echo ""

DST="/usr/local"
FFMPEGDIR=$DST"/FFmpegIOS"
SRC="./src/ios/FFMpegiOS"



function bye {
	echo "Bye!"
	exit 1
}

# if usr local don't exists create! :)
if ! [ -d $DST ] ; then
	mkdir -p $DST
fi

# check if the destiny dir exist
if [ -d $FFMPEGDIR ] ; then
	# kill the dir !
	rm -rf $FFMPEGDIR
fi

# copy the include headers!
sout=`cp -pr $SRC $FFMPEGDIR`

echo "DONE!"
echo "YOU CAN COMPILE YOUR iOS PROJECT"


