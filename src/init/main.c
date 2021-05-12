#include <wj_types.h>

//extern int32 led_operate(uint8 channel);

int gboot_main(void)
{
    led_operate(0xA0);

    return (0);
}
