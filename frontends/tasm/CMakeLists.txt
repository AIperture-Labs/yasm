include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${yasm_SOURCE_DIR}/frontends/yasm
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/license.c
    COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_SOURCE_DIR}/frontends/yasm/genstring.py
    license_msg
    ${CMAKE_CURRENT_BINARY_DIR}/license.c
    ${YASM_PROJECT_DIRDIR}/COPYING
    MAIN_DEPENDENCY ${YASM_PROJECT_DIR}/COPYING
    DEPENDS ${CMAKE_SOURCE_DIR}/frontends/yasm/genstring.py
)

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})

if(BUILD_SHARED_LIBS)
    add_executable(ytasm
        tasm.c
        tasm-options.c
        ${yasm_SOURCE_DIR}/frontends/yasm/yasm-plugin.c
    )
    target_link_libraries(ytasm libyasm ${LIBDL})
else()
    add_executable(ytasm
        tasm.c
        tasm-options.c
    )
    target_link_libraries(ytasm yasmstd libyasm)
endif()

set_source_files_properties(tasm.c PROPERTIES
    OBJECT_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/license.c
)

install(TARGETS ytasm RUNTIME DESTINATION bin)
