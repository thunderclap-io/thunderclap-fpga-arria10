BSC=bsc
LIBS=../../
BSCFLAGS=-keep-fires -cross-info -aggressive-conditions -p +:$(LIBS)
VERILOGDEST=../qsys_ip/MMRingBuffer

#all: $(VERILOGDEST) $(VERILOGDEST)/mkMMRingBuffer.v $(VERILOGDEST)/mkMMRingBufferSink.v $(VERILOGDEST)/mkMMRingBufferSource.v
all: $(VERILOGDEST) $(VERILOGDEST)/mkPCIePacketReceiver.v $(VERILOGDEST)/mkPCIePacketTransmitter.v

$(VERILOGDEST):
	mkdir -p $(VERILOGDEST)
	cp *.tcl $(VERILOGDEST)

$(VERILOGDEST)/mkMMRingBuffer.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBuffer MMRingBuffer.bsv

$(VERILOGDEST)/mkMMRingBufferSink.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBufferSink MMRingBuffer.bsv

$(VERILOGDEST)/mkMMRingBufferSource.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBufferSource MMRingBuffer.bsv

$(VERILOGDEST)/mkPCIePacketReceiver.v: PCIePacketReceiver.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkPCIePacketReceiver PCIePacketReceiver.bsv

$(VERILOGDEST)/mkPCIePacketTransmitter.v: PCIePacketTransmitter.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkPCIePacketTransmitter PCIePacketTransmitter.bsv

ringtest:
	$(BSC) $(BSCFLAGS) -u -sim -g mkMMRingBufferTB MMRingBufferTB.bsv
	$(BSC) $(BSCFLAGS) -e mkMMRingBufferTB -sim -o mkMMRingBufferTB -g mkMMRingBufferTB 

sttest:
	$(BSC) $(BSCFLAGS) -u -sim -g mkAvalonSinkTB AvalonSTTB.bsv
	$(BSC) $(BSCFLAGS) -e mkAvalonSinkTB -sim -o mkAvalonSinkTB -g mkAvalonSinkTB 
	$(BSC) $(BSCFLAGS) -u -sim -g mkAvalonSourceTB AvalonSTTB.bsv
	$(BSC) $(BSCFLAGS) -e mkAvalonSourceTB -sim -o mkAvalonSourceTB -g mkAvalonSourceTB 

pcietest:
	$(BSC) $(BSCFLAGS) -u -sim -g mkPCIePacketReceiverTB PCIePacketReceiver.bsv
	$(BSC) $(BSCFLAGS) -e mkPCIePacketReceiverTB -sim -o mkPCIePacketReceiverTB -g mkPCIePacketReceiverTB 
	$(BSC) $(BSCFLAGS) -u -sim -g mkPCIePacketTransmitterTB PCIePacketTransmitter.bsv
	$(BSC) $(BSCFLAGS) -e mkPCIePacketTransmitterTB -sim -o mkPCIePacketTransmitterTB -g mkPCIePacketTransmitterTB 
#	./sim

$(VERILOGDEST)/mkAvalonSinkPCIe.v: AvalonST.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkAvalonSinkPCIe AvalonST.bsv

$(VERILOGDEST)/mkAvalonSourcePCIe.v: AvalonST.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkAvalonSourcePCIe AvalonST.bsv



.PHONY: clean
clean:
	rm -f  *.bi *.bo *.ba *.info *.sched *.h *.o *.so $(VERILOGDEST)/mk*.v *~  >/dev/null
	rm -rf $(VERILOGDEST)
