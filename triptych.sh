#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage: ./triptych.sh <music.mp3> <title>
#/ Description:
#/ Examples: ./triptych.sh Afterlife.mp3 "Afterlife - Arcade Fire"
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
    FONT_COLOR="#333333"
    WAVEFORM_COLOR="#333333"

    if [ "$#" -ne 2 ] || ! [ -f "$1" ]; then
        usage
        exit 1
    fi

    MP3="$1"
    TITLE="$2"

    # 10x15 -> 1181x771
    # 1181 * 3 -> 3543
    convert -compress none -size 3543x771 xc:"$BACKGROUND_COLOR" tmp.png

    # ( 3543 * 80 ) / 100 -> 2834
    # ( 771 * 20 ) / 100 -> 154
    ffmpeg -i "$MP3" -filter_complex "aformat=channel_layouts=mono,showwavespic=s=2834x154:colors=$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR|$WAVEFORM_COLOR" -frames:v 1 waveform.png
    # convert waveform.png -compress none -compose copy -bordercolor "#2c2c2c" -border 1x1 waveform.png

    convert tmp.png waveform.png -compress none -gravity center -compose over -composite tmp.png
    convert tmp.png -compress none -gravity center -font "SanFranciscoText-Regular.otf" -fill "$FONT_COLOR" -pointsize 17 -annotate +0+154 "$TITLE" tmp.png
    # convert -negate result.png result.png

    convert tmp.png -compress none -crop 1181x771+0+0 result.png
    convert tmp.png -compress none -crop 1181x771+1181+0 result1.png
    convert tmp.png -compress none -crop 1181x771+2362+0 result2.png

    open result.png
    open result1.png
    open result2.png
fi