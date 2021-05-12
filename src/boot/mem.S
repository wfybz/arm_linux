.text
.global mem_init

#define MEM_SYS_CFG    0x7E00F120
#define P1MEMCBASE     0x7E001000
#define DMC_MEMC_SAT          0x00    /* DRAM Controller status register  */
#define DMC_MEMC_CMD          0x04    /* DRAM controller command register */
#define DMC_DDR_CMD           0x08    /* direct command register          */
#define DMC_MEM_CFG           0x0C    /* memory configuration register    */
#define DMC_DDR_REFRESH_PRD   0x10    /* Refresh period register          */
#define DMC_DDR_CAS_LATENCY   0x14    /* CAS LATENCY registe              */
#define DMC_DDR_T_DQSS        0x18    /* T_DQSS register                  */
#define DMC_DDR_T_MRD         0x1C    
#define DMC_DDR_T_RAS         0x20
#define DMC_DDR_T_RC          0x24
#define DMC_DDR_T_RCD         0x28
#define DMC_DDR_T_RFC         0x2C
#define DMC_DDR_T_RP          0x30
#define DMC_DDR_T_RRD         0x34
#define DMC_DDR_T_WR          0x38
#define DMC_DDR_T_WTR         0x3C
#define DMC_DDR_T_XP          0x40
#define DMC_DDR_T_XSR         0x44
#define DMC_DDR_T_ESR         0x48
#define DMC_MEM_CFG2          0x4C
#define P1_CHIP0_CFG          0x200
#define P1_USER_CFG           0x304
		
mem_init:
		/*
	     * set static memory chip selection 
		 * multiplexing of memory port 0
		*/
		ldr r0, =MEM_SYS_CFG
		mov r1, #0x8
		str r1, [r0]
		
		ldr r0, =P1MEMCBASE    @内存控制命令寄存器
		
		mov r1, #0x4           @内存控制器进入配置模式
		str r1, [r0, #DMC_MEMC_CMD]

		ldr r1, =(7800 / (1000000000 / 133000000) + 1) @设置刷新时间
		str r1, [r0, #DMC_DDR_REFRESH_PRD]

		mov r1, #(0x3 << 1)
		str r1, [r0, #DMC_DDR_CAS_LATENCY]

		mov r1, #0x1
		str r1, [r0, #DMC_DDR_T_DQSS]

		mov r1, #0x2
		str r1, [r0, #DMC_DDR_T_MRD]

		ldr r1, =( 45 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_RAS]

		ldr r1, =( 68 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_RC]

		ldr r1, =( 23 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_RCD]

		ldr r1, =( 80 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_RFC]

		ldr r1, =( 23 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_RP]

		ldr r1, =( 15 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_RRD]

		ldr r1, =( 15 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_WR]

		mov r1, #0x07
		str r1, [r1, #DMC_DDR_T_WTR]

		mov r1, #0x02
		str r1, [r0, #DMC_DDR_T_XP]

		ldr r1, =( 120 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_XSR]

		ldr r1, =( 120 / ( 1000000000 / 133000000 ) + 1 )
		str r1, [r0, #DMC_DDR_T_ESR]

		ldr r1, =0x0001001A   @col:10, row:14
		str r1, [r0, #DMC_MEM_CFG]

		ldr r1, =0x0b45
		str r1, [r0, #DMC_MEM_CFG2]

		ldr r1, =0x150F8
		str r1, [r0, #P1_CHIP0_CFG]

		mov r1, #0x0
		str r1, [r0, #P1_USER_CFG]

		ldr r1, =0x000c0000             @ NOP
        str r1, [r0, #DMC_DDR_CMD]

		ldr r1, =0x00000000             @ Prechargeall
		str r1, [r0, #DMC_DDR_CMD]

		ldr r1, =0x00040000             @ Autorefresh
		str r1, [r0, #DMC_DDR_CMD]

		ldr r1, =0x000A0000             
		str r1, [r0, #DMC_DDR_CMD]

		ldr r1, =0x00080032
		str r1, [r0, #DMC_DDR_CMD]

		mov r1, #0x0                   @ GO
		str r1, [r0, #DMC_MEMC_CMD]

check_dec1_ready:
		ldr r1, [r0, #DMC_MEMC_SAT]
		mov r2, #0x3
		and r1, r1, r2                 @ready status
		cmp r1, #0x1
		bne check_dec1_ready
		nop
		
		mov pc, lr
