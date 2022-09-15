/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/amf01/Documents/DLP/P1/Ejercicio3/Contador_binario.vhd";
extern char *IEEE_P_3620187407;
extern char *IEEE_P_2592010699;

unsigned char ieee_p_2592010699_sub_1690584930_503743352(char *, unsigned char );
unsigned char ieee_p_2592010699_sub_1744673427_503743352(char *, char *, unsigned int , unsigned int );
char *ieee_p_3620187407_sub_436279890_3965413181(char *, char *, char *, char *, int );
char *ieee_p_3620187407_sub_436351764_3965413181(char *, char *, char *, char *, int );


static void work_a_3045168205_3212880686_p_0(char *t0)
{
    char t18[16];
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    unsigned char t5;
    unsigned char t6;
    char *t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    unsigned char t11;
    char *t12;
    unsigned char t13;
    unsigned char t14;
    char *t15;
    unsigned char t16;
    unsigned char t17;
    char *t19;
    char *t20;
    char *t21;
    unsigned int t22;
    unsigned int t23;
    unsigned char t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;
    char *t29;

LAB0:    xsi_set_current_line(26, ng0);
    t1 = (t0 + 1512U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)2);
    if (t4 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(38, ng0);
    t1 = (t0 + 6817);
    t7 = (t0 + 4136);
    t8 = (t7 + 56U);
    t12 = *((char **)t8);
    t15 = (t12 + 56U);
    t19 = *((char **)t15);
    memcpy(t19, t1, 4U);
    xsi_driver_first_trans_fast(t7);

LAB3:    xsi_set_current_line(40, ng0);
    t1 = (t0 + 1992U);
    t2 = *((char **)t1);
    t1 = (t0 + 4200);
    t7 = (t1 + 56U);
    t8 = *((char **)t7);
    t12 = (t8 + 56U);
    t15 = *((char **)t12);
    memcpy(t15, t2, 4U);
    xsi_driver_first_trans_fast_port(t1);
    xsi_set_current_line(41, ng0);
    t1 = (t0 + 1992U);
    t2 = *((char **)t1);
    t1 = (t0 + 4264);
    t7 = (t1 + 56U);
    t8 = *((char **)t7);
    t12 = (t8 + 56U);
    t15 = *((char **)t12);
    memcpy(t15, t2, 4U);
    xsi_driver_first_trans_fast_port(t1);
    t1 = (t0 + 4040);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(27, ng0);
    t1 = (t0 + 2272U);
    t6 = xsi_signal_has_event(t1);
    if (t6 == 1)
        goto LAB8;

LAB9:    t5 = (unsigned char)0;

LAB10:    if (t5 != 0)
        goto LAB5;

LAB7:
LAB6:    goto LAB3;

LAB5:    xsi_set_current_line(29, ng0);
    t7 = (t0 + 1192U);
    t12 = *((char **)t7);
    t13 = *((unsigned char *)t12);
    t14 = (t13 == (unsigned char)3);
    if (t14 == 1)
        goto LAB14;

LAB15:    t11 = (unsigned char)0;

LAB16:    if (t11 != 0)
        goto LAB11;

LAB13:    t1 = (t0 + 1192U);
    t2 = *((char **)t1);
    t4 = *((unsigned char *)t2);
    t5 = (t4 == (unsigned char)3);
    if (t5 == 1)
        goto LAB21;

LAB22:    t3 = (unsigned char)0;

LAB23:    if (t3 != 0)
        goto LAB19;

LAB20:    xsi_set_current_line(34, ng0);
    t1 = (t0 + 1992U);
    t2 = *((char **)t1);
    t1 = (t0 + 4136);
    t7 = (t1 + 56U);
    t8 = *((char **)t7);
    t12 = (t8 + 56U);
    t15 = *((char **)t12);
    memcpy(t15, t2, 4U);
    xsi_driver_first_trans_fast(t1);

LAB12:    goto LAB6;

LAB8:    t7 = (t0 + 2312U);
    t8 = *((char **)t7);
    t9 = *((unsigned char *)t8);
    t10 = (t9 == (unsigned char)3);
    t5 = t10;
    goto LAB10;

LAB11:    xsi_set_current_line(30, ng0);
    t7 = (t0 + 1992U);
    t19 = *((char **)t7);
    t7 = (t0 + 6756U);
    t20 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t18, t19, t7, 1);
    t21 = (t18 + 12U);
    t22 = *((unsigned int *)t21);
    t23 = (1U * t22);
    t24 = (4U != t23);
    if (t24 == 1)
        goto LAB17;

LAB18:    t25 = (t0 + 4136);
    t26 = (t25 + 56U);
    t27 = *((char **)t26);
    t28 = (t27 + 56U);
    t29 = *((char **)t28);
    memcpy(t29, t20, 4U);
    xsi_driver_first_trans_fast(t25);
    goto LAB12;

LAB14:    t7 = (t0 + 1352U);
    t15 = *((char **)t7);
    t16 = *((unsigned char *)t15);
    t17 = (t16 == (unsigned char)3);
    t11 = t17;
    goto LAB16;

LAB17:    xsi_size_not_matching(4U, t23, 0);
    goto LAB18;

LAB19:    xsi_set_current_line(32, ng0);
    t1 = (t0 + 1992U);
    t8 = *((char **)t1);
    t1 = (t0 + 6756U);
    t12 = ieee_p_3620187407_sub_436351764_3965413181(IEEE_P_3620187407, t18, t8, t1, 1);
    t15 = (t18 + 12U);
    t22 = *((unsigned int *)t15);
    t23 = (1U * t22);
    t10 = (4U != t23);
    if (t10 == 1)
        goto LAB24;

LAB25:    t19 = (t0 + 4136);
    t20 = (t19 + 56U);
    t21 = *((char **)t20);
    t25 = (t21 + 56U);
    t26 = *((char **)t25);
    memcpy(t26, t12, 4U);
    xsi_driver_first_trans_fast(t19);
    goto LAB12;

LAB21:    t1 = (t0 + 1352U);
    t7 = *((char **)t1);
    t6 = *((unsigned char *)t7);
    t9 = (t6 == (unsigned char)2);
    t3 = t9;
    goto LAB23;

LAB24:    xsi_size_not_matching(4U, t23, 0);
    goto LAB25;

}

static void work_a_3045168205_3212880686_p_1(char *t0)
{
    char *t1;
    unsigned char t2;
    char *t3;
    char *t4;
    int t5;
    unsigned char t6;
    char *t7;
    unsigned char t8;
    unsigned char t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    int t14;

LAB0:    xsi_set_current_line(45, ng0);
    t1 = (t0 + 992U);
    t2 = ieee_p_2592010699_sub_1744673427_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t2 != 0)
        goto LAB2;

LAB4:
LAB3:    t1 = (t0 + 4056);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(46, ng0);
    t3 = (t0 + 2152U);
    t4 = *((char **)t3);
    t5 = *((int *)t4);
    t6 = (t5 == 24999999);
    if (t6 != 0)
        goto LAB5;

LAB7:    xsi_set_current_line(50, ng0);
    t1 = (t0 + 2152U);
    t3 = *((char **)t1);
    t5 = *((int *)t3);
    t14 = (t5 + 1);
    t1 = (t0 + 4392);
    t4 = (t1 + 56U);
    t7 = *((char **)t4);
    t10 = (t7 + 56U);
    t11 = *((char **)t10);
    *((int *)t11) = t14;
    xsi_driver_first_trans_fast(t1);

LAB6:    goto LAB3;

LAB5:    xsi_set_current_line(47, ng0);
    t3 = (t0 + 2312U);
    t7 = *((char **)t3);
    t8 = *((unsigned char *)t7);
    t9 = ieee_p_2592010699_sub_1690584930_503743352(IEEE_P_2592010699, t8);
    t3 = (t0 + 4328);
    t10 = (t3 + 56U);
    t11 = *((char **)t10);
    t12 = (t11 + 56U);
    t13 = *((char **)t12);
    *((unsigned char *)t13) = t9;
    xsi_driver_first_trans_fast(t3);
    xsi_set_current_line(48, ng0);
    t1 = (t0 + 4392);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t7 = (t4 + 56U);
    t10 = *((char **)t7);
    *((int *)t10) = 1;
    xsi_driver_first_trans_fast(t1);
    goto LAB6;

}


extern void work_a_3045168205_3212880686_init()
{
	static char *pe[] = {(void *)work_a_3045168205_3212880686_p_0,(void *)work_a_3045168205_3212880686_p_1};
	xsi_register_didat("work_a_3045168205_3212880686", "isim/TopContador_isim_beh.exe.sim/work/a_3045168205_3212880686.didat");
	xsi_register_executes(pe);
}
