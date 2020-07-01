#/bin/bash

container_name=$1
image_name=$2

docker run -itd -v $(pwd)/input_audio:/input_audio -v $(pwd)/utils:/utils --rm --name ${container_name} ${image_name} bash