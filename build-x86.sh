#!/bin/bash
set -e

configure(){
    cmake \
        -Bbuild \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF \
        -DWITH_FFMPEG=ON \
        -DWITH_CUDA=ON \
        -DCUDA_ARCH_BIN='7.5 8.0 8.6' \
        -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
        -DCUDA_HOST_COMPILER:FILEPATH=/usr/bin/x86_64-linux-gnu-gcc-9 \
        # -DCMAKE_VERBOSE_MAKEFILE=on \
        # -DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib-3.4.2/modules
}

build(){
    let nproc=$(nproc)-1
    cmake --build build -j $nproc
}

apt install libgtk2.0-dev
pkg-config --version gtk+-2.0
if [ $? -ne 0]; then
    echo "apt install libgtk2.0-dev failed."
    exit 1
fi

configure
build
#第一次编译产生ffmpeg， 第二次build才能链接到ffmpeg
configure
build