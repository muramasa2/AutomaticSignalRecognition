#!/bin/bash

input_path=$1
output_path=$2

yes | ffmpeg -i ${input_path} -ac 1 -ar 16000 -acodec pcm_s16le ${output_path}
