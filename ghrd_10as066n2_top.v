module ghrd_10as066n2_top (
  // FPGA peripherals ports
  input  wire [3:0]    fpga_dipsw_pio,                   
  output wire [3:0]    fpga_led_pio,                     
  input  wire [3:0]    fpga_button_pio,  
  // HPS memory controller ports
  // DDR4 single rank -2133 device
  output wire          hps_memory_mem_act_n,
  output wire          hps_memory_mem_bg,
  output wire          hps_memory_mem_par,
  input  wire          hps_memory_mem_alert_n,
  inout  wire [4-1:0]  hps_memory_mem_dbi_n,
  output wire [16:0]   hps_memory_mem_a,                           
  output wire [1:0]    hps_memory_mem_ba,
  output wire          hps_memory_mem_ck,                          
  output wire          hps_memory_mem_ck_n,                        
  output wire          hps_memory_mem_cke,                         
  output wire          hps_memory_mem_cs_n,                                            
  output wire          hps_memory_mem_reset_n,                     
  inout  wire [32-1:0] hps_memory_mem_dq,                          
  inout  wire [4-1:0]  hps_memory_mem_dqs,                         
  inout  wire [4-1:0]  hps_memory_mem_dqs_n,                       
  output wire          hps_memory_mem_odt,                                          
  input  wire          hps_memory_oct_rzqin,     
  input  wire          emif_ref_clk,  
  // HPS peripherals
  output wire          hps_emac0_TX_CLK,   
  output wire          hps_emac0_TXD0,     
  output wire          hps_emac0_TXD1,     
  output wire          hps_emac0_TXD2,     
  output wire          hps_emac0_TXD3,     
  input  wire          hps_emac0_RXD0,     
  inout  wire          hps_emac0_MDIO,     
  output wire          hps_emac0_MDC,      
  input  wire          hps_emac0_RX_CTL,   
  output wire          hps_emac0_TX_CTL,   
  input  wire          hps_emac0_RX_CLK,   
  input  wire          hps_emac0_RXD1,     
  input  wire          hps_emac0_RXD2,     
  input  wire          hps_emac0_RXD3, 
  inout  wire          hps_usb0_D0,        
  inout  wire          hps_usb0_D1,        
  inout  wire          hps_usb0_D2,        
  inout  wire          hps_usb0_D3,        
  inout  wire          hps_usb0_D4,        
  inout  wire          hps_usb0_D5,        
  inout  wire          hps_usb0_D6,        
  inout  wire          hps_usb0_D7,        
  input  wire          hps_usb0_CLK,       
  output wire          hps_usb0_STP,       
  input  wire          hps_usb0_DIR,       
  input  wire          hps_usb0_NXT,   
  output wire          hps_spim1_CLK,
  output wire          hps_spim1_MOSI,
  input  wire          hps_spim1_MISO,
  output wire          hps_spim1_SS0_N,
  output wire          hps_spim1_SS1_N,
  input  wire          hps_uart1_RX,       
  output wire          hps_uart1_TX,       
//  inout  wire          hps_i2c1_SDA,       
//  inout  wire          hps_i2c1_SCL,       
  inout  wire          hps_sdio_CMD,
  output wire          hps_sdio_CLK,
  inout  wire          hps_sdio_D0,
  inout  wire          hps_sdio_D1,
  inout  wire          hps_sdio_D2,
  inout  wire          hps_sdio_D3,
  inout  wire          hps_sdio_D4,
  inout  wire          hps_sdio_D5,
  inout  wire          hps_sdio_D6,
  inout  wire          hps_sdio_D7,
  output wire          hps_trace_CLK,      
  output wire          hps_trace_D0,       
  output wire          hps_trace_D1,       
  output wire          hps_trace_D2,       
  output wire          hps_trace_D3,         
  inout  wire          hps_gpio_GPIO14,    
  inout  wire          hps_gpio_GPIO05,
  inout  wire          hps_gpio_GPIO16,    
  inout  wire          hps_gpio_GPIO17, 
  // Other HPS-FPGA peripherals
  input		 wire	      pcie_ep_refclk_100,
  input	    wire 		  pcie_ep_rx_in0,
  /*input	    wire 		  pcie_ep_rx_in1,
  input	    wire 		  pcie_ep_rx_in2,
  input	    wire 		  pcie_ep_rx_in3,
  */output	wire 		  pcie_ep_tx_out0,
  /*output	wire 		  pcie_ep_tx_out1,
  output	wire 		  pcie_ep_tx_out2,
  output	wire 		  pcie_ep_tx_out3,
  */input	    wire 		  pcie_ep_perst,
  //output    wire		  pcie_perstn_out,
  // FPGA clock and reset
  input  wire          fpga_clk_100,
  input  wire          fpga_reset_n  
);

// internal wires and registers declaration
  wire [3:0]  fpga_debounced_buttons;
  wire [3:0]  fpga_led_internal;
  wire [27:0] stm_hw_events;
  wire        hps_fpga_reset;
  wire [2:0]  hps_reset_req;
  wire        hps_cold_reset;
  wire        hps_warm_reset;
  wire        hps_debug_reset;

wire	pcie_npor_npor;
wire coreclk_fanout_clk;
wire coreclk_fanout_reset_n;
wire [4:0]	hps_pcie_a10_hip_avmm_hip_pipe_sim_ltssmstate;
wire [4:0] hps_pcie_a10_hip_avmm_hip_status_ltssmstate;
//wire pcie_ep_perst;

//assign pcie_ep_perst = 1'b0;

// connection of internal logics
  assign fpga_led_pio     = fpga_led_internal;
  assign stm_hw_events    = {{16{1'b0}}, fpga_dipsw_pio, fpga_led_internal, fpga_debounced_buttons};
  assign pcie_npor_npor = ~hps_fpga_reset & pcie_ep_perst & fpga_reset_n;
 
  //registers
  reg         L0_led;        // link status ltssm=0xf
  reg         alive_led;     // heart beat 
  reg  [1:0]  linkwidth_led; // link width, 1=x1, 2=x4, skipped x2 and ignored x8
  reg  [25:0] alive_cnt;
  
  
  // connection of internal logics
  //assign pcie_perstn_out = 1'b1;
//  assign fpga_led_pio = {L0_led, alive_led, linkwidth_led[1], ~fpga_led_internal};
  //assign sync_pcie_por_n = ~sync_pcie_por; potentailly redundant signal
  
  // logic for LED display derivation
  always @(posedge coreclk_fanout_clk or negedge coreclk_fanout_reset_n) begin // pcie_refclk_clk to be modified with coreclk_out from PCIe IP later
    if (!coreclk_fanout_reset_n) begin
      L0_led        <= 1'b0;      
      alive_led     <= 1'b0;   
      linkwidth_led <= 2'h0;
      alive_cnt     <= 26'd0;
      end
    else begin
      L0_led        <= ~(hps_pcie_a10_hip_avmm_hip_status_ltssmstate[3:0] == 4'hf);
      alive_led     <= alive_cnt[25];   
      linkwidth_led <= {alive_cnt[24],alive_cnt[21]}; // tentatively assign linkwidth_led as flashing display as PCIe HIP has yet exposed the tl_cfg_sts signal
      alive_cnt     <= alive_cnt + 1;   
      end
    end

// SoC sub-system module
ghrd_10as066n2 soc_inst (
  .f2h_stm_hw_events_stm_hwevents                (stm_hw_events),                   
  .pio_dipsw_external_connection_export          (fpga_dipsw_pio),    
  .pio_led_external_connection_in_port           (fpga_led_internal),
  .pio_led_external_connection_out_port          (fpga_led_internal),                   
  .pio_button_external_connection_export         (fpga_debounced_buttons),    
  .hps_io_hps_io_phery_emac0_TX_CLK              (hps_emac0_TX_CLK), 
  .hps_io_hps_io_phery_emac0_TXD0                (hps_emac0_TXD0),   
  .hps_io_hps_io_phery_emac0_TXD1                (hps_emac0_TXD1),   
  .hps_io_hps_io_phery_emac0_TXD2                (hps_emac0_TXD2),   
  .hps_io_hps_io_phery_emac0_TXD3                (hps_emac0_TXD3),   
  .hps_io_hps_io_phery_emac0_MDIO                (hps_emac0_MDIO),   
  .hps_io_hps_io_phery_emac0_MDC                 (hps_emac0_MDC),    
  .hps_io_hps_io_phery_emac0_RX_CTL              (hps_emac0_RX_CTL), 
  .hps_io_hps_io_phery_emac0_TX_CTL              (hps_emac0_TX_CTL), 
  .hps_io_hps_io_phery_emac0_RX_CLK              (hps_emac0_RX_CLK), 
  .hps_io_hps_io_phery_emac0_RXD0                (hps_emac0_RXD0),   
  .hps_io_hps_io_phery_emac0_RXD1                (hps_emac0_RXD1),   
  .hps_io_hps_io_phery_emac0_RXD2                (hps_emac0_RXD2),   
  .hps_io_hps_io_phery_emac0_RXD3                (hps_emac0_RXD3),
  .hps_io_hps_io_phery_usb0_DATA0                (hps_usb0_D0),      
  .hps_io_hps_io_phery_usb0_DATA1                (hps_usb0_D1),      
  .hps_io_hps_io_phery_usb0_DATA2                (hps_usb0_D2),      
  .hps_io_hps_io_phery_usb0_DATA3                (hps_usb0_D3),      
  .hps_io_hps_io_phery_usb0_DATA4                (hps_usb0_D4),      
  .hps_io_hps_io_phery_usb0_DATA5                (hps_usb0_D5),      
  .hps_io_hps_io_phery_usb0_DATA6                (hps_usb0_D6),      
  .hps_io_hps_io_phery_usb0_DATA7                (hps_usb0_D7),      
  .hps_io_hps_io_phery_usb0_CLK                  (hps_usb0_CLK),     
  .hps_io_hps_io_phery_usb0_STP                  (hps_usb0_STP),     
  .hps_io_hps_io_phery_usb0_DIR                  (hps_usb0_DIR),     
  .hps_io_hps_io_phery_usb0_NXT                  (hps_usb0_NXT),   
  .hps_io_hps_io_phery_spim1_CLK                 (hps_spim1_CLK),
  .hps_io_hps_io_phery_spim1_MOSI                (hps_spim1_MOSI),
  .hps_io_hps_io_phery_spim1_MISO                (hps_spim1_MISO),
  .hps_io_hps_io_phery_spim1_SS0_N               (hps_spim1_SS0_N),
  .hps_io_hps_io_phery_spim1_SS1_N               (hps_spim1_SS1_N),
  .hps_io_hps_io_phery_uart1_RX                  (hps_uart1_RX),     
  .hps_io_hps_io_phery_uart1_TX                  (hps_uart1_TX),  
  .hps_io_hps_io_phery_sdmmc_CMD                 (hps_sdio_CMD),     
  .hps_io_hps_io_phery_sdmmc_D0                  (hps_sdio_D0),      
  .hps_io_hps_io_phery_sdmmc_D1                  (hps_sdio_D1),      
  .hps_io_hps_io_phery_sdmmc_D2                  (hps_sdio_D2),      
  .hps_io_hps_io_phery_sdmmc_D3                  (hps_sdio_D3),      
  .hps_io_hps_io_phery_sdmmc_D4                  (hps_sdio_D4),
  .hps_io_hps_io_phery_sdmmc_D5                  (hps_sdio_D5),
  .hps_io_hps_io_phery_sdmmc_D6                  (hps_sdio_D6),
  .hps_io_hps_io_phery_sdmmc_D7                  (hps_sdio_D7),
  .hps_io_hps_io_phery_sdmmc_CCLK                (hps_sdio_CLK),   
  .hps_io_hps_io_phery_trace_CLK                 (hps_trace_CLK),
  .hps_io_hps_io_phery_trace_D0                  (hps_trace_D0),
  .hps_io_hps_io_phery_trace_D1                  (hps_trace_D1),
  .hps_io_hps_io_phery_trace_D2                  (hps_trace_D2),
  .hps_io_hps_io_phery_trace_D3                  (hps_trace_D3),
  .hps_io_hps_io_gpio_gpio1_io5                  (hps_gpio_GPIO05),  
  .hps_io_hps_io_gpio_gpio1_io14                 (hps_gpio_GPIO14),
  .hps_io_hps_io_gpio_gpio1_io16                 (hps_gpio_GPIO16),
  .hps_io_hps_io_gpio_gpio1_io17                 (hps_gpio_GPIO17),
//  .hps_io_hps_io_phery_i2c1_SDA                  (hps_i2c1_SDA),
//  .hps_io_hps_io_phery_i2c1_SCL                  (hps_i2c1_SCL),  
  .h2f_gp_gp_in                                  (32'd0),
  .h2f_gp_gp_out                                 (),
  .emif_a10_hps_0_mem_conduit_end_mem_ck         (hps_memory_mem_ck),     
  .emif_a10_hps_0_mem_conduit_end_mem_ck_n       (hps_memory_mem_ck_n),   
  .emif_a10_hps_0_mem_conduit_end_mem_a          (hps_memory_mem_a),      
  .emif_a10_hps_0_mem_conduit_end_mem_act_n      (hps_memory_mem_act_n),
  .emif_a10_hps_0_mem_conduit_end_mem_ba         (hps_memory_mem_ba), 
  .emif_a10_hps_0_mem_conduit_end_mem_bg         (hps_memory_mem_bg),
  .emif_a10_hps_0_mem_conduit_end_mem_cke        (hps_memory_mem_cke),    
  .emif_a10_hps_0_mem_conduit_end_mem_cs_n       (hps_memory_mem_cs_n),   
  .emif_a10_hps_0_mem_conduit_end_mem_odt        (hps_memory_mem_odt),    
  .emif_a10_hps_0_mem_conduit_end_mem_reset_n    (hps_memory_mem_reset_n),
  .emif_a10_hps_0_mem_conduit_end_mem_par        (hps_memory_mem_par), 
  .emif_a10_hps_0_mem_conduit_end_mem_alert_n    (hps_memory_mem_alert_n), 
  .emif_a10_hps_0_mem_conduit_end_mem_dqs        (hps_memory_mem_dqs),    
  .emif_a10_hps_0_mem_conduit_end_mem_dqs_n      (hps_memory_mem_dqs_n),  
  .emif_a10_hps_0_mem_conduit_end_mem_dq         (hps_memory_mem_dq), 
  .emif_a10_hps_0_mem_conduit_end_mem_dbi_n      (hps_memory_mem_dbi_n), 
  .emif_a10_hps_0_oct_conduit_end_oct_rzqin      (hps_memory_oct_rzqin), 
  .emif_a10_hps_0_pll_ref_clk_clock_sink_clk     (emif_ref_clk),


        .pcie_tlp_buffer_pcie_ep_0_pcie_rstn_npor             (pcie_npor_npor),             //             pcie_tlp_buffer_pcie_rstn.npor
        .pcie_tlp_buffer_pcie_ep_0_pcie_rstn_pin_perst        (pcie_ep_perst),        //                                      .pin_perst
        .pcie_tlp_buffer_pcie_ep_0_hip_serial_rx_in0          (pcie_ep_rx_in0),          //            pcie_tlp_buffer_hip_serial.rx_in0
/*        .pcie_tlp_buffer_pcie_ep_0_hip_serial_rx_in1          (pcie_ep_rx_in1),          //                                      .rx_in1
        .pcie_tlp_buffer_pcie_ep_0_hip_serial_rx_in2          (pcie_ep_rx_in2),          //                                      .rx_in2
        .pcie_tlp_buffer_pcie_ep_0_hip_serial_rx_in3          (pcie_ep_rx_in3),          //                                      .rx_in3
*/        .pcie_tlp_buffer_pcie_ep_0_hip_serial_tx_out0         (pcie_ep_tx_out0),         //                                      .tx_out0
/*        .pcie_tlp_buffer_pcie_ep_0_hip_serial_tx_out1         (pcie_ep_tx_out1),         //                                      .tx_out1
        .pcie_tlp_buffer_pcie_ep_0_hip_serial_tx_out2         (pcie_ep_tx_out2),         //                                      .tx_out2
        .pcie_tlp_buffer_pcie_ep_0_hip_serial_tx_out3         (pcie_ep_tx_out3),         //                                      .tx_out3
*/        .pcie_tlp_buffer_pcie_ep_0_refclk_clk                 (pcie_ep_refclk_100),                  //                pcie_tlp_buffer_refclk.clk
/*
  
   //PCIe
  .pcie_0_pcie_a10_hip_avmm_refclk_clk (pcie_ep_refclk_100),
  .pcie_0_coreclk_fanout_clk_clk	(coreclk_fanout_clk),                   
  .pcie_0_coreclk_fanout_clk_reset_reset_n	(coreclk_fanout_reset_n), 
  //.iopll_0_refclk_clk	(coreclk_fanout_clk),
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_sim_pipe_pclk_in	(1'b0),         
  .pcie_0_pcie_a10_hip_avmm_hip_ctrl_test_in        ( 32'h0 ),
  .pcie_0_pcie_a10_hip_avmm_hip_ctrl_simu_mode_pipe ( 0 ),
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_phystatus0	(1'b0),                 
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_phystatus1	(1'b0),                 
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_phystatus2	(1'b0),                 
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_phystatus3	(1'b0),  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdata0	(32'b0),                   
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdata1	(32'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdata2	(32'b0),                    
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdata3	(32'b0),                            
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdatak0	(4'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdatak1	(4'b0),                   
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdatak2	(4'b0),                   
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdatak3	(4'b0),                                    
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxelecidle0	(1'b0),                
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxelecidle1	(1'b0),                
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxelecidle2	(1'b0),                
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxelecidle3	(1'b0),                              
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxstatus0	(3'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxstatus1	(3'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxstatus2	(3'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxstatus3	(3'b0),                               
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxvalid0	(1'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxvalid1	(1'b0),                
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxvalid2	(1'b0),                 
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxvalid3	(1'b0),                                    
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdataskip0	(1'b0),                
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdataskip1	(1'b0),              
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdataskip2	(1'b0),               
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxdataskip3	(1'b0),                       
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxblkst0	(1'b0),                   
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxblkst1	(1'b0),            
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxblkst2	(1'b0),                   
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxblkst3	(1'b0),
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxsynchd0	(2'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxsynchd1	(2'b0),                 
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxsynchd2	(2'b0),                  
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_rxsynchd3	(2'b0),                                 
  .pcie_0_pcie_a10_hip_avmm_hip_serial_rx_in0       ( pcie_ep_rx_in0 ),
  .pcie_0_pcie_a10_hip_avmm_hip_serial_rx_in1       ( pcie_ep_rx_in1 ),
  .pcie_0_pcie_a10_hip_avmm_hip_serial_rx_in2       ( pcie_ep_rx_in2 ),
  .pcie_0_pcie_a10_hip_avmm_hip_serial_rx_in3       ( pcie_ep_rx_in3 ),
  .pcie_0_pcie_a10_hip_avmm_hip_serial_tx_out0      ( pcie_ep_tx_out0 ),
  .pcie_0_pcie_a10_hip_avmm_hip_serial_tx_out1      ( pcie_ep_tx_out1 ),
  .pcie_0_pcie_a10_hip_avmm_hip_serial_tx_out2      ( pcie_ep_tx_out2 ),
  .pcie_0_pcie_a10_hip_avmm_hip_serial_tx_out3      ( pcie_ep_tx_out3 ), 
  .pcie_0_pcie_a10_hip_avmm_hip_pipe_sim_ltssmstate	(hps_pcie_a10_hip_avmm_hip_pipe_sim_ltssmstate),
  .pcie_0_pcie_a10_hip_avmm_hip_status_ltssmstate	(hps_pcie_a10_hip_avmm_hip_status_ltssmstate),
  .pcie_0_pcie_a10_hip_avmm_npor_npor	(pcie_npor_npor),
  .pcie_0_pcie_a10_hip_avmm_npor_pin_perst	(pcie_ep_perst),
*/  
  
  .clk_100_clk                                   (fpga_clk_100),
  .reset_reset_n                                 (fpga_reset_n),
  .hps_fpga_reset_reset                          (hps_fpga_reset),
  .issp_hps_resets_source                        (hps_reset_req),
  .f2h_cold_reset_req_reset_n                    (~hps_cold_reset),
  .f2h_warm_reset_req_reset_n                    (~hps_warm_reset),
  .f2h_debug_reset_req_reset_n                   (~hps_debug_reset)
);  

// Debounce logic to clean out glitches within 1ms
debounce debounce_inst (
  .clk                                  (fpga_clk_100),
  .reset_n                              (~hps_fpga_reset),  
  .data_in                              (fpga_button_pio),
  .data_out                             (fpga_debounced_buttons)
);
  defparam debounce_inst.WIDTH = 4;
  defparam debounce_inst.POLARITY = "LOW";
  defparam debounce_inst.TIMEOUT = 100000;              // at 100Mhz this is a debounce time of 1ms
  defparam debounce_inst.TIMEOUT_WIDTH = 32;            // ceil(log2(TIMEOUT))
 

altera_edge_detector pulse_cold_reset (
  .clk       (fpga_clk_100),
  .rst_n     (~hps_fpga_reset),
  .signal_in (hps_reset_req[0]),
  .pulse_out (hps_cold_reset)
);
  defparam pulse_cold_reset.PULSE_EXT = 6;
  defparam pulse_cold_reset.EDGE_TYPE = 1;
  defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_warm_reset (
  .clk       (fpga_clk_100),
  .rst_n     (~hps_fpga_reset),
  .signal_in (hps_reset_req[1]),
  .pulse_out (hps_warm_reset)
);
  defparam pulse_warm_reset.PULSE_EXT = 2;
  defparam pulse_warm_reset.EDGE_TYPE = 1;
  defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_debug_reset (
  .clk       (fpga_clk_100),
  .rst_n     (~hps_fpga_reset),
  .signal_in (hps_reset_req[2]),
  .pulse_out (hps_debug_reset)
);
  defparam pulse_debug_reset.PULSE_EXT = 32;
  defparam pulse_debug_reset.EDGE_TYPE = 1;
  defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;
  

endmodule


