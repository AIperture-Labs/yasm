include(CheckCSourceCompiles)
include(CheckCCompilerFlag)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CheckTypeSize)
include(CheckLibraryExists)

find_program(CPP_PROG NAMES cpp)

# Platform-specific include files (POSIX, Win32)
check_include_file(locale.h HAVE_LOCALE_H)
check_include_file(libgen.h HAVE_LIBGEN_H)
check_include_file(unistd.h HAVE_UNISTD_H)
check_include_file(direct.h HAVE_DIRECT_H)
check_include_file(stdint.h HAVE_STDINT_H)

check_symbol_exists(abort "stdlib.h" HAVE_ABORT)

check_function_exists(getcwd HAVE_GETCWD)
check_function_exists(toascii HAVE_TOASCII)

check_library_exists(dl dlopen "" HAVE_LIBDL)

if(HAVE_LIBDL)
    set(LIBDL "dl")
else()
    set(LIBDL "")
endif()

configure_file(libyasm-stdint.h.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/libyasm-stdint.h)
configure_file(config.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.h)

add_definitions(-DHAVE_CONFIG_H)

find_package(Python COMPONENTS Interpreter)
if(NOT Python_EXECUTABLE)
    message(FATAL_ERROR "Could not find Python executable")
endif()

if(CMAKE_COMPILER_IS_GNUCXX)
    check_c_compiler_flag(-pipe C_ACCEPTS_PIPE)
    check_c_compiler_flag(-ansi C_ACCEPTS_ANSI)
    check_c_compiler_flag(-pedantic C_ACCEPTS_PEDANTIC)
    check_c_compiler_flag(-Wall C_ACCEPTS_WALL)
    check_c_compiler_flag(-Wno-unused-parameter C_ACCEPTS_WNOUNUSEDPARAM)

    if(C_ACCEPTS_PIPE)
        add_definitions(-pipe)
    endif(C_ACCEPTS_PIPE)

    if(C_ACCEPTS_ANSI)
        add_definitions(-ansi)
    endif(C_ACCEPTS_ANSI)

    if(C_ACCEPTS_PEDANTIC)
        add_definitions(-pedantic)
    endif(C_ACCEPTS_PEDANTIC)

    if(C_ACCEPTS_WALL)
        add_definitions(-Wall)
    endif(C_ACCEPTS_WALL)

    if(C_ACCEPTS_WNOUNUSEDPARAM)
        add_definitions(-Wno-unused-parameter)
    endif(C_ACCEPTS_WNOUNUSEDPARAM)
endif(CMAKE_COMPILER_IS_GNUCXX)

# Disable some annoying Visual Studio warnings
if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-D_CRT_NONSTDC_NO_WARNINGS)
endif(MSVC)
