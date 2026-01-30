include_directories(${CMAKE_CURRENT_BINARY_DIR})

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/license.c
    COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/genstring.py
    license_msg
    ${CMAKE_CURRENT_BINARY_DIR}/license.c
    ${YASM_PROJECT_DIRDIR}/COPYING
    MAIN_DEPENDENCY ${YASM_PROJECT_DIR}/COPYING
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/genstring.py
)

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})

if(BUILD_SHARED_LIBS)
    add_executable(yasm
        yasm.c
        yasm-options.c
        yasm-plugin.c
    )
    target_link_libraries(yasm libyasm ${LIBDL})
else()
    add_executable(yasm
        yasm.c
        yasm-options.c
    )
    target_link_libraries(yasm yasmstd libyasm)
endif()

set_source_files_properties(yasm.c PROPERTIES
    OBJECT_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/license.c
)

install(TARGETS yasm RUNTIME DESTINATION bin)
