FROM ubuntu:18.04
LABEL maintainer "Masato Murata <masato.murata@g.softbank.co.jp>"

ARG NUM_BUILD_CORES=4


RUN echo "---Prepare to install kaldi---"  && \
    apt-get update && \
    apt-get -y install --no-install-recommends \ 
        automake \
        autoconf \
        apt-utils \
        bc \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        flac \
        gawk \
        gfortran \
        git \
        libtool \
        python2.7 \
        python3 \
	    python3-pip \
        sox \
        nkf \
        subversion \
        unzip \
        vim \
        wget \
        zip \
        zlib1g-dev \
        libsndfile1-dev \
        ffmpeg \
        fish \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN /usr/bin/python3 -m pip install -U pip && \
    pip install -U pip setuptools && \
    pip3 install protobuf==3.8.0 \
        joblib==0.13.2 \
        scikit-learn==0.20.3 \
        nltk==3.4


# Download kaldi
RUN echo "---Install kaldi---" && \
    git clone https://github.com/kaldi-asr/kaldi && \
    cd /kaldi && \
    rm -rf docker windows && \
    cd egs && \
    ls | grep -v -e csj -e wsj | xargs rm -rf

# Install kaldi
RUN cd /kaldi/tools && \
    ./extras/install_mkl.sh && \
    make -j ${NUM_BUILD_CORES} && \
    cd /kaldi/src && \
    ./configure && \
    make -j clean depend && \
    make -j ${NUM_BUILD_CORES}

WORKDIR /


# Download ESPnet
RUN echo "---Install ESPnet---" && \
    git clone https://github.com/espnet/espnet && \
    cd espnet && \
    rm -rf docker egs2 espnet2 && \
    cd egs && \
    ls | grep -v -e csj -e wsj | xargs rm -rf

# Install ESPnet
RUN echo "Make without GPU"; \
    cd /espnet/tools && \
    make nkf.done && \
    make KALDI=/kaldi CUPY_VERSION='' -j ${NUM_BUILD_CORES}

WORKDIR /