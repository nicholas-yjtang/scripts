FROM nvidia/cuda:11.4.0-cudnn8-devel-ubuntu20.04
RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
RUN apt update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt install -y tzdata\
    build-essential cmake unzip pkg-config wget \
    libjpeg-dev libpng-dev libtiff-dev \
    libavcodec-dev libavformat-dev libswscale-dev libavresample-dev \
    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libxvidcore-dev x264 libx264-dev libfaac-dev libmp3lame-dev libtheora-dev \
    libfaac-dev libmp3lame-dev libvorbis-dev \
    libopencore-amrnb-dev libopencore-amrwb-dev \
    libdc1394-22 libdc1394-22-dev libxine2-dev libv4l-dev v4l-utils \
    libtbb-dev libatlas-base-dev gfortran \
    libgtk-3-dev \
    python3-dev python3-pip
COPY build.sh /root/build.sh
RUN /bin/bash /root/build.sh
