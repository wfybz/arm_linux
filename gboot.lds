OUTPUT_ARCH(arm)
ENTRY(_start)
SECTIONS {
	 . = 0x50008000;

	 . = ALIGN(4);
	 .text :
	 {
	 	debug/obj/src/boot/start.o(.text)
		*(.text)
	 }

	 . = ALIGN(4);
	 .data :
	 {
	 	*(.data)
	 }

	 . = ALIGN(4);
	 bss_start = .;
	 .bss :
	 {
	 	*(.bss)
	 }
	 bss_end = .;
}
