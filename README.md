This is an Arria 10 SoC FPGA design for the Arria 10 SoC development kit.
PCIe TLPs are available on pipes in the ARM memory space.

The A10SoCDK is connected to PCIe via an FMC to PCIe cable in socket FMCB. 
(This cable is a Samtec HDR-181157-01-PCIEC, special/made to order for about
$200 in 1 off from Samtec direct)

# Memory map:

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

# PCIe packet pipes

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

# Building the FPGA via Quartus GUI

Tested with Quartus 17.1 standard (not Lite or Pro).  Needs BSV compiler:

1. 
```
make -C pcie-bsv/bsv/MMRingBuffer
```
2. Open in Qsys/Platform Designer:
```
qsys-edit ghrd_10as066n2.qsys
```
3. Press the Generate HDL... button
4. Open in Quartus:
```
quartus ghrd_10as066n2 &
```
5. Processing -> Start Compilation


# Building the SD card image

First build your FPGA bitfile with Quartus.  Then fetch and build the
necessary components to generate a suitable SD card:

```
git clone https://github.com/CTSRD-CHERI/pcie-probe-software.git
mkdir sdcard
cd sdcard
../pcie-probe-software/scripts/socfpga/build_ubuntu_sdcard.sh ../pcie-fpga-arria10-socdevkit ghrd_10as066n2
```
