BSC=bsc
LIBS=../../
BSCFLAGS=-keep-fires -cross-info -aggressive-conditions -p +:$(LIBS)
VERILOGDEST=../qsys_ip/MMRingBuffer

all: $(VERILOGDEST) $(VERILOGDEST)/mkMMRingBuffer.v $(VERILOGDEST)/mkMMRingBufferSink.v $(VERILOGDEST)/mkMMRingBufferSource.v

$(VERILOGDEST):
	mkdir -p $(VERILOGDEST)
	cp RingBuffer*.tcl $(VERILOGDEST)

$(VERILOGDEST)/mkMMRingBuffer.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBuffer MMRingBuffer.bsv

$(VERILOGDEST)/mkMMRingBufferSink.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBufferSink MMRingBuffer.bsv

$(VERILOGDEST)/mkMMRingBufferSource.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBufferSource MMRingBuffer.bsv

ringtest:
	$(BSC) $(BSCFLAGS) -u -sim -g mkMMRingBufferTB MMRingBufferTB.bsv
	$(BSC) $(BSCFLAGS) -e mkMMRingBufferTB -sim -o mkMMRingBufferTB -g mkMMRingBufferTB 

sttest:
	$(BSC) $(BSCFLAGS) -u -sim -g mkAvalonSinkTB AvalonSTTB.bsv
	$(BSC) $(BSCFLAGS) -e mkAvalonSinkTB -sim -o mkAvalonSinkTB -g mkAvalonSinkTB 
	$(BSC) $(BSCFLAGS) -u -sim -g mkAvalonSourceTB AvalonSTTB.bsv
	$(BSC) $(BSCFLAGS) -e mkAvalonSourceTB -sim -o mkAvalonSourceTB -g mkAvalonSourceTB 

pcietest:
	$(BSC) $(BSCFLAGS) -u -sim -g mkPCIePacketReceiverTB PCIeBuffer.bsv
	$(BSC) $(BSCFLAGS) -e mkPCIePacketReceiverTB -sim -o mkPCIePacketReceiverTB -g mkPCIePacketReceiverTB 
#	./sim

$(VERILOGDEST)/mkAvalonSinkPCIe.v: AvalonST.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkAvalonSinkPCIe AvalonST.bsv

$(VERILOGDEST)/mkAvalonSourcePCIe.v: AvalonST.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkAvalonSourcePCIe AvalonST.bsv



.PHONY: clean
clean:
	rm -f  *.bi *.bo *.ba *.info *.sched *.h *.o *.so $(VERILOGDEST)/mkMMRingBuffer.v $(VERILOGDEST)/mkMMRingBufferSink.v *~  >/dev/null
	rm -rf $(VERILOGDEST)
