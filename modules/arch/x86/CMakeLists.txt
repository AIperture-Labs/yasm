add_custom_command(
    OUTPUT
    ${CMAKE_CURRENT_BINARY_DIR}/x86insns.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.gperf
    COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/arch/x86/gen_x86_insn.py
    ${CMAKE_CURRENT_BINARY_DIR}/x86insns.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.gperf
    MAIN_DEPENDENCY ${CMAKE_CURRENT_SOURCE_DIR}/arch/x86/gen_x86_insn.py
)

yasm_genperf(
    ${CMAKE_CURRENT_SOURCE_DIR}/arch/x86/x86cpu.gperf
    ${CMAKE_CURRENT_BINARY_DIR}/x86cpu.c
)

yasm_genperf(
    ${CMAKE_CURRENT_SOURCE_DIR}/arch/x86/x86regtmod.gperf
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

yasm_add_module(arch_x86
    arch/x86/x86arch.c
    arch/x86/x86bc.c
    arch/x86/x86expr.c
    arch/x86/x86id.c
    x86cpu.c
    x86regtmod.c
)

set(insn_DEPS
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_nasm.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insn_gas.c
    ${CMAKE_CURRENT_BINARY_DIR}/x86insns.c
)

set_source_files_properties(arch/x86/x86id.c PROPERTIES
    OBJECT_DEPENDS "${insn_DEPS}"
)
