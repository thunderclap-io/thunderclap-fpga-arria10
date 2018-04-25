This is an Arria 10 SoC FPGA design for the Arria 10 SoC development kit.
PCIe TLPs are available on pipes in the ARM memory space.

The A10SoCDK is connected to PCIe via an FMC to PCIe cable in socket FMCB. 
(This cable is a Samtec HDR-181157-01-PCIEC, special/made to order for about
$200 in 1 off from Samtec direct)

Memory map:

    HPS2FPGA bridge base:  0xC0000000
    256KB SRAM:	           0xC0000000
    PCIePacketReceiver:    0xC0040000
    PCIePacketTransmitter: 0xC0040400
    Transceiver reconfig:  0xC0044000
    Reconfig PLL0:         0xC0045000
    Reconfig PLL1:         0xC0046000
    JTAG UART:             0xC0047000
    System ID ('0x4e110')  0xC0047010


PCIe packet pipes:

Each pipe is 32 bits wide and receives 64 bit data in two pieces:
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

Offset +0x0 is read/write sensitve, ie the protocol to read a 64 bit word
is to read +0x4 and subsequently +0x0.  Reading 0x0 will prepare the next
word for reading.

