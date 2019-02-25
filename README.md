# Thunderclap FPGA hardware platform

This repository contains the FPGA design for the Thunderclap platform, as run on two Arria 10 boards:

* The Intel Arria 10 SoC Development Kit, connected to PCIe via an FMC to PCIe cable in socket FMCB.
(This cable is a Samtec HDR-181157-01-PCIEC, special/made to order for about
$200 in 1 off from Samtec direct)
* The Enclustra Mercury AA1+ board in a PE1 carrier board (probably PE1-200 - still work in progress)

Architecturally, the system consists of the hard Arm Cortex A9 CPU, with a PCI Express IP core in the FPGA logic.  The IP core is connected to the Arm via simple polled pipes that deliver raw PCI Express packets (TLPs).  Software reads/writes these pipes and parses the PCIe messages, and is able to generated arbitrary packets on PCIe.  All this is software-defined, there is at present no acceleration for PCIe packet generation.

## Memory map:

```
    HPS2FPGA bridge base:  0xC0000000
    256KB SRAM:            0xC0000000
    PCIePacketReceiver:    0xC0040000
    PCIePacketTransmitter: 0xC0040400
    Transceiver reconfig:  0xC0044000
    Reconfig PLL0:         0xC0045000
    Reconfig PLL1:         0xC0046000
    JTAG UART:             0xC0047000
    System ID ('0x4e110')  0xC0047010

    Lightweight HPS2FPGA
      bridge base:         0xFF200000
    System ID (0xb0071800) 0xFF200000
    LED PIO                0xFF200010
    Button PIO             0xFF200020
    DIP switches           0xFF200030
    Reset PIO              0xFF200040
    Altera Interrupt
      Latency Counter      0xFF200100
```

## PCIe packet pipes

Each pipe is 32 bits wide and receives 64 bit data in two pieces:

```
    +0x0: bits 0-31 (TX on write/RX dequeue on read)
    +0x4: bits 32-63
    +0x8: flags:
            bits 0-15: reserved
            bits 16-23: byte enables for 64 bit word
            bit  24: set if start of packet
            bit  25: set if end of packet
            bits 26-31: reserved
    +0xC: read pipe: non-zero if there is data to read
          write pipe: bit 0 set will send the packet
```

Offset +0x0 is read/write sensitve, ie the protocol to read a 64 bit word
is to read +0x4 and subsequently +0x0.  Reading 0x0 will prepare the next
word for reading.

Setting bit 0 of the reset PIO will force the PCIe core into reset, clearing
will re-enable the PCIe core.  The hard IP is hardwired to the PCIE_PERST
reset line - ie it appears the PIO will only reset PCIe logic but not the
transceivers.

The pipe logic is written in BSV (Bluespec System Verilog), however generated Verilog sources are also provided.

# Building the FPGA

Assuming Intel Quartus is on your PATH (tested with versions 17.1 standard and 18.1 standard), from the top level run:

```
make intel-a10soc-devkit
```

or
```
make enclustra-mercury-aa1-pe1
```

(once the first build is run, you can also open the projects in the `boards` directory in the Quartus GUI)

# Building the SD card image

(scripted version still work in progress)

First build your FPGA bitfile with Quartus.  Then fetch and build the
necessary components to generate a suitable SD card (requires sudo and
Quartus's embedded tools installed):

```
sudo whoami # prompt early so we aren't interrupted
export SOCEDS_DEST_ROOT=$QUARTUS_ROOTDIR/../embedded
. $SOCEDS_DEST_ROOT/env.sh
git clone https://github.com/thunderclap-io/thunderclap-qemu.git
mkdir sdcard
cd sdcard
../thunderclap-qemu/scripts/socfpga/build_ubuntu_sdcard.sh ../thunderclap-fpga-arria10 ghrd_10as066n2
```

You may need to install Ubuntu package libssl-dev to build the Linux kernel.
