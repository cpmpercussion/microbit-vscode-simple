/* common/nRF52833.ld */
/* Copyright (c) 2018-20 J. M. Spivey */

MEMORY {
    FLASH   (rx)  : ORIGIN = 0x00000000,      LENGTH = 512K
    RAM     (rwx) : ORIGIN = 0x20000000,      LENGTH = 124K
    CODERAM (rwx) : ORIGIN = 0x00800000+124K, LENGTH = 4K
}

OUTPUT_FORMAT ("elf32-littlearm")

ENTRY(Reset_Handler)

/*
  Specifies the end of the main stack (see ARM reference manual B1.4.1) This variable is
  used in startup.S to initalise the SP register. We set it to the end of the larger RAM section.
 */
_stack_end = ORIGIN(RAM) + LENGTH(RAM); /* 0x2001_8000 */

/* Amount of room that must be left unused for the stack to grow into */
_min_stack_size = 0x400;

SECTIONS {

    .rodata.vtable : { *(.rodata.vtable) } > FLASH

    /* Next we insert all the .text sections */
    .text : {
        . = ALIGN(4);
        _text_start = .;
        *(.text)
        _text_end = .;
    } > FLASH

    /* Then we insert all the .data sections */
    .data : {
        . = ALIGN(4);
        _data_start_ram = .;
        KEEP(*(.data))
        . = ALIGN(4); /* Round up the data section to a multiple of 4 bytes, to make the startup copy routine simpler */
        _data_end_ram = .;

        /* Require that the stack has some room to grow */
        /*
          NOTE: Inside of a section entry like this, the current position starts at 0, not the start address of
          the memory region. This is why we compare against LENGTH(RAM) instead of _stack_end.
        */
        ASSERT(_data_end_ram + _min_stack_size < LENGTH(RAM), "Error: Stack does not have enough room to grow");
    } > RAM AT> FLASH

    _data_start_flash = LOADADDR(.data);
    _data_end_flash = _data_start_flash + (_data_end_ram - _data_start_ram);
}