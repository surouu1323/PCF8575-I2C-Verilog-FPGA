module gw_gao(
    int_sig,
    SDA_bus,
    SCL_bus,
    \rdata[15] ,
    \rdata[14] ,
    \rdata[13] ,
    \rdata[12] ,
    \rdata[11] ,
    \rdata[10] ,
    \rdata[9] ,
    \rdata[8] ,
    \rdata[7] ,
    \rdata[6] ,
    \rdata[5] ,
    \rdata[4] ,
    \rdata[3] ,
    \rdata[2] ,
    \rdata[1] ,
    \rdata[0] ,
    \u_pcf8575/rdata_sub_reg[15] ,
    \u_pcf8575/rdata_sub_reg[14] ,
    \u_pcf8575/rdata_sub_reg[13] ,
    \u_pcf8575/rdata_sub_reg[12] ,
    \u_pcf8575/rdata_sub_reg[11] ,
    \u_pcf8575/rdata_sub_reg[10] ,
    \u_pcf8575/rdata_sub_reg[9] ,
    \u_pcf8575/rdata_sub_reg[8] ,
    \u_pcf8575/rdata_sub_reg[7] ,
    \u_pcf8575/rdata_sub_reg[6] ,
    \u_pcf8575/rdata_sub_reg[5] ,
    \u_pcf8575/rdata_sub_reg[4] ,
    \u_pcf8575/rdata_sub_reg[3] ,
    \u_pcf8575/rdata_sub_reg[2] ,
    \u_pcf8575/rdata_sub_reg[1] ,
    \u_pcf8575/rdata_sub_reg[0] ,
    clk_800Khz,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input int_sig;
input SDA_bus;
input SCL_bus;
input \rdata[15] ;
input \rdata[14] ;
input \rdata[13] ;
input \rdata[12] ;
input \rdata[11] ;
input \rdata[10] ;
input \rdata[9] ;
input \rdata[8] ;
input \rdata[7] ;
input \rdata[6] ;
input \rdata[5] ;
input \rdata[4] ;
input \rdata[3] ;
input \rdata[2] ;
input \rdata[1] ;
input \rdata[0] ;
input \u_pcf8575/rdata_sub_reg[15] ;
input \u_pcf8575/rdata_sub_reg[14] ;
input \u_pcf8575/rdata_sub_reg[13] ;
input \u_pcf8575/rdata_sub_reg[12] ;
input \u_pcf8575/rdata_sub_reg[11] ;
input \u_pcf8575/rdata_sub_reg[10] ;
input \u_pcf8575/rdata_sub_reg[9] ;
input \u_pcf8575/rdata_sub_reg[8] ;
input \u_pcf8575/rdata_sub_reg[7] ;
input \u_pcf8575/rdata_sub_reg[6] ;
input \u_pcf8575/rdata_sub_reg[5] ;
input \u_pcf8575/rdata_sub_reg[4] ;
input \u_pcf8575/rdata_sub_reg[3] ;
input \u_pcf8575/rdata_sub_reg[2] ;
input \u_pcf8575/rdata_sub_reg[1] ;
input \u_pcf8575/rdata_sub_reg[0] ;
input clk_800Khz;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire int_sig;
wire SDA_bus;
wire SCL_bus;
wire \rdata[15] ;
wire \rdata[14] ;
wire \rdata[13] ;
wire \rdata[12] ;
wire \rdata[11] ;
wire \rdata[10] ;
wire \rdata[9] ;
wire \rdata[8] ;
wire \rdata[7] ;
wire \rdata[6] ;
wire \rdata[5] ;
wire \rdata[4] ;
wire \rdata[3] ;
wire \rdata[2] ;
wire \rdata[1] ;
wire \rdata[0] ;
wire \u_pcf8575/rdata_sub_reg[15] ;
wire \u_pcf8575/rdata_sub_reg[14] ;
wire \u_pcf8575/rdata_sub_reg[13] ;
wire \u_pcf8575/rdata_sub_reg[12] ;
wire \u_pcf8575/rdata_sub_reg[11] ;
wire \u_pcf8575/rdata_sub_reg[10] ;
wire \u_pcf8575/rdata_sub_reg[9] ;
wire \u_pcf8575/rdata_sub_reg[8] ;
wire \u_pcf8575/rdata_sub_reg[7] ;
wire \u_pcf8575/rdata_sub_reg[6] ;
wire \u_pcf8575/rdata_sub_reg[5] ;
wire \u_pcf8575/rdata_sub_reg[4] ;
wire \u_pcf8575/rdata_sub_reg[3] ;
wire \u_pcf8575/rdata_sub_reg[2] ;
wire \u_pcf8575/rdata_sub_reg[1] ;
wire \u_pcf8575/rdata_sub_reg[0] ;
wire clk_800Khz;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(int_sig),
    .data_i({int_sig,SDA_bus,SCL_bus,\rdata[15] ,\rdata[14] ,\rdata[13] ,\rdata[12] ,\rdata[11] ,\rdata[10] ,\rdata[9] ,\rdata[8] ,\rdata[7] ,\rdata[6] ,\rdata[5] ,\rdata[4] ,\rdata[3] ,\rdata[2] ,\rdata[1] ,\rdata[0] ,\u_pcf8575/rdata_sub_reg[15] ,\u_pcf8575/rdata_sub_reg[14] ,\u_pcf8575/rdata_sub_reg[13] ,\u_pcf8575/rdata_sub_reg[12] ,\u_pcf8575/rdata_sub_reg[11] ,\u_pcf8575/rdata_sub_reg[10] ,\u_pcf8575/rdata_sub_reg[9] ,\u_pcf8575/rdata_sub_reg[8] ,\u_pcf8575/rdata_sub_reg[7] ,\u_pcf8575/rdata_sub_reg[6] ,\u_pcf8575/rdata_sub_reg[5] ,\u_pcf8575/rdata_sub_reg[4] ,\u_pcf8575/rdata_sub_reg[3] ,\u_pcf8575/rdata_sub_reg[2] ,\u_pcf8575/rdata_sub_reg[1] ,\u_pcf8575/rdata_sub_reg[0] }),
    .clk_i(clk_800Khz)
);

endmodule
