#!/usr/bin/env bash

files=("tmp.png" "waveform.png" "result.png" "result1.png" "result2.png")

for file in ${files[@]}; do
    if [ -e $file ]; then
        rm $file
    fi
done