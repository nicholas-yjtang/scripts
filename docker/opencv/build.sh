#!/bin/bash
mkdir -p /opt/opencv
mkdir -p /root/tmp/build
pushd /root/tmp
if [ ! -f opencv.tar.gz ]; then
wget -q -O opencv.tar.gz https://github.com/opencv/opencv/archive/refs/tags/4.5.5.tar.gz
fi
if [ ! -f opencv_contrib.tar.gz ]; then
wget -q -O opencv_contrib.tar.gz https://github.com/opencv/opencv_contrib/archive/refs/tags/4.5.5.tar.gz
fi
tar xvf opencv.tar.gz
tar xvf opencv_contrib.tar.gz
cmake -D CMAKE_BUILD_TYPE=RELEASE \
-D CMAKE_INSTALL_PREFIX=/opt/opencv \
-D WITH_TBB=ON \
-D ENABLE_FAST_MATH=1 \
-D CUDA_FAST_MATH=1 \
-D WITH_CUBLAS=1 \
-D WITH_CUDA=ON \
-D WITH_CUDNN=ON \
-D OPENCV_DNN_CUDA=ON \
-D CUDA_ARCH_BIN=8.6 \
-D WITH_V4L=ON \
-D WITH_QT=OFF \
-D WITH_GTK=ON \
-D WITH_OPENGL=ON \
-D WITH_GSTREAMER=ON \
-D OPENCV_GENERATE_PKGCONFIG=ON \
-D OPENCV_PC_FILE_NAME=opencv.pc \
-D OPENCV_ENABLE_NONFREE=ON \
-D OPENCV_PYTHON3_INSTALL_PATH=/usr/lib/python3/dist-packages \
-D PYTHON_EXECUTABLE=/usr/bin/python3 \
-D OPENCV_EXTRA_MODULES_PATH=opencv_contrib-4.5.5/modules \
-D INSTALL_PYTHON_EXAMPLES=OFF \
-D INSTALL_C_EXAMPLES=OFF \
-D BUILD_EXAMPLES=OFF -S opencv-4.5.5 -B build
pushd build
make -j
make install
popd
popd
rm -rf /root/tmp
