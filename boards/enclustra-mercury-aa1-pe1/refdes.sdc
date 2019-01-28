set_time_format -unit ns -decimal_places 3
create_clock -name EMIF_REF_CLOCK -period 30 [get_ports emif_a10_hps_0_pll_ref_clk_clk]
create_clock -name PCIE_REFCLK -period 10 [get_ports PCIE_REFCLK_p]
