#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage: ./social.sh <music.mp3> <title>
#/ Description:
#/ Examples: ./social.sh Afterlife.mp3 "Afterlife - Arcade Fire"
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() {
    files=("tmp.png" "waveform.png")

    for file in ${files[@]}; do
        if [ -e $file ]; then
            rm $file
        fi
    done
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    BACKGROUND_COLOR="#fff"
    FONT_COLOR="#000000"
    WAVEFORM_COLOR="#000000"

    if [ "$#" -ne 2 ] || ! [ -f "$1" ]; then
        usage
        exit 1
    fi

    MP3="$1"
    TITLE="$2"

    # # instagram 640x640
    # # convert -compress none -size 640x640 xc:"$BACKGROUND_COLOR" tmp.png

    # instagram 1080x566
    convert -compress none -size 1080x566 xc:"$BACKGROUND_COLOR" tmp.png

    # # ( 640 * 80 ) / 100 -> 512
    # # ( 640 * 20 ) / 100 -> 128
    # # ffmpeg -i "$MP3" -filter_complex "aformat=channel_layouts=mono,showwavespic=s=512x128:colors=$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR" -frames:v 1 waveform.png
    # # convert waveform.png -compress none -compose copy -bordercolor "#2c2c2c" -border 1x1 waveform.png

    # ( 1080 * 80 ) / 100 -> 864
    # ( 566 * 20 ) / 100 -> 113 * 2
    ffmpeg -i "$MP3" -filter_complex "aformat=channel_layouts=mono,showwavespic=s=864x226:colors=$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR" -frames:v 1 waveform.png
    # convert waveform.png -compress none -compose copy -bordercolor "#2c2c2c" -border 1x1 waveform.png

    convert tmp.png waveform.png -compress none -gravity center -compose over -composite tmp.png
    convert tmp.png -compress none -gravity center -font "SanFranciscoText-Regular.otf" -fill "$FONT_COLOR" -pointsize 17 -annotate +0+113 "$TITLE" result.png
    # convert -negate result.png result.png

    open result.png
fi