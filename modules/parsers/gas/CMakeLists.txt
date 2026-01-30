yasm_re2c(
    ${CMAKE_CURRENT_SOURCE_DIR}/parsers/gas/gas-token.re
    ${CMAKE_CURRENT_BINARY_DIR}/gas-token.c
    -b
)

yasm_add_module(parser_gas
    parsers/gas/gas-parser.c
    parsers/gas/gas-parse.c
    parsers/gas/gas-parse-intel.c
    gas-token.c
)
