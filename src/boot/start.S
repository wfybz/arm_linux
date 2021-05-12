.text
.global _start
_start:
	b reset                          
	ldr pc, _undifined_instruction   
	ldr pc, _software_interrupt
	ldr pc, _prefetch_abort
	ldr pc, _data_abort
	ldr pc, _not_used
	ldr pc, _irq
	ldr pc, _fiq

_undifined_instruction:	.word undifined_instruction
_software_interrupt:	.word software_interrupt
_prefetch_abort:	.word prefetch_abort
_data_abort:		.word data_abort
_not_used:		.word not_used
_irq:			.word irq
_fiq:			.word fiq
_reset:	

undifined_instruction:
	nop

software_interrupt:
	nop

prefetch_abort:
	nop

data_abort:
	nop

not_used:
	nop

irq:
	nop

fiq:
	nop

reset:
	bl set_svc
	bl set_peri_port   @set peripheral prot memory cp15
	bl disable_watchdog
	bl disable_interrupt
	bl disable_mmu
	bl init_clock
	bl mem_init
	bl copy_to_ram
	bl init_stack
	bl clean_bss
@	bl light_led
	ldr pc, =gboot_main

set_svc:
	mrs r0, cpsr
	bic r0, r0, #0x1f
	orr r0, r0, #0xd3   @disable irq and fiq, svc mode
	msr cpsr, r0
	mov pc, lr

set_peri_port:
	ldr r0, =0x70000000   @peripheral base addr: 0x70000000
	orr r0, r0, #0x13     @size : 256MB
	mcr p15, 0, r0, c15, c2, 4
	mov pc, lr

#define pWTCON    0x7E004000	
disable_watchdog:
	ldr r0, =pWTCON
	mov r1, #0x0
	str r1, [r0]
	mov pc, lr

#define pVIC0INTENCLEAR 0x71200014
#define pVIC1INTENCLEAR 0x71300014
disable_interrupt:
	mvn r1, #0x0
	ldr r0, =pVIC0INTENCLEAR
	str r1, [r0]

	ldr r0, =pVIC1INTENCLEAR
	str r1, [r0]
	
	mov pc, lr

disable_mmu:
	mcr p15, 0, r0, c7, c7, 0  @Invalidate Both Caches
	mrc p15, 0, r0, c1, c0, 0  @read control reg to r0
	bic r0, r0, #0x00000007    @disable mmu Dcache 
	mcr p15, 0, r0, c1, c0, 0  @write r0 to control reg

	mov pc, lr

#define CLK_DIV0    0x7E00F020
#define DIV0_VAL    ((0x0 << 0) | (0x1 << 9) | (0x1 << 8) | (0x3 << 12))
#define OTHERS      0x7E00F900
#define MPLL_COM    0x7E00F010
#define APLL_COM    0x7E00F00C
#define CLK_SRC     0x7E00F01C

#define MDIV        (266)
#define PDIV        (3)
#define SDIV        (1)
#define PLL_VAL     ((1 << 31) | (MDIV << 16) | (PDIV << 8) | (SDIV << 0))
init_clock:
	/*
	 * ARMclk = 533MHz
	 * HCLK   = 266MHz
	 * HCLKX2 = 266MHz
	 * PCLK   = 133MHz
	*/
	ldr r0, =CLK_DIV0
	ldr r1, =DIV0_VAL
	str r1, [r0]

	/* Async Mode */
	ldr r0, =OTHERS
	ldr r1, [r0]
	bic r1, r1, #0xC0 @bit7 Asynchronous mode, bit6 select mpll(async)
	str r1, [r0]

	/* APLL = 533MHz */
	ldr r0, =APLL_COM
	ldr r1, =PLL_VAL
	str r1, [r0]

	/* MPLL = 533MHz */
	ldr r0, =MPLL_COM
	ldr r1, =PLL_VAL
	str r1, [r0]

	/* select pll clock source */
	ldr r0, =CLK_SRC
	mov r1, #0x3
	str r1, [r0]
	
	mov pc, lr

copy_to_ram:
	ldr r0, =0x0C000000
	ldr r1, =0x50008000
	add r3, r0, #1024*4
copy_loop:
	/* [r0] ->4K-> [r1] */
	ldr r2, [r0], #4   @ ldr, r0<-r0+4
	str r2, [r1], #4
	cmp r0, r3
	bne copy_loop

	mov pc, lr

init_stack:
	ldr sp, =0x54000000
	mov pc, lr

clean_bss:
	ldr r0, =bss_start
	ldr r1, =bss_end
	cmp r0, r1
	moveq pc, lr    @[r0]=[r1], then mov pc, lr

clean_loop:
	mov r2, #0
	str r2, [r0], #4
	cmp r0, r1
	bne clean_loop

	mov pc, lr


#define GPKCON0    0x7F008800
#define GPKDAT     0x7F008808
light_led:
	ldr r0, =GPKCON0
	ldr r1, =0x11110000
	str r1, [r0]

	ldr r0, =GPKDAT
	ldr r1, =0xA0
	str r1, [r0]

	mov pc, lr

