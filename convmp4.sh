#!/bin/bash


echo "By default the script will create an mp4 container with h264 encoding as that seems to be the format supported by most devices."


function die() {
exit 1
}

function convertvideo () {
echo "ffmpeg -y -vsync 2 -hide_banner -hwaccel cuvid -i $input -r $framerate -c:v $vencoder -b:v $vbit -c:a $aencoder -b:a $abit -ar $audiosr $output"".$container"
#time ffmpeg -y -vsync 0 -hide_banner -hwaccel cuvid -i $input -r $framerate -c:v $vencoder -filter_complex "yadif=parity=tff:deint=all,unsharp=lx=7:ly=7:la=1.5:cx=7:cy=7:ca=1.5,scale=$aspect" -b:v $vbit -c:a $aencoder -b:a $abit -ar $audiosr $output"".$container
time ffmpeg -y -vsync 0 -hide_banner -hwaccel cuvid -i $input -r $framerate -c:v $vencoder -filter_complex "yadif=parity=tff:deint=all,scale=$aspect" -b:v $vbit -c:a $aencoder -b:a $abit -ar $audiosr $output"".$container
}

## temp cli
#### DeInterlacing
### for i in `ls`; do ffmpeg -y -hwaccel cuvid -vsync 0 -i $i -c:v h264_nvenc -preset llhq -vf "yadif=parity=tff:deint=all" -c:a aac -ac 2 `basename -s .MPG $i`.mp4 ;done
### deInterlacing plus sharpning
### ffmpeg -y -hwaccel cuvid -vsync 0 -i M2U00357.MPG -c:v h264_nvenc -preset llhq -filter_complex "yadif=parity=tff:deint=all,unsharp=lx=7:ly=7:la=1.5:cx=7:cy=7:ca=1.5" -c:a aac -ac 2 M2U00357_2.mp4
### deInterlacing plus sharpning plus scaling
### ffmpeg -y -hwaccel cuvid -vsync 0 -i M2U00357.MPG -c:v h264_nvenc -preset llhq -filter_complex "yadif=parity=tff:deint=all,unsharp=lx=7:ly=7:la=1.5:cx=7:cy=7:ca=1.5,scale=1920:1080 -c:a aac -ac 2 M2U00357_2.mp4

if [[ $1 == "" ]]; then
    echo "Need the input file"
    ls -1
    die 1
fi


while getopts ay opt
do
    case $opt in
        ### Automatic
        a) framerate=30; vencoder=h264_nvenc; vbit=3M; aencoder=aac; abit=128k; audiosr=48000; input=$2; output=$input"_out"; aspect=1920:1080; container=mp4 ;;
        y) framerate=30; vencoder=h264_nvenc; vbit=5M; aencoder=aac; abit=384k; audiosr=48000; input=$2; output=$input"_out"; aspect=1920:1080; container=mp4 ;;
        i)

    esac
    convertvideo
    die
done


#Get the input file
input=$1
output=$1_out
container=mp4

##########################
#select the video encoder
echo " Select the video encoder
1. h264
2. h265
3. h264_nvenc (hardware assist)
4. h265_nvenc (hardware assist)
"

read -e -i 3 venc
case $venc in
    1) vencoder=h264 ;;
    2) vencoder=hevc ;;
    3) vencoder=h264_nvenc ;;
    4) vencoder=hevc_nvenc ;;
    *) exit ;;
esac

##########################
#select the video bitrate
echo " Select the video bitrate
1. 5M
2. 3M
3. 2M
4. 1M
5. 512k
6. 256k
7. copy (keep same bitrate)
"

read -e -i 2 vbitr
case $vbitr in
    1) vbit=5M ;;
    2) vbit=3M ;;
    3) vbit=2M ;;
    4) vbit=1M ;;
    5) vbit=512k ;;
    6) vbit=256k ;;
    7) vbit=copy ;;
    *) exit ;;
esac

##########################
#select the audio encoder
echo " Select the audio encoder
1. aac
2. ac3
3. mp3
"

read -e -i 1 aenc
case $aenc in
    1) aencoder=aac ;;
    2) aencoder=ac3 ;;
    3) aencoder=mp3 ;;
    4) aencoder=copy ;;
    *) exit ;;
esac

##########################
# Select Audio Sample rate
echo " Select the audio sample rate
1. 48000
2. 44100
"

read -e -i 1 asr
case $asr in
    1) audiosr=48000 ;;
    2) audiosr=44100 ;;
    *) exit ;;
esac


##########################
#select the audio bitrate
echo " Select the audio bitrate
1. 384k
2. 192k
3. 128k
4. 64k
"

read -e -i 2 abitr
case $abitr in
    1) abit=384k ;;
    2) abit=192k ;;
    3) abit=128k ;;
    4) abit=64k ;;
    *) exit ;;
esac

# Is hardware accelleration support possible
hw=y

##############################
# Select frame rate
echo "Select frame rate (24,30,60)"
read -e -i 30 framerate


#############################
# Select Aspect ratio
echo "Select resolution/aspect ratio
1. 3840:2160 2160p
2. 2560:1440 1440p
3. 1920:1080 1080p
4. 1280:720 720p
5. 854:480 480p
6. 640:360 360p
7. 426:240 240p
"
read -e -i 3 aspect
case $aspect in
    1) aspect=3840:2160 ;;
    2) aspect=2560:1440 ;;
    3) aspect=1920:1080 ;;
    4) aspect=1280:720  ;;
    5) aspect=854:480   ;;
    6) aspect=640:360   ;;
    7) aspect=426:240   ;;
    *) die              ;;
esac
clear

convertvideo
