BSC=bsc
LIBS=../../
BSCFLAGS=-keep-fires -cross-info -aggressive-conditions -p +:$(LIBS)
VERILOGDEST=../qsys_ip/MMRingBuffer

all: $(VERILOGDEST) $(VERILOGDEST)/mkMMRingBuffer.v $(VERILOGDEST)/mkMMRingBufferSink.v $(VERILOGDEST)/mkMMRingBufferSource.v

$(VERILOGDEST):
	mkdir $(VERILOGDEST)
	cp RingBuffer*.tcl $(VERILOGDEST)

$(VERILOGDEST)/mkMMRingBuffer.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBuffer MMRingBuffer.bsv

$(VERILOGDEST)/mkMMRingBufferSink.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBufferSink MMRingBuffer.bsv

$(VERILOGDEST)/mkMMRingBufferSource.v: MMRingBuffer.bsv
	$(BSC) $(BSCFLAGS) -vdir $(VERILOGDEST) -u -verilog -g mkMMRingBufferSource MMRingBuffer.bsv

.PHONY: clean
clean:
	rm -f  *.bi *.bo *.ba *.info *.sched *.h *.o *.so $(VERILOGDEST)/mkMMRingBuffer.v $(VERILOGDEST)/mkMMRingBufferSink.v *~  >/dev/null
	rm -rf $(VERILOGDEST)
