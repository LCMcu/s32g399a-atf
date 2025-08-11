OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(bl31sram_entrypoint)
MEMORY {
    RAM (rwx): ORIGIN = 0x34302000, LENGTH = (0x34302000 + (50 * ((1) << (12)))) - 0x34302000
}
SECTIONS
{
    . = 0x34302000;
    ASSERT(. == ALIGN(((1) << (12))),
           "BL31SRAM_BASE address is not aligned on a page boundary.")
    ro . : {
        __RO_START__ = .;
        *bl31sram_entrypoint.o(.text*)
        *(.text*)
        *(.rodata*)
        . = ALIGN(8);
        __PARSER_LIB_DESCS_START__ = .;
        KEEP(*(.img_parser_lib_descs))
        __PARSER_LIB_DESCS_END__ = .;
        *(.vectors)
        __RO_END_UNALIGNED__ = .;
        . = ALIGN(((1) << (12)));
        __RO_END__ = .;
    } >RAM
    __RW_START__ = . ;
    .data . : {
        __DATA_START__ = .;
        *(.data*)
        __DATA_END__ = .;
    } >RAM
    stacks (NOLOAD) : {
        __STACKS_START__ = .;
        *(tzfw_normal_stacks)
        __STACKS_END__ = .;
    } >RAM
    .bss : ALIGN(16) {
        __BSS_START__ = .;
        *(SORT_BY_ALIGNMENT(.bss*))
        *(COMMON)
        __BSS_END__ = .;
    } >RAM
    xlat_table (NOLOAD) : {
        *(xlat_table)
    } >RAM
    __RW_END__ = .;
    __BL31SRAM_END__ = .;
    __BSS_SIZE__ = SIZEOF(.bss);
    ASSERT(. <= (0x34302000 + (50 * ((1) << (12)))), "BL31SRAM image has exceeded its limit.")
}
