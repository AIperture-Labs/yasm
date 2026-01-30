yasm_re2c(
    ${CMAKE_CURRENT_SOURCE_DIR}/arch/lc3b/lc3bid.re
    ${CMAKE_CURRENT_BINARY_DIR}/lc3bid.c
    -s
)

yasm_add_module(arch_lc3b
    arch/lc3b/lc3barch.c
    arch/lc3b/lc3bbc.c
    lc3bid.c
)
