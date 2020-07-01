#!/bin/bash

image_name=$1
container_name=$2
output_audioname=$3
audio_files=$4  # test.wav, hoge.m4a等

start_stage=0
stop_stage=4

help_message=$(cat <<EOF
Usage:
    $0 <image_name> <container_name> (optional)(<record audio name> <select recog audio path>)

Example:
    $0 espnet testcontainer (optional)example example.wav
EOF
)

if [ $# -lt 2 ]; then
    echo "${help_message}"
    exit 1;
fi

if [ ${start_stage} -le 0 ] && [ ${stop_stage} -ge 0 ]; then
    echo '----------Build Docker Image from Dockerfile----------'
    docker_image=$(docker images | grep ${image_name})
    
    if ! [[ -n ${docker_image} ]]; then  # -n : 1文字以上存在する時
        ./utils/build_image.sh ${image_name}
        echo 'finish building Docker Image' 
    else
        echo 'this Docker Image already exists, using that.'
    fi
fi

if [ ${start_stage} -le 1 ] && [ ${stop_stage} -ge 1 ]; then
    echo '----------Create Docker Container from Docker Image----------'
    docker_container=$(docker ps -a | grep ${container_name})
    
    if ! [[ -n ${docker_container} ]]; then
       ./utils/start_docker.sh ${container_name} ${image_name}
    else
        echo 'this Docker Container already exists, using that.'
    fi
fi

if [ ${start_stage} -le 2 ] && [ ${stop_stage} -ge 2 ]; then
    if [ $# -ge 3 ]; then
        echo '----------Recording audio data----------'
        local_audio_files=$(ls ./input_audio)
        
        if ! [[ -z $(echo ${local_audio_files} | grep ${output_audioname}.wav) ]]; then
            while ! [[ -z $(echo ${local_audio_files} | grep ${output_audioname}.wav) ]]
            do
                echo 'This audio file already exists!'
                echo 'Please type input audio name: '
                read output_audioname
            done
            
            change_path=$(echo ${audio_files} | grep $3.wav)
            audio_files=${audio_files/${change_path}/${output_audioname}.wav}
        fi

        sudo python3 ./utils/record.py ${output_audioname}
        docker cp $(pwd)/input_audio/${output_audioname}.wav ${container_name}:/input_audio/
    fi
fi

if [ ${start_stage} -le 3 ] && [ ${stop_stage} -ge 3 ]; then
    echo '----------Preprocess audio data----------'
    docker exec ${container_name} mkdir wav

    if [ $# -lt 4 ]; then
        echo 'Select all audio files in /input_audio'
        audio_files=$(docker exec ${container_name} ls /input_audio)
    fi

    echo 'Convert' ${audio_files}
    for audio_file in ${audio_files}; do
        docker exec ${container_name} /utils/data_prep.sh /input_audio/${audio_file} /wav/${audio_file%.*}.wav
    done
fi

if [ ${start_stage} -le 4 ] && [ ${stop_stage} -ge 4 ]; then
    echo '----------Start speech recognition----------'
    wav_files=$(docker exec ${container_name} ls /wav)
    
    echo 'Recognize' ${wav_files}
    for wav_file in ${wav_files}; do
        docker exec ${container_name} /utils/recog_wav.sh /wav/${wav_file}
    done
    
    docker exec ${container_name} rm -rf /wav
fi