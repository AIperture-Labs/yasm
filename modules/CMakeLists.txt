include_directories(${CMAKE_CURRENT_BINARY_DIR})

include(arch/CMakeLists.txt)
include(listfmts/CMakeLists.txt)
include(parsers/CMakeLists.txt)
include(preprocs/CMakeLists.txt)
include(dbgfmts/CMakeLists.txt)
include(objfmts/CMakeLists.txt)

message(STATUS "Standard modules: ${YASM_MODULES}")

#
# Generate init_plugin.c
# This file provides the yasm_init_plugin() function for yasmstd.
#

set(INIT_PLUGIN_C ${CMAKE_CURRENT_BINARY_DIR}/init_plugin.c)
set(INIT_PLUGIN_C_REV 1)

# Don't regen if no changes; default to regen
set(regen_init_plugin_c TRUE)
if(EXISTS ${INIT_PLUGIN_C})
    file(READ ${INIT_PLUGIN_C} _old_init_plugin_c)
    string(REGEX MATCHALL "[^\n]*\n" _lines "${_old_init_plugin_c}")
    #MESSAGE(STATUS "Lines: ${_lines}")

    list(GET _lines 0 _line0)
    string(REGEX MATCH "([A-Za-z][A-Za-z0-9_]+[ ]?)+" _old_modules "${_line0}")
    #MESSAGE(STATUS "Old modules: ${_old_modules}")
    string(REPLACE ";" " " _modules_str "${YASM_MODULES}")
    string(COMPARE EQUAL "${_old_modules}" "${_modules_str} " _modules_match)

    list(GET _lines 1 _line1)
    string(REGEX MATCH "rev [0-9]+" _old_modules_rev "${_line1}")
    #MESSAGE(STATUS "Old modules rev: ${_old_modules_rev}")
    string(COMPARE EQUAL "${_old_modules_rev}" "rev ${INIT_PLUGIN_C_REV}"
        _modules_rev_match)

    if(_modules_match AND _modules_rev_match)
        set(regen_init_plugin_c FALSE)
    endif(_modules_match AND _modules_rev_match)
endif()

if(regen_init_plugin_c)
    message(STATUS "Generating standard plugin initialization file")
    string(REPLACE ";" " " _modules_str "${YASM_MODULES}")
    file(WRITE ${INIT_PLUGIN_C} "/* ${_modules_str} \n")
    file(APPEND ${INIT_PLUGIN_C} "   rev ${INIT_PLUGIN_C_REV}\n")
    file(APPEND ${INIT_PLUGIN_C} " */\n\n")
    file(APPEND ${INIT_PLUGIN_C} "#include <libyasm.h>\n")
    file(APPEND ${INIT_PLUGIN_C} "#include <libyasm/module.h>\n\n")
    foreach(module ${YASM_MODULES})
        string(REGEX MATCHALL "[a-zA-Z][a-zA-Z0-9]+" _modulepath ${module})
        list(GET _modulepath 0 _type)
        list(GET _modulepath 1 _keyword)
        file(APPEND ${INIT_PLUGIN_C}
            "extern yasm_${_type}_module yasm_${_keyword}_LTX_${_type};\n")
    endforeach()
    if(BUILD_SHARED_LIBS)
        file(APPEND ${INIT_PLUGIN_C} "\n#ifdef _MSC_VER\n")
        file(APPEND ${INIT_PLUGIN_C} "__declspec(dllexport)\n")
        file(APPEND ${INIT_PLUGIN_C} "#endif\n")
    endif()
    file(APPEND ${INIT_PLUGIN_C} "void\n")
    file(APPEND ${INIT_PLUGIN_C} "yasm_init_plugin(void)\n")
    file(APPEND ${INIT_PLUGIN_C} "{\n")
    foreach(module ${YASM_MODULES})
        string(REGEX MATCHALL "[a-zA-Z][a-zA-Z0-9]+" _modulepath ${module})
        list(GET _modulepath 0 _type)
        list(GET _modulepath 1 _keyword)
        set(_data "yasm_${_keyword}_LTX_${_type}")
        string(TOUPPER "${_type}" _type)
        file(APPEND ${INIT_PLUGIN_C}
            "    yasm_register_module(YASM_MODULE_${_type}, \"${_keyword}\", &${_data});\n")
    endforeach()
    file(APPEND ${INIT_PLUGIN_C} "}\n")
else()
    message(STATUS "Not regenerating static modules file (unchanged)")
endif()

set_source_files_properties(init_plugin.c GENERATED)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})

if(BUILD_SHARED_LIBS)
    add_library(yasmstd MODULE
        init_plugin.c
        ${YASM_MODULES_SRC}
    )
    target_link_libraries(yasmstd libyasm)

    if(WIN32)
        install(TARGETS yasmstd LIBRARY DESTINATION bin)
    else()
        install(TARGETS yasmstd LIBRARY DESTINATION lib)
    endif()
else()
    add_library(yasmstd
        init_plugin.c
        ${YASM_MODULES_SRC}
    )
    target_link_libraries(yasmstd libyasm)
endif()
