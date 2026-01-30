project(yasm)
cmake_minimum_required(VERSION 3.5...4.1)
if(COMMAND cmake_policy)
    cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)

# Where to look first for cmake modules
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

set(YASM_PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

include(YasmMacros)
include(VersionGen)

option(ENABLE_NLS "Enable message translations" OFF)

option(YASM_BUILD_TESTS "Enable building of tests" ON)

if(YASM_BUILD_TESTS)
    enable_testing()
endif(YASM_BUILD_TESTS)

# Default build type to debug if not set
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING
        "Choose the type of build, options are: None Debug Release RelWithDebInfo MinSizeRel."
        FORCE)
endif(NOT CMAKE_BUILD_TYPE)

version_gen(PACKAGE_VERSION "${CMAKE_BINARY_DIR}/YASM-VERSION-FILE" "1.3.0")

set(PACKAGE_STRING "yasm ${PACKAGE_VERSION}")

include_directories(AFTER ${CMAKE_BINARY_DIR} ${yasm_SOURCE_DIR})

include(ConfigureChecks.cmake)

add_subdirectory(tools)
add_subdirectory(libyasm)
add_subdirectory(modules)
add_subdirectory(frontends)

install(FILES
    libyasm.h
    ${CMAKE_BINARY_DIR}/libyasm-stdint.h
    DESTINATION include
)
