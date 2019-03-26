//
// Copyright (c) 2018 A. Theodore Markettos
// All rights reserved.
//
// @BERI_LICENSE_HEADER_START@
//
// Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
// license agreements.  See the NOTICE file distributed with this work for
// additional information regarding copyright ownership.  BERI licenses this
// file to you under the BERI Hardware-Software License, Version 1.0 (the
// "License"); you may not use this file except in compliance with the
// License.  You may obtain a copy of the License at:
//
//   http://www.beri-open-systems.org/legal/license-1-0.txt
//
// Unless required by applicable law or agreed to in writing, Work distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations under the License.
//
// @BERI_LICENSE_HEADER_END@
//
module mercury_aa1_top (
	input		emif_a10_hps_0_pll_ref_clk_clk,
	input		emif_a10_hps_0_oct_oct_rzqin,
	output		emif_a10_hps_0_mem_mem_ck,
	output		emif_a10_hps_0_mem_mem_ck_n,
	output	[16:0]	emif_a10_hps_0_mem_mem_a,
	output		emif_a10_hps_0_mem_mem_act_n,
	output	[1:0]	emif_a10_hps_0_mem_mem_ba,
	output	[1:0]	emif_a10_hps_0_mem_mem_bg,
	output		emif_a10_hps_0_mem_mem_cke,
	output		emif_a10_hps_0_mem_mem_cs_n,
	output		emif_a10_hps_0_mem_mem_odt,
	output		emif_a10_hps_0_mem_mem_reset_n,
	output		emif_a10_hps_0_mem_mem_par,
	input		emif_a10_hps_0_mem_mem_alert_n,
	inout	[4:0]	emif_a10_hps_0_mem_mem_dqs,
	inout 	[4:0]	emif_a10_hps_0_mem_mem_dqs_n,
	inout	[39:0]	emif_a10_hps_0_mem_mem_dq,
	inout	[4:0]	emif_a10_hps_0_mem_mem_dbi_n,
	output 		hps_io_hps_io_phery_emac0_TX_CLK,
	output 		hps_io_hps_io_phery_emac0_TXD0,
	output		hps_io_hps_io_phery_emac0_TXD1,
	output		hps_io_hps_io_phery_emac0_TXD2,
	output		hps_io_hps_io_phery_emac0_TXD3,
	input		hps_io_hps_io_phery_emac0_RX_CTL,
	output		hps_io_hps_io_phery_emac0_TX_CTL,
	input		hps_io_hps_io_phery_emac0_RX_CLK,
	input		hps_io_hps_io_phery_emac0_RXD0,
	input		hps_io_hps_io_phery_emac0_RXD1,
	input		hps_io_hps_io_phery_emac0_RXD2,
	input		hps_io_hps_io_phery_emac0_RXD3,
	inout		hps_io_hps_io_phery_emac0_MDIO,
	output		hps_io_hps_io_phery_emac0_MDC,
	inout		hps_io_hps_io_phery_sdmmc_CMD,
	inout		hps_io_hps_io_phery_sdmmc_D0,
	inout		hps_io_hps_io_phery_sdmmc_D1,
	inout		hps_io_hps_io_phery_sdmmc_D2,
	inout		hps_io_hps_io_phery_sdmmc_D3,
	output		hps_io_hps_io_phery_sdmmc_CCLK,
	inout		hps_io_hps_io_phery_usb0_DATA0,
	inout		hps_io_hps_io_phery_usb0_DATA1,
	inout		hps_io_hps_io_phery_usb0_DATA2,
	inout		hps_io_hps_io_phery_usb0_DATA3,
	inout		hps_io_hps_io_phery_usb0_DATA4,
	inout		hps_io_hps_io_phery_usb0_DATA5,
	inout		hps_io_hps_io_phery_usb0_DATA6,
	inout		hps_io_hps_io_phery_usb0_DATA7,
	input		hps_io_hps_io_phery_usb0_CLK,
	output		hps_io_hps_io_phery_usb0_STP,
	input		hps_io_hps_io_phery_usb0_DIR,
	input		hps_io_hps_io_phery_usb0_NXT,
	output		hps_io_hps_io_phery_spim0_CLK,
	output		hps_io_hps_io_phery_spim0_MOSI,
	input		hps_io_hps_io_phery_spim0_MISO,
	output		hps_io_hps_io_phery_spim0_SS0_N,
	input		hps_io_hps_io_phery_uart1_RX,
	output		hps_io_hps_io_phery_uart1_TX,
	inout		hps_io_hps_io_phery_i2c1_SDA,
	inout		hps_io_hps_io_phery_i2c1_SCL,
	inout		hps_io_hps_io_gpio_gpio1_io0,
	inout		hps_io_hps_io_gpio_gpio1_io1,
	inout		hps_io_hps_io_gpio_gpio1_io8,
	inout		hps_io_hps_io_gpio_gpio1_io9,
	inout		hps_io_hps_io_gpio_gpio1_io22,
	inout		hps_io_hps_io_gpio_gpio1_io23,
	inout		FLASH_SEL_BS1,
	inout		Led3_N_HPS_BS0,
	inout		Led0_N,
	inout		Led1_N,
	output		Led2_N,
	//inout		  hps_io_hps_io_gpio_gpio1_io12,
	//inout		  hps_io_hps_io_gpio_gpio1_io13,
	//inout		  hps_io_hps_io_gpio_gpio1_io14,
	//inout		  hps_io_hps_io_gpio_gpio1_io15,
	//inout		  hps_io_hps_io_gpio_gpio1_io16,
	//inout		  hps_io_hps_io_gpio_gpio1_io17,
	inout		Flash_OE_N,
	inout		PWR_INT_VSEL,
	output		PWR_MGT_VSEL,
	inout		FX3_A0_B3B_L5_U5_N,
	inout		FX3_A1_B3B_L3_T6_P,
	inout		FX3_DQ0_B3B_L8_K4_P,
	inout		FX3_DQ10_B3B_L14_H1_P,
	inout		FX3_DQ11_B3B_L14_G1_N,
	inout		FX3_DQ12_B3B_L10_J3_N,
	inout		FX3_DQ13_B3B_L7_M4_N,
	inout		FX3_DQ14_B3B_L9_N2_P,
	inout		FX3_DQ15_B3B_L1_P3_P,
	inout		FX3_DQ16_B3B_L24_V3_N,
	inout		FX3_DQ17_B3B_L19_U3_P,
	inout		FX3_DQ18_B3B_L23_V2_N,
	inout		FX3_DQ1_B3B_L8_L4_N,
	inout		FX3_DQ20_B3B_L19_U4_N,
	inout		FX3_DQ21_B3B_L23_W2_P,
	inout		FX3_DQ22_B3B_L20_U1_N,
	inout		FX3_DQ23_B3B_L20_V1_P,
	inout		FX3_DQ24_B3B_L13_CLK0_M1_N,
	inout		FX3_DQ25_B3B_L22_V5_P,
	inout		FX3_DQ26_B3B_L21_V7_N,
	inout		FX3_DQ27_B3B_L21_U6_P,
	inout		FX3_DQ28_B3B_L12_CLK1_L3_N,
	inout		FX3_DQ29_B3B_L22_V6_N,
	inout		FX3_DQ2_B3B_L4_R5_N,
	inout		FX3_DQ30_B3B_L12_CLK1_L2_P,
	inout		FX3_DQ31_B3B_L13_CLK0_N1_P,
	inout		FX3_DQ3_B3B_L11_RZQ_K2_P,
	inout		FX3_DQ4_B3B_L17_L1_P,
	inout		FX3_DQ5_B3B_L4_R4_P,
	inout		FX3_DQ6_B3B_L11_J2_N,
	inout		FX3_DQ7_B3B_L17_K1_N,
	inout		FX3_DQ8_B3B_L10_H2_P,
	inout		FX3_DQ9_B3B_L7_M3_P,
	inout		FX3_FLAGA_B3B_L15_R2_P,
	inout		FX3_FLAGB_B3B_L18_T1_P,
	inout		FX3_GPIO23_B3B_L16_T3_N,
	inout		FX3_GPIO25_B3B_L5_T4_P,
	inout		FX3_GPIO26_B3B_L18_R1_N,
	inout		FX3_GPIO27_B3B_L3_T7_N,
	inout		FX3_PKTEND_B3B_L1_P4_N_n,
	inout		FX3_SLCS_B3B_L9_N3_N_n,
	inout		FX3_SLRD_B3B_L15_P2_N_n,
	inout		FX3_SLWR_B3B_L16_T2_P_n,
	inout		FX3_SLOE_n,
	inout		FX3_CLK,
	inout		FX3_RESET_PL_n,
	inout		IO_B2A_L10_AE19_P,
	inout		IO_B2A_L10_AE20_N,
	inout		IO_B2A_L11_AF16_N,
	inout		IO_B2A_L11_RZQ_AG16_P,
	inout		IO_B2A_L12_CLK1_AG14_P,
	inout		IO_B2A_L12_CLK1_AG15_N,
	inout		IO_B2A_L13_CLK0_AA16_N,
	inout		IO_B2A_L13_CLK0_AB16_P,
	inout		IO_B2A_L14_AD19_N,
	inout		IO_B2A_L14_AD20_P,
	inout		IO_B2A_L15_AC16_P,
	inout		IO_B2A_L15_AC17_N,
	inout		IO_B2A_L16_AC18_N,
	inout		IO_B2A_L16_AD18_P,
	inout		IO_B2A_L17_AD17_N,
	inout		IO_B2A_L17_AE17_P,
	inout		IO_B2A_L18_Y15_N,
	inout		IO_B2A_L18_Y16_P,
	inout		IO_B2A_L19_AA11_N,
	input		IO_B2A_L19_AB11_PERST_P_n,
	inout		IO_B2A_L1_AE10_N,
	inout		IO_B2A_L1_AE11_P,
	inout		IO_B2A_L20_AA14_N,
	inout		IO_B2A_L20_AB14_P,
	inout		IO_B2A_L21_AB15_N,
	inout		IO_B2A_L21_AC15_P,
	inout		IO_B2A_L22_AC13_P,
	inout		IO_B2A_L22_CVP_AB13_N,
	inout		IO_B2A_L23_AA12_P,
	inout		IO_B2A_L23_AA13_N,
	inout		IO_B2A_L24_AC11_N,
	inout		IO_B2A_L24_AC12_P,
	inout		IO_B2A_L2_AE14_N,
	inout		IO_B2A_L2_AE15_P,
	inout		IO_B2A_L3_AD15_N,
	inout		IO_B2A_L3_AE16_P,
	inout		IO_B2A_L4_AD12_N,
	inout		IO_B2A_L4_AE12_P,
	inout		IO_B2A_L5_AF11_N,
	inout		IO_B2A_L5_AF12_P,
	inout		IO_B2A_L6_AD13_P,
	inout		IO_B2A_L6_AD14_N,
	inout		IO_B2A_L7_AF19_N,
	inout		IO_B2A_L7_AG18_P,
	inout		IO_B2A_L8_AF17_P,
	inout		IO_B2A_L8_AF18_N,
	inout		IO_B2A_L9_AF13_P,
	inout		IO_B2A_L9_AF14_N,
	inout		IO_B3A_L10_AA2_P,
	inout		IO_B3A_L10_AB3_N,
	inout		IO_B3A_L11_AA4_N,
	inout		IO_B3A_L11_RZQ_AA3_P,
	inout		IO_B3A_L12_CLK1_AA6_P,
	inout		IO_B3A_L12_CLK1_AA7_N,
	inout		IO_B3A_L13_CLK0_AC3_N,
	inout		IO_B3A_L13_CLK0_AD3_P,
	inout		IO_B3A_L14_AE1_P,
	inout		IO_B3A_L14_AF2_N,
	inout		IO_B3A_L15_AC1_P,
	inout		IO_B3A_L15_AC2_N,
	inout		IO_B3A_L16_AD2_N,
	inout		IO_B3A_L16_AE2_P,
	inout		IO_B3A_L17_AF1_N,
	inout		IO_B3A_L17_AG1_P,
	inout		IO_B3A_L18_AF3_N,
	inout		IO_B3A_L18_AG3_P,
	inout		IO_B3A_L19_AH2_P,
	inout		IO_B3A_L19_AH3_N,
	inout		IO_B3A_L1_W4_P,
	inout		IO_B3A_L1_Y4_N,
	inout		IO_B3A_L20_AD4_N,
	inout		IO_B3A_L20_AE4_P,
	inout		IO_B3A_L21_AC6_P,
	inout		IO_B3A_L21_AC7_N,
	inout		IO_B3A_L22_AE6_N,
	inout		IO_B3A_L22_AF6_P,
	inout		IO_B3A_L23_AF4_N,
	inout		IO_B3A_L23_AG4_P,
	inout		IO_B3A_L24_AD5_N,
	inout		IO_B3A_L24_AE5_P,
	inout		IO_B3A_L2_W7_N,
	inout		IO_B3A_L2_W8_P,
	inout		IO_B3A_L3_Y6_N,
	inout		IO_B3A_L3_Y7_P,
	inout		IO_B3A_L4_W5_P,
	inout		IO_B3A_L4_Y5_N,
	inout		IO_B3A_L5_Y1_P,
	inout		IO_B3A_L5_Y2_N,
	inout		IO_B3A_L6_AA8_N,
	inout		IO_B3A_L6_AA9_P,
	inout		IO_B3A_L7_AB4_N,
	inout		IO_B3A_L7_AC5_P,
	inout		IO_B3A_L8_AA1_N,
	inout		IO_B3A_L8_AB1_P,
	inout		IO_B3A_L9_AB5_N,
	inout		IO_B3A_L9_AB6_P,
	inout		IO_B3C_L10_J5_N,
	inout		IO_B3C_L10_K5_P,
	inout		IO_B3C_L11_M6_N,
	inout		IO_B3C_L11_RZQ_M5_P,
	inout		IO_B3C_L12_CLK1_N5_P,
	inout		IO_B3C_L12_CLK1_P5_N,
	inout		IO_B3C_L13_CLK0_G5_P,
	inout		IO_B3C_L13_CLK0_G6_N,
	inout		IO_B3C_L14_B3_P,
	inout		IO_B3C_L14_C3_N,
	inout		IO_B3C_L15_A4_P,
	inout		IO_B3C_L15_B4_N,
	inout		IO_B3C_L16_E4_N,
	inout		IO_B3C_L16_F4_P,
	inout		IO_B3C_L17_A2_P,
	inout		IO_B3C_L17_A3_N,
	inout		IO_B3C_L18_D3_P,
	inout		IO_B3C_L18_D4_N,
	inout		IO_B3C_L19_C2_N,
	inout		IO_B3C_L19_D2_P,
	inout		IO_B3C_L1_H6_P,
	inout		IO_B3C_L1_H7_N,
	inout		IO_B3C_L20_E2_N,
	inout		IO_B3C_L20_F2_P,
	inout		IO_B3C_L21_F3_N,
	inout		IO_B3C_L21_G3_P,
	inout		IO_B3C_L22_H3_P,
	inout		IO_B3C_L22_J4_N,
	inout		IO_B3C_L23_B1_N,
	inout		IO_B3C_L23_C1_P,
	inout		IO_B3C_L24_E1_N,
	inout		IO_B3C_L24_F1_P,
	inout		IO_B3C_L2_N7_P,
	inout		IO_B3C_L2_N8_N,
	inout		IO_B3C_L3_K6_N,
	inout		IO_B3C_L3_L6_P,
	inout		IO_B3C_L4_G4_P,
	inout		IO_B3C_L4_H5_N,
	inout		IO_B3C_L5_J7_N,
	inout		IO_B3C_L5_K7_P,
	inout		IO_B3C_L6_L7_P,
	inout		IO_B3C_L6_M8_N,
	inout		IO_B3C_L7_P8_N,
	inout		IO_B3C_L7_P9_P,
	inout		IO_B3C_L8_N6_P,
	inout		IO_B3C_L8_P7_N,
	inout		IO_B3C_L9_R6_P,
	inout		IO_B3C_L9_R7_N,
	inout		IO_B3D_L10_H8_P,
	inout		IO_B3D_L10_J8_N,
	inout		IO_B3D_L11_F7_N,
	inout		IO_B3D_L11_RZQ_F6_P,
	inout		IO_B3D_L12_CLK1_F8_N,
	inout		IO_B3D_L12_CLK1_G8_P,
	inout		IO_B3D_L13_CLK0_C7_P,
	inout		IO_B3D_L13_CLK0_D7_N,
	inout		IO_B3D_L14_A6_P,
	inout		IO_B3D_L14_A7_N,
	inout		IO_B3D_L15_E6_P,
	inout		IO_B3D_L15_E7_N,
	inout		IO_B3D_L16_C5_P,
	inout		IO_B3D_L16_C6_N,
	inout		IO_B3D_L17_B5_P,
	inout		IO_B3D_L17_B6_N,
	inout		IO_B3D_L18_D5_P,
	inout		IO_B3D_L18_E5_N,
	inout		IO_B3D_L7_J9_N,
	inout		IO_B3D_L7_K9_P,
	inout		IO_B3D_L8_F9_P,
	inout		IO_B3D_L8_G9_N,
	inout		IO_B3D_L9_L8_N,
	inout		IO_B3D_L9_L9_P,
	input		[0:0] PCIE_RX_p,
	output	[0:0] PCIE_TX_p,
	input		PCIE_REFCLK_p
);

	reg [15:0]	RstCnt;
	reg [23:0]	LedCount;
	reg 		Rst;
	wire		h2f_reset_n;
	wire     clk200;
	wire     clk100ext;			// 100MHz external clock generator on plugin module
	wire     clkusr;				// 100MHz transceiver configuration clock

    system u0 (
		.clk100_clk                       (clk100ext),                    // main I/O clock
		.clk200_clk                       (clk200),                       //                     clk200.clk
		.reset_reset_n                    (!Rst),
		.emif_a10_hps_0_mem_mem_ck        (emif_a10_hps_0_mem_mem_ck),        //         emif_a10_hps_0_mem.mem_ck
		.emif_a10_hps_0_mem_mem_ck_n      (emif_a10_hps_0_mem_mem_ck_n),      //                           .mem_ck_n
		.emif_a10_hps_0_mem_mem_a         (emif_a10_hps_0_mem_mem_a),         //                           .mem_a
		.emif_a10_hps_0_mem_mem_act_n     (emif_a10_hps_0_mem_mem_act_n),     //                           .mem_act_n
		.emif_a10_hps_0_mem_mem_ba        (emif_a10_hps_0_mem_mem_ba),        //                           .mem_ba
		.emif_a10_hps_0_mem_mem_bg        (emif_a10_hps_0_mem_mem_bg),        //                           .mem_bg
		.emif_a10_hps_0_mem_mem_cke       (emif_a10_hps_0_mem_mem_cke),       //                           .mem_cke
		.emif_a10_hps_0_mem_mem_cs_n      (emif_a10_hps_0_mem_mem_cs_n),      //                           .mem_cs_n
		.emif_a10_hps_0_mem_mem_odt       (emif_a10_hps_0_mem_mem_odt),       //                           .mem_odt
		.emif_a10_hps_0_mem_mem_reset_n   (emif_a10_hps_0_mem_mem_reset_n),   //                           .mem_reset_n
		.emif_a10_hps_0_mem_mem_par       (emif_a10_hps_0_mem_mem_par),       //                           .mem_par
		.emif_a10_hps_0_mem_mem_alert_n   (emif_a10_hps_0_mem_mem_alert_n),   //                           .mem_alert_n
		.emif_a10_hps_0_mem_mem_dqs       (emif_a10_hps_0_mem_mem_dqs),       //                           .mem_dqs
		.emif_a10_hps_0_mem_mem_dqs_n     (emif_a10_hps_0_mem_mem_dqs_n),     //                           .mem_dqs_n
		.emif_a10_hps_0_mem_mem_dq        (emif_a10_hps_0_mem_mem_dq),        //                           .mem_dq
		.emif_a10_hps_0_mem_mem_dbi_n     (emif_a10_hps_0_mem_mem_dbi_n),     //                           .mem_dbi_n
		.emif_a10_hps_0_oct_oct_rzqin     (emif_a10_hps_0_oct_oct_rzqin),     //         emif_a10_hps_0_oct.oct_rzqin
		.emif_a10_hps_0_pll_ref_clk_clk   (emif_a10_hps_0_pll_ref_clk_clk),   // emif_a10_hps_0_pll_ref_clk.clk
		.hps_io_hps_io_phery_emac0_TX_CLK (hps_io_hps_io_phery_emac0_TX_CLK), //                     hps_io.hps_io_phery_emac0_TX_CLK
		.hps_io_hps_io_phery_emac0_TXD0   (hps_io_hps_io_phery_emac0_TXD0),   //                           .hps_io_phery_emac0_TXD0
		.hps_io_hps_io_phery_emac0_TXD1   (hps_io_hps_io_phery_emac0_TXD1),   //                           .hps_io_phery_emac0_TXD1
		.hps_io_hps_io_phery_emac0_TXD2   (hps_io_hps_io_phery_emac0_TXD2),   //                           .hps_io_phery_emac0_TXD2
		.hps_io_hps_io_phery_emac0_TXD3   (hps_io_hps_io_phery_emac0_TXD3),   //                           .hps_io_phery_emac0_TXD3
		.hps_io_hps_io_phery_emac0_RX_CTL (hps_io_hps_io_phery_emac0_RX_CTL), //                           .hps_io_phery_emac0_RX_CTL
		.hps_io_hps_io_phery_emac0_TX_CTL (hps_io_hps_io_phery_emac0_TX_CTL), //                           .hps_io_phery_emac0_TX_CTL
		.hps_io_hps_io_phery_emac0_RX_CLK (hps_io_hps_io_phery_emac0_RX_CLK), //                           .hps_io_phery_emac0_RX_CLK
		.hps_io_hps_io_phery_emac0_RXD0   (hps_io_hps_io_phery_emac0_RXD0),   //                           .hps_io_phery_emac0_RXD0
		.hps_io_hps_io_phery_emac0_RXD1   (hps_io_hps_io_phery_emac0_RXD1),   //                           .hps_io_phery_emac0_RXD1
		.hps_io_hps_io_phery_emac0_RXD2   (hps_io_hps_io_phery_emac0_RXD2),   //                           .hps_io_phery_emac0_RXD2
		.hps_io_hps_io_phery_emac0_RXD3   (hps_io_hps_io_phery_emac0_RXD3),   //                           .hps_io_phery_emac0_RXD3
		.hps_io_hps_io_phery_emac0_MDIO   (hps_io_hps_io_phery_emac0_MDIO),   //                           .hps_io_phery_emac0_MDIO
		.hps_io_hps_io_phery_emac0_MDC    (hps_io_hps_io_phery_emac0_MDC),    //                           .hps_io_phery_emac0_MDC
		.hps_io_hps_io_phery_sdmmc_CMD    (hps_io_hps_io_phery_sdmmc_CMD),    //                           .hps_io_phery_sdmmc_CMD
		.hps_io_hps_io_phery_sdmmc_D0     (hps_io_hps_io_phery_sdmmc_D0),     //                           .hps_io_phery_sdmmc_D0
		.hps_io_hps_io_phery_sdmmc_D1     (hps_io_hps_io_phery_sdmmc_D1),     //                           .hps_io_phery_sdmmc_D1
		.hps_io_hps_io_phery_sdmmc_D2     (hps_io_hps_io_phery_sdmmc_D2),     //                           .hps_io_phery_sdmmc_D2
		.hps_io_hps_io_phery_sdmmc_D3     (hps_io_hps_io_phery_sdmmc_D3),     //                           .hps_io_phery_sdmmc_D3
		.hps_io_hps_io_phery_sdmmc_CCLK   (hps_io_hps_io_phery_sdmmc_CCLK),   //                           .hps_io_phery_sdmmc_CCLK
		.hps_io_hps_io_phery_usb0_DATA0   (hps_io_hps_io_phery_usb0_DATA0),   //                           .hps_io_phery_usb0_DATA0
		.hps_io_hps_io_phery_usb0_DATA1   (hps_io_hps_io_phery_usb0_DATA1),   //                           .hps_io_phery_usb0_DATA1
		.hps_io_hps_io_phery_usb0_DATA2   (hps_io_hps_io_phery_usb0_DATA2),   //                           .hps_io_phery_usb0_DATA2
		.hps_io_hps_io_phery_usb0_DATA3   (hps_io_hps_io_phery_usb0_DATA3),   //                           .hps_io_phery_usb0_DATA3
		.hps_io_hps_io_phery_usb0_DATA4   (hps_io_hps_io_phery_usb0_DATA4),   //                           .hps_io_phery_usb0_DATA4
		.hps_io_hps_io_phery_usb0_DATA5   (hps_io_hps_io_phery_usb0_DATA5),   //                           .hps_io_phery_usb0_DATA5
		.hps_io_hps_io_phery_usb0_DATA6   (hps_io_hps_io_phery_usb0_DATA6),   //                           .hps_io_phery_usb0_DATA6
		.hps_io_hps_io_phery_usb0_DATA7   (hps_io_hps_io_phery_usb0_DATA7),   //                           .hps_io_phery_usb0_DATA7
		.hps_io_hps_io_phery_usb0_CLK     (hps_io_hps_io_phery_usb0_CLK),     //                           .hps_io_phery_usb0_CLK
		.hps_io_hps_io_phery_usb0_STP     (hps_io_hps_io_phery_usb0_STP),     //                           .hps_io_phery_usb0_STP
		.hps_io_hps_io_phery_usb0_DIR     (hps_io_hps_io_phery_usb0_DIR),     //                           .hps_io_phery_usb0_DIR
		.hps_io_hps_io_phery_usb0_NXT     (hps_io_hps_io_phery_usb0_NXT),     //                           .hps_io_phery_usb0_NXT
		.hps_io_hps_io_phery_spim0_CLK    (hps_io_hps_io_phery_spim0_CLK),    //                           .hps_io_phery_spim0_CLK
		.hps_io_hps_io_phery_spim0_MOSI   (hps_io_hps_io_phery_spim0_MOSI),   //                           .hps_io_phery_spim0_MOSI
		.hps_io_hps_io_phery_spim0_MISO   (hps_io_hps_io_phery_spim0_MISO),   //                           .hps_io_phery_spim0_MISO
		.hps_io_hps_io_phery_spim0_SS0_N  (hps_io_hps_io_phery_spim0_SS0_N),  //                           .hps_io_phery_spim0_SS0_N
		.hps_io_hps_io_phery_uart1_RX     (hps_io_hps_io_phery_uart1_RX),     //                           .hps_io_phery_uart1_RX
		.hps_io_hps_io_phery_uart1_TX     (hps_io_hps_io_phery_uart1_TX),     //                           .hps_io_phery_uart1_TX
		.hps_io_hps_io_phery_i2c1_SDA     (hps_io_hps_io_phery_i2c1_SDA),     //                           .hps_io_phery_i2c1_SDA
		.hps_io_hps_io_phery_i2c1_SCL     (hps_io_hps_io_phery_i2c1_SCL),     //                           .hps_io_phery_i2c1_SCL
		.hps_io_hps_io_gpio_gpio2_io6     (FLASH_SEL_BS1),     //                           .hps_io_gpio_gpio2_io6
		.hps_io_hps_io_gpio_gpio2_io7     (Led3_N_HPS_BS0),     //                           .hps_io_gpio_gpio2_io7
		.hps_io_hps_io_gpio_gpio1_io0     (hps_io_hps_io_gpio_gpio1_io0),     //                           .hps_io_gpio_gpio1_io0
		.hps_io_hps_io_gpio_gpio1_io1     (hps_io_hps_io_gpio_gpio1_io1),     //                           .hps_io_gpio_gpio1_io1
		.hps_io_hps_io_gpio_gpio1_io2     (Led0_N),     //                           .hps_io_gpio_gpio1_io2
		.hps_io_hps_io_gpio_gpio1_io3     (Led1_N),     //                           .hps_io_gpio_gpio1_io3
		.hps_io_hps_io_gpio_gpio1_io4     (PWR_INT_VSEL),     //                           .hps_io_gpio_gpio1_io4
		.hps_io_hps_io_gpio_gpio1_io5     (Flash_OE_N),     //                           .hps_io_gpio_gpio1_io5
		.hps_io_hps_io_gpio_gpio1_io8     (hps_io_hps_io_gpio_gpio1_io8),     //                           .hps_io_gpio_gpio1_io8
		.hps_io_hps_io_gpio_gpio1_io9     (hps_io_hps_io_gpio_gpio1_io9),     //                           .hps_io_gpio_gpio1_io9
		.hps_io_hps_io_gpio_gpio1_io22    (hps_io_hps_io_gpio_gpio1_io22),    //                           .hps_io_gpio_gpio1_io22
		.hps_io_hps_io_gpio_gpio1_io23    (hps_io_hps_io_gpio_gpio1_io23),     //                           .hps_io_gpio_gpio1_io23

        .streams_0_pcie_ep_0_hip_serial_rx_in0   (PCIE_RX_p[0]),   // streams_0_pcie_ep_0_hip_serial.rx_in0
        .streams_0_pcie_ep_0_hip_serial_tx_out0  (PCIE_TX_p[0]),  //                               .tx_out0
        .streams_0_pcie_ep_0_pcie_rstn_npor      (!Rst),      //  streams_0_pcie_ep_0_pcie_rstn.npor
        .streams_0_pcie_ep_0_pcie_rstn_pin_perst (IO_B2A_L19_AB11_PERST_P_n), //                               .pin_perst
        .streams_0_pcie_ep_0_refclk_clk          (PCIE_REFCLK_p),           //     streams_0_pcie_ep_0_refclk.clk
       .reset_bridge_0_out_reset_reset_n        (h2f_reset_n),         //       reset_bridge_0_out_reset.reset_n
 
		);

    assign PERST_n = IO_B2A_L19_AB11_PERST_P_n;
    //assign IO_B2A_L18_Y16_P = PCIE_REFCLK_p;
	 assign clkusr = IO_B2A_L18_Y15_N;
	 assign clk100ext = IO_B2A_L12_CLK1_AG15_N;


    always @(posedge clk200) begin
	if (!RstCnt == 0) begin
		Rst <= 0;
	end else begin
		Rst <= 1;
		RstCnt <= RstCnt + 1;
	end
    end


    always @(posedge clk100ext) begin
	if (Rst == 1) begin
		LedCount <= 0;
	end else begin
		LedCount <= LedCount + 1;
	end
    end

    assign Led2_N = !LedCount[23];


	assign FX3_A0_B3B_L5_U5_N	= 1'bz;
	assign FX3_A1_B3B_L3_T6_P	= 1'bz;
	assign FX3_FLAGA_B3B_L15_R2_P	= 1'bz;
	assign FX3_FLAGB_B3B_L18_T1_P	= 1'bz;
	assign FX3_GPIO23_B3B_L16_T3_N	= 1'bz;
	assign FX3_GPIO25_B3B_L5_T4_P	= 1'bz;
	assign FX3_GPIO26_B3B_L18_R1_N	= 1'bz;
	assign FX3_GPIO27_B3B_L3_T7_N	= 1'bz;
	assign FX3_PKTEND_B3B_L1_P4_N_n	= 1'bz;
	assign FX3_SLCS_B3B_L9_N3_N_n	= 1'bz;
	assign FX3_SLRD_B3B_L15_P2_N_n	= 1'bz;
	assign FX3_SLWR_B3B_L16_T2_P_n	= 1'bz;
	assign FX3_SLOE_n		= 1'bz;
	assign FX3_CLK			= 1'bz;
	assign FX3_RESET_PL_n		= 1'b1;
//	assign PWR_MGT_VSEL		= 1'b0; // 0.9V = normal
	assign PWR_MGT_VSEL 		= 1'bz; // 1.03V = high speed

endmodule
