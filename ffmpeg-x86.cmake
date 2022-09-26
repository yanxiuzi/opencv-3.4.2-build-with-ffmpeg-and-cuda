if(WITH_CUDA)
# IF need GPU decode, you should install depends for GPUS, 
# Such as Nvidia see: https://developer.nvidia.com/blog/nvidia-ffmpeg-transcoding-guide/ 
# NOTE: Different GPU maybe different 'nvccflags'
# NOTE: If build with multi arch od cuda, please search 'nvccflags="$nvccflags -ptx"' in ffmpeg configure file, then comment out this code.
message(STATUS "WITH_CUDA set to 'ON'.")
endif(WITH_CUDA)
include(ExternalProject)
ExternalProject_Add(ffmpeg
    URL https://ffmpeg.org/releases/ffmpeg-4.3.3.tar.gz #版本太高不支持
    BUILD_IN_SOURCE 1
    CONFIGURE_COMMAND  bash -c "apt install libgnutls28-dev nasm -y && \
                        ./configure --prefix=${CMAKE_BINARY_DIR}/ffmpeg --enable-pic --enable-gnutls --disable-programs --enable-nonfree --enable-cuda-nvcc --nvccflags=\"-gencode arch=compute_75,code=sm_75 -gencode arch=compute_80,code=sm_80 -gencode arch=compute_86,code=sm_86 -O2\""
    BUILD_COMMAND make -j
    INSTALL_COMMAND ${ffmpeg_install_commands}
)

set(CMAKE_SHARED_LINKER_FLAGS "-Wl,-Bsymbolic")
set(CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR}/ffmpeg)
set(CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR}/ffmpeg)
set(ENV{PKG_CONFIG_PATH} ${CMAKE_BINARY_DIR}/ffmpeg/lib/pkgconfig:$ENV{PKG_CONFIG_PATH})