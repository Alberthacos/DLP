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
static const char *ng0 = "C:/Users/amf01/Documents/DLP/P1/Ejercicio3/controlador_display.vhd";
extern char *IEEE_P_3620187407;

unsigned char ieee_p_3620187407_sub_1742983514_3965413181(char *, char *, char *, char *, char *);
char *ieee_p_3620187407_sub_674691591_3965413181(char *, char *, char *, char *, unsigned char );
char *ieee_p_3620187407_sub_767740470_3965413181(char *, char *, char *, char *, char *, char *);


static void work_a_2661630192_0674716837_p_0(char *t0)
{
    char t5[16];
    char t16[16];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    int t8;
    unsigned int t9;
    unsigned char t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    unsigned int t17;
    char *t18;
    unsigned char t19;
    unsigned char t20;
    unsigned char t21;
    unsigned char t22;
    int t23;

LAB0:    xsi_set_current_line(28, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t1 = (t0 + 6756U);
    t3 = (t0 + 6880);
    t6 = (t5 + 0U);
    t7 = (t6 + 0U);
    *((int *)t7) = 0;
    t7 = (t6 + 4U);
    *((int *)t7) = 3;
    t7 = (t6 + 8U);
    *((int *)t7) = 1;
    t8 = (3 - 0);
    t9 = (t8 * 1);
    t9 = (t9 + 1);
    t7 = (t6 + 12U);
    *((unsigned int *)t7) = t9;
    t10 = ieee_p_3620187407_sub_1742983514_3965413181(IEEE_P_3620187407, t2, t1, t3, t5);
    if (t10 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(32, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t1 = (t0 + 6756U);
    t3 = (t0 + 6888);
    t6 = (t16 + 0U);
    t7 = (t6 + 0U);
    *((int *)t7) = 0;
    t7 = (t6 + 4U);
    *((int *)t7) = 3;
    t7 = (t6 + 8U);
    *((int *)t7) = 1;
    t8 = (3 - 0);
    t9 = (t8 * 1);
    t9 = (t9 + 1);
    t7 = (t6 + 12U);
    *((unsigned int *)t7) = t9;
    t7 = ieee_p_3620187407_sub_767740470_3965413181(IEEE_P_3620187407, t5, t2, t1, t3, t16);
    t11 = (t5 + 12U);
    t9 = *((unsigned int *)t11);
    t17 = (1U * t9);
    t10 = (4U != t17);
    if (t10 == 1)
        goto LAB5;

LAB6:    t12 = (t0 + 4136);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t18 = *((char **)t15);
    memcpy(t18, t7, 4U);
    xsi_driver_first_trans_fast(t12);
    xsi_set_current_line(33, ng0);
    t1 = (t0 + 6892);
    t3 = (t0 + 4200);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 4U);
    xsi_driver_first_trans_fast(t3);

LAB3:    xsi_set_current_line(36, ng0);
    t1 = (t0 + 1152U);
    t19 = xsi_signal_has_event(t1);
    if (t19 == 1)
        goto LAB10;

LAB11:    t10 = (unsigned char)0;

LAB12:    if (t10 != 0)
        goto LAB7;

LAB9:
LAB8:    t1 = (t0 + 4040);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(29, ng0);
    t7 = (t0 + 1032U);
    t11 = *((char **)t7);
    t7 = (t0 + 4136);
    t12 = (t7 + 56U);
    t13 = *((char **)t12);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t11, 4U);
    xsi_driver_first_trans_fast(t7);
    xsi_set_current_line(30, ng0);
    t1 = (t0 + 6884);
    t3 = (t0 + 4200);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 4U);
    xsi_driver_first_trans_fast(t3);
    goto LAB3;

LAB5:    xsi_size_not_matching(4U, t17, 0);
    goto LAB6;

LAB7:    xsi_set_current_line(37, ng0);
    t2 = (t0 + 2152U);
    t4 = *((char **)t2);
    t2 = (t0 + 6820U);
    t6 = ieee_p_3620187407_sub_674691591_3965413181(IEEE_P_3620187407, t5, t4, t2, (unsigned char)3);
    t7 = (t5 + 12U);
    t9 = *((unsigned int *)t7);
    t17 = (1U * t9);
    t22 = (2U != t17);
    if (t22 == 1)
        goto LAB13;

LAB14:    t11 = (t0 + 4264);
    t12 = (t11 + 56U);
    t13 = *((char **)t12);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 2U);
    xsi_driver_first_trans_fast(t11);
    xsi_set_current_line(39, ng0);
    t1 = (t0 + 2152U);
    t2 = *((char **)t1);
    t1 = (t0 + 6896);
    t8 = xsi_mem_cmp(t1, t2, 2U);
    if (t8 == 1)
        goto LAB16;

LAB19:    t4 = (t0 + 6898);
    t23 = xsi_mem_cmp(t4, t2, 2U);
    if (t23 == 1)
        goto LAB17;

LAB20:
LAB18:    xsi_set_current_line(43, ng0);
    t1 = (t0 + 6908);
    t3 = (t0 + 4328);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 4U);
    xsi_driver_first_trans_fast_port(t3);
    xsi_set_current_line(43, ng0);
    t1 = (t0 + 6912);
    t3 = (t0 + 4392);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 4U);
    xsi_driver_first_trans_fast(t3);

LAB15:    goto LAB8;

LAB10:    t2 = (t0 + 1192U);
    t3 = *((char **)t2);
    t20 = *((unsigned char *)t3);
    t21 = (t20 == (unsigned char)3);
    t10 = t21;
    goto LAB12;

LAB13:    xsi_size_not_matching(2U, t17, 0);
    goto LAB14;

LAB16:    xsi_set_current_line(40, ng0);
    t7 = (t0 + 6900);
    t12 = (t0 + 4328);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t18 = *((char **)t15);
    memcpy(t18, t7, 4U);
    xsi_driver_first_trans_fast_port(t12);
    xsi_set_current_line(40, ng0);
    t1 = (t0 + 1832U);
    t2 = *((char **)t1);
    t1 = (t0 + 4392);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t6 = (t4 + 56U);
    t7 = *((char **)t6);
    memcpy(t7, t2, 4U);
    xsi_driver_first_trans_fast(t1);
    goto LAB15;

LAB17:    xsi_set_current_line(41, ng0);
    t1 = (t0 + 6904);
    t3 = (t0 + 4328);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 4U);
    xsi_driver_first_trans_fast_port(t3);
    xsi_set_current_line(41, ng0);
    t1 = (t0 + 1992U);
    t2 = *((char **)t1);
    t1 = (t0 + 4392);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t6 = (t4 + 56U);
    t7 = *((char **)t6);
    memcpy(t7, t2, 4U);
    xsi_driver_first_trans_fast(t1);
    goto LAB15;

LAB21:;
}

static void work_a_2661630192_0674716837_p_1(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    int t4;
    char *t5;
    char *t6;
    int t7;
    char *t8;
    char *t9;
    int t10;
    char *t11;
    int t13;
    char *t14;
    int t16;
    char *t17;
    int t19;
    char *t20;
    int t22;
    char *t23;
    int t25;
    char *t26;
    int t28;
    char *t29;
    int t31;
    char *t32;
    int t34;
    char *t35;
    char *t37;
    char *t38;
    char *t39;
    char *t40;
    char *t41;

LAB0:    xsi_set_current_line(51, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 6916);
    t4 = xsi_mem_cmp(t1, t2, 4U);
    if (t4 == 1)
        goto LAB3;

LAB15:    t5 = (t0 + 6920);
    t7 = xsi_mem_cmp(t5, t2, 4U);
    if (t7 == 1)
        goto LAB4;

LAB16:    t8 = (t0 + 6924);
    t10 = xsi_mem_cmp(t8, t2, 4U);
    if (t10 == 1)
        goto LAB5;

LAB17:    t11 = (t0 + 6928);
    t13 = xsi_mem_cmp(t11, t2, 4U);
    if (t13 == 1)
        goto LAB6;

LAB18:    t14 = (t0 + 6932);
    t16 = xsi_mem_cmp(t14, t2, 4U);
    if (t16 == 1)
        goto LAB7;

LAB19:    t17 = (t0 + 6936);
    t19 = xsi_mem_cmp(t17, t2, 4U);
    if (t19 == 1)
        goto LAB8;

LAB20:    t20 = (t0 + 6940);
    t22 = xsi_mem_cmp(t20, t2, 4U);
    if (t22 == 1)
        goto LAB9;

LAB21:    t23 = (t0 + 6944);
    t25 = xsi_mem_cmp(t23, t2, 4U);
    if (t25 == 1)
        goto LAB10;

LAB22:    t26 = (t0 + 6948);
    t28 = xsi_mem_cmp(t26, t2, 4U);
    if (t28 == 1)
        goto LAB11;

LAB23:    t29 = (t0 + 6952);
    t31 = xsi_mem_cmp(t29, t2, 4U);
    if (t31 == 1)
        goto LAB12;

LAB24:    t32 = (t0 + 6956);
    t34 = xsi_mem_cmp(t32, t2, 4U);
    if (t34 == 1)
        goto LAB13;

LAB25:
LAB14:    xsi_set_current_line(63, ng0);
    t1 = (t0 + 7048);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);

LAB2:    t1 = (t0 + 4056);
    *((int *)t1) = 1;

LAB1:    return;
LAB3:    xsi_set_current_line(52, ng0);
    t35 = (t0 + 6960);
    t37 = (t0 + 4456);
    t38 = (t37 + 56U);
    t39 = *((char **)t38);
    t40 = (t39 + 56U);
    t41 = *((char **)t40);
    memcpy(t41, t35, 8U);
    xsi_driver_first_trans_fast_port(t37);
    goto LAB2;

LAB4:    xsi_set_current_line(53, ng0);
    t1 = (t0 + 6968);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB5:    xsi_set_current_line(54, ng0);
    t1 = (t0 + 6976);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB6:    xsi_set_current_line(55, ng0);
    t1 = (t0 + 6984);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB7:    xsi_set_current_line(56, ng0);
    t1 = (t0 + 6992);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB8:    xsi_set_current_line(57, ng0);
    t1 = (t0 + 7000);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB9:    xsi_set_current_line(58, ng0);
    t1 = (t0 + 7008);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB10:    xsi_set_current_line(59, ng0);
    t1 = (t0 + 7016);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB11:    xsi_set_current_line(60, ng0);
    t1 = (t0 + 7024);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB12:    xsi_set_current_line(61, ng0);
    t1 = (t0 + 7032);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB13:    xsi_set_current_line(62, ng0);
    t1 = (t0 + 7040);
    t3 = (t0 + 4456);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    t8 = (t6 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 8U);
    xsi_driver_first_trans_fast_port(t3);
    goto LAB2;

LAB26:;
}


extern void work_a_2661630192_0674716837_init()
{
	static char *pe[] = {(void *)work_a_2661630192_0674716837_p_0,(void *)work_a_2661630192_0674716837_p_1};
	xsi_register_didat("work_a_2661630192_0674716837", "isim/TopContador_isim_beh.exe.sim/work/a_2661630192_0674716837.didat");
	xsi_register_executes(pe);
}
