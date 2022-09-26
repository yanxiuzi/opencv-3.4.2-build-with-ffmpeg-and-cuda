set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
link_directories(
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/lib
    ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
)
add_link_options(-Wl,--as-needed)
set(CMAKE_BUILD_RPATH_USE_ORIGIN true)

set(debugger_opt "-ggdb -Og")
set(dyamic_link_opt "-fPIC")

set(BUILD_GIT_INFO "Build without git log info")
find_package(Git)

if(Git_FOUND)
    execute_process(
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ${GIT_EXECUTABLE} branch --show-current
        OUTPUT_VARIABLE GIT_BRANCH
        ERROR_VARIABLE GIT_ERROR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
        OUTPUT_VARIABLE GIT_HEAD
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT ${GIT_ERROR} STREQUAL "")
        message(WARNING "executable file not build in git repo: ${GIT_ERROR}")
    else()
        set(BUILD_GIT_INFO "${GIT_BRANCH}:${GIT_HEAD}")
    endif()
endif()

# add_compile_definitions(_BUILD_GIT_INFO='${BUILD_GIT_INFO}')
# add_compile_definitions(_BUILD_PROJECT_INFO='${CMAKE_PROJECT_NAME} ${CMAKE_PROJECT_VERSION}')

if(WIN32)
    message(STATUS "Target system: Windows")
    if(msvc)
        set(debugger_opt "-g")
    endif()
elseif(APPLE)
    message(STATUS "Target system: Apple")
elseif(ANDROID)
    message(STATUS "Target system: ANDROID")
    set(dyamic_link_opt "")
elseif(UNIX)
    message(STATUS "Target system: UNIX")
endif(WIN32)

message(STATUS "CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")
message(STATUS "CMAKE_SYSTEM_PROCESSOR  = ${CMAKE_SYSTEM_PROCESSOR}")

if(CMAKE_SYSTEM_PROCESSOR STREQUAL aarch64 AND NOT CMAKE_TOOLCHAIN_FILE)
    message(WARNING "Build for aarch64, but not define CMAKE_TOOLCHAIN_FILE, if necessary please use -DCMAKE_TOOLCHAIN_FILE=<path>")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "-Wall ${debugger_opt} ${dyamic_link_opt}")
set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -Wall ${dyamic_link_opt}")
set(CMAKE_C_FLAGS_DEBUG "-Wall ${debugger_opt} ${dyamic_link_opt}")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG -Wall ${dyamic_link_opt}")

message(STATUS "CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}")

if(CMAKE_BUILD_TYPE STREQUAL "Release")
    message(STATUS "CMAKE_CXX_FLAGS_RELEASE: ${CMAKE_CXX_FLAGS_RELEASE}")
else()
    # set(CMAKE_DEBUG_POSTFIX "_d")
    message(STATUS "CMAKE_CXX_FLAGS_DEBUG: ${CMAKE_CXX_FLAGS_DEBUG}")
endif()
