project(dbgmod)
cmake_minimum_required(VERSION 2.4)

set(YASM_POSSIBLE_PATHS
    "$ENV{ProgramFiles}/Yasm/Bin"
    /usr/bin
    /usr/local/bin
)

find_program(YASM_PATH yasm
    PATHS ${YASM_POSSIBLE_PATHS}
)

set(YASM_POSSIBLE_INCLUDE_PATHS
    "${YASM_PATH}"
    "${YASM_PATH}/../include"
    "$ENV{ProgramFiles}/Yasm/Include"
    /usr/include
    /usr/local/include
)

find_path(YASM_INCLUDE_PATH NAMES libyasm.h
    DOC "The path to the libyasm include files"
    PATHS ${YASM_POSSIBLE_INCLUDE_PATHS}
)

if(NOT YASM_INCLUDE_PATH)
    message(FATAL_ERROR "Could not find yasm include files")
endif(NOT YASM_INCLUDE_PATH)

include_directories(${YASM_INCLUDE_PATH})

set(YASM_POSSIBLE_LIB_PATHS
    "${YASM_PATH}"
    "${YASM_PATH}/../lib"
    "${YASM_INCLUDE_PATH}/../lib"
    "$ENV{ProgramFiles}/Yasm/Lib"
    /usr/lib
    /usr/local/lib
)

find_library(YASM_LIBRARY
    NAMES yasm
    DOC "The path to the libyasm library"
    PATHS ${YASM_POSSIBLE_LIB_PATHS}
)

if(NOT yasm_library)
    message(FATAL_ERROR "Could not find yasm library")
endif(NOT YASM_LIBRARY)

add_library(dbgmod MODULE
    init_plugin.c
    dbg-objfmt.c
)
target_link_libraries(dbgmod ${YASM_LIBRARY})
