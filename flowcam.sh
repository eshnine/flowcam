#!/bin/bash

function start_recording(){
	local file_name=${@-"tmp"}
  if [ "$2" = "self" ]; then
    ffplay -window_title esh -f v4l2 -framerate 25 -video_size 320x240 -i /dev/video0 &
  fi
  if [ "$3" = "only" ]; then
    exit
  fi
  ffmpeg -y -thread_queue_size 512  -f x11grab -video_size 1280x800 -framerate 30 -i :0.0  -c:v h264_qsv  -thread_queue_size 512 -f alsa -ac 2 -i hw:0  "/tmp/$file_name.mp4"
}

TEMP_OUTPUT_FILE_NAME="/tmp/flowcam.name.txt"
touch $TEMP_OUTPUT_FILE_NAME

dialog --title "Flow" --backtitle "FlowCam"  --inputbox "What is your flow?" 8 60 2>$TEMP_OUTPUT_FILE_NAME

trap "rm $TEMP_OUTPUT_FILE_NAME; exit" SIGHUP SIGINT SIGTERM

user_response=$?

flow_name=$(<$TEMP_OUTPUT_FILE_NAME)

case $user_response in
  0)
    start_recording $flow_name $1 $2
    ;;
  1)
    echo "Cancel pressed."
    ;;
  255)
    echo "[ESC] key pressed."
esac

rm $TEMP_OUTPUT_FILE_NAME

