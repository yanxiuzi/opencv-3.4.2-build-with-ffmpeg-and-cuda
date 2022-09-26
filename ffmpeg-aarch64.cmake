# ffmpeg
message(STATUS "FFMPEG_SRC_BUILD = ${FFMPEG_SRC_BUILD}")
set(ffmpeg_INSTALL_PREFIX ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/ffmpeg)

if(WITH_CUDA)
    message(STATUS "WITH_CUDA set to 'ON'.")
    set(ENABLE_CUDA ON)
endif(WITH_CUDA)

if(FFMPEG_SRC_BUILD)
    set(CUDA_FFNVCODEC_DEPEDS_HEADER "")

    if(ENABLE_CUDA)
        # IF need GPU decode, you should install depends for GPUS,
        # such as Nvidia see: https://developer.nvidia.com/blog/nvidia-ffmpeg-transcoding-guide/
        # for diff gpu compute-capability, you may need set NVCCFLAGS environment variable:
        # NVCCFLAGS=-gencode arch=compute_62,code=sm_62 -gencode arch=compute_72,code=sm_72 -gencode arch=compute_75,code=sm_75 -gencode arch=compute_80,code=sm_80 -gencode arch=compute_86,code=sm_86
        message(STATUS "ENABLE_CUDA set to 'ON'.")
        include(ExternalProject)
        find_program(MAKE_EXE NAMES gmake nmake make REQUIRED)
        ExternalProject_Add(nv-codec-headers
            GIT_REPOSITORY https://github.com/FFmpeg/nv-codec-headers
            BUILD_IN_SOURCE TRUE
            STEP_TARGETS install
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ${MAKE_EXE} -e PREFIX=${ffmpeg_INSTALL_PREFIX} -j
            INSTALL_COMMAND ${MAKE_EXE} -e PREFIX=${ffmpeg_INSTALL_PREFIX} install
            LOG_CONFIGURE TRUE
            LOG_BUILD TRUE
            LOG_INSTALL TRUE
        )
        set(CUDA_FFNVCODEC_DEPEDS_HEADER nv-codec-headers-install)
        set(FFMPEG_CUDA_FLAGS "--enable-nonfree --enable-cuda-nvcc --enable-cuvid --enable-nvenc ") # --enable-shared
        set(FFMPEG_NVCC_FLAGS "--nvccflags=\"-gencode arch=compute_62,code=sm_62 -gencode arch=compute_72,code=sm_72 -gencode arch=compute_75,code=sm_75 -O2\"")
    endif(ENABLE_CUDA)

    include(ExternalProject)
    ExternalProject_Add(ffmpeg
        # URL https://ffmpeg.org/releases/ffmpeg-4.3.3.tar.gz # 版本太高不支持
        URL https://git.ffmpeg.org/gitweb/ffmpeg.git/snapshot/390d6853d0ef408007feb39c0040682c81c02751.tar.gz
        BUILD_IN_SOURCE TRUE
        DEPENDS ${CUDA_FFNVCODEC_DEPEDS_HEADER}
        UPDATE_COMMAND apt update && apt install -y libgnutls28-dev yasm nasm liblzma-dev libbz2-dev
        ./configure --prefix=${CMAKE_BINARY_DIR}/ffmpeg --enable-pic --enable-gnutls --disable-programs --enable-nonfree --enable-cuda-nvcc
        CONFIGURE_COMMAND bash -c "PKG_CONFIG_PATH=${ffmpeg_INSTALL_PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH} ./configure --prefix=${ffmpeg_INSTALL_PREFIX} --enable-gnutls --enable-pic --disable-doc --disable-programs ${FFMPEG_CUDA_FLAGS}"
        BUILD_COMMAND ${MAKE_EXE} -j
        INSTALL_COMMAND ${ffmpeg_install_commands}
        LOG_CONFIGURE TRUE
        LOG_BUILD TRUE
        LOG_INSTALL TRUE
    )
    set(ffmpeg_SOURCE_DIR ${ffmpeg_INSTALL_PREFIX})

else(FFMPEG_SRC_BUILD)
    if(ENABLE_CUDA)
        set(FFMPEG_TAR_URL https://assets.ai-team.dev/libs/ffmpeg_cuda.tar.gz)
    else(ENABLE_CUDA)
        set(FFMPEG_TAR_URL https://assets.ai-team.dev/libs/ffmpeg.tar.gz)
    endif(ENABLE_CUDA)

    if(CMAKE_SYSTEM_PROCESSOR STREQUAL aarch64)
        set(FFMPEG_TAR_URL https://assets.ai-team.dev/libs/ffmpeg-aarch64.tar.gz)
    endif()

    include(FetchContent)
    FetchContent_Declare(ffmpeg
        URL ${FFMPEG_TAR_URL}
        SOURCE_DIR ${ffmpeg_INSTALL_PREFIX}
    )
    FetchContent_MakeAvailable(ffmpeg)
    add_library(ffmpeg INTERFACE)
endif(FFMPEG_SRC_BUILD)

set(CMAKE_SHARED_LINKER_FLAGS "-Wl,-Bsymbolic")
set(CMAKE_MODULE_PATH ${ffmpeg_INSTALL_PREFIX})
set(CMAKE_PREFIX_PATH ${ffmpeg_INSTALL_PREFIX})
set(ENV{PKG_CONFIG_PATH} ${ffmpeg_INSTALL_PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH})
