#include <wj_types.h>

#define GPKCON0     (*(volatile unsigned long *)0x7F008800)
#define GPKDAT      (*(volatile unsigned long *)0x7F008808)

int32 led_operate(uint8 channel)
{
    GPKCON0 = 0x11110000;
    GPKDAT  = channel & 0xFF;

    return (0);
}
