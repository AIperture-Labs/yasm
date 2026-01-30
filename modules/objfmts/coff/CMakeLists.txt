yasm_genmacro(
    ${CMAKE_CURRENT_SOURCE_DIR}/objfmts/coff/win64-nasm.mac
    ${CMAKE_CURRENT_BINARY_DIR}/win64-nasm.c
    win64_nasm_stdmac
)

yasm_genmacro(
    ${CMAKE_CURRENT_SOURCE_DIR}/objfmts/coff/win64-gas.mac
    ${CMAKE_CURRENT_BINARY_DIR}/win64-gas.c
    win64_gas_stdmac
)

set(coff_DEPS
    ${CMAKE_CURRENT_BINARY_DIR}/win64-nasm.c
    ${CMAKE_CURRENT_BINARY_DIR}/win64-gas.c
)

set_source_files_properties(objfmts/coff/coff-objfmt.c PROPERTIES
    OBJECT_DEPENDS "${coff_DEPS}"
)

yasm_add_module(objfmt_coff
    objfmts/coff/coff-objfmt.c
    objfmts/coff/win64-except.c
)
list(APPEND YASM_MODULES objfmt_win32)
list(APPEND YASM_MODULES objfmt_win64)
