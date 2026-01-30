project(x86mod)
cmake_minimum_required(VERSION 2.4)

set(YASM_SOURCE_DIR "${PROJECT_SOURCE_DIR}/../.."
    CACHE STRING "Location of Yasm source")

if(NOT YASM_SOURCE_DIR)
    message(FATAL_ERROR "YASM_SOURCE_DIR must be defined")
endif(NOT YASM_SOURCE_DIR)

set(SOURCE_DIR "${YASM_SOURCE_DIR}/modules/arch/x86")

set(YASM_POSSIBLE_PATHS
    "$ENV{ProgramFiles}/Yasm/Bin"
    /usr/bin
    /usr/local/bin
)

find_program(YASM_PATH yasm
    PATHS ${YASM_POSSIBLE_PATHS}
)

set(GENPERF_POSSIBLE_PATHS
    ${YASM_SOURCE_DIR}/objdir/tools/genperf
    ${YASM_SOURCE_DIR}/objdir/tools/genperf/Debug
    ${YASM_SOURCE_DIR}/objdir/tools/genperf/Release
)

find_program(GENPERF_PATH genperf
    DOC "The path to the yasm genperf executable"
    PATHS ${GENPERF_POSSIBLE_PATHS}
)

if(NOT GENPERF_PATH)
    MESSAGE(FATAL_ERROR "Could not find genperf executable")
endif(NOT GENPERF_PATH)

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
    MESSAGE(FATAL_ERROR "Could not find yasm include files")
endif(NOT YASM_INCLUDE_PATH)

include_directories(${YASM_INCLUDE_PATH})
include_directories(${YASM_SOURCE_DIR})

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

if(NOT YASM_LIBRARY)
    message(FATAL_ERROR "Could not find yasm library")
endif(NOT YASM_LIBRARY)

include(FindPythonInterp)

if(not python_executable)
    message(FATAL_ERROR "Could not find Python executable")
endif(NOT PYTHON_EXECUTABLE)

include_directories(${SOURCE_DIR})
include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_custom_command(
    OUTPUT
    ${CMAKE_CURRENT_BINARY_DIR}/x86insns.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.gperf
    COMMAND ${PYTHON_EXECUTABLE} ${SOURCE_DIR}/gen_x86_insn.py
    ${CMAKE_CURRENT_BINARY_DIR}/x86insns.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.gperf
    MAIN_DEPENDENCY ${SOURCE_DIR}/gen_x86_insn.py
)

macro(YASM_GENPERF _in_NAME _out_NAME)
    add_custom_command(
        OUTPUT ${_out_NAME}
        COMMAND ${GENPERF_PATH} ${_in_NAME} ${_out_NAME}
        MAIN_DEPENDENCY ${_in_NAME}
    )
endmacro(YASM_GENPERF)

yasm_genperf(
    ${SOURCE_DIR}/x86cpu.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86cpu.c
)

yasm_genperf(
    ${SOURCE_DIR}/x86regtmod.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86regtmod.c
)

yasm_genperf(
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.c
)

yasm_genperf(
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.c
)

set(insn_DEPS
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insns.c
)

set_source_files_properties(${SOURCE_DIR}/x86id.c PROPERTIES
    OBJECT_DEPENDS "${insn_DEPS}"
)

add_library(x86mod MODULE
    init_plugin.c
    ${SOURCE_DIR}/x86arch.c
    ${SOURCE_DIR}/x86bc.c
    ${SOURCE_DIR}/x86expr.c
    ${SOURCE_DIR}/x86id.c
    x86cpu.c
    x86regtmod.c
)
target_link_libraries(x86mod ${YASM_LIBRARY})
