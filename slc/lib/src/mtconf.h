#ifndef MT_CONF_H
#define MT_CONF_H

#include <stdint.h>
#include <stddef.h>
#include <time.h>

typedef uint32_t confword_t;

extern confword_t mgconf_master_freq;
extern confword_t mgconf_core_freq;
extern confword_t mgconf_ftes_per_core;
extern confword_t mgconf_ttes_per_core;

struct mg_device_id
{
    uint16_t provider;
    uint16_t model;
    uint16_t revision;
    uint16_t padding;
};

struct mg_device_info
{
    size_t ndevices;
    struct mg_device_id *enumeration;
    void*               *base_addrs;
};

extern struct mg_device_info mg_devinfo;

extern size_t mg_uart_devid;
extern size_t mg_lcd_devid;
extern size_t mg_rtc_devid;
extern size_t mg_cfgrom_devid;
extern size_t mg_gfxctl_devid;
extern size_t mg_gfxfb_devid;

extern volatile uint32_t *mg_gfx_ctl;
extern void *mg_gfx_fb;

extern int verbose_boot;
extern clock_t boot_ts;

#define output_ts(Stream) do {                            \
        clock_t _tmp = clock();                           \
        output_char(' ', (Stream));                       \
        output_char('[', (Stream));                       \
        output_char('+', (Stream));                       \
        output_uint(_tmp - boot_ts, (Stream));            \
        output_char(']', (Stream));                       \
        boot_ts = _tmp;                                   \
    } while(0)

void sys_detect_devs(void);
void sys_conf_init(void);

#endif
