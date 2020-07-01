#!/bin/bash

input_path=$1

cd /espnet/egs/csj/asr1
../../../utils/recog_wav.sh --models csj.transformer.v1 ${input_path}
