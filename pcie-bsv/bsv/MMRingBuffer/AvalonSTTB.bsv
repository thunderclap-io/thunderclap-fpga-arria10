//import MMRingBuffer::*;
import AvalonSTPCIe::*;
import GetPut::*;
import PCIE::*;

interface AvalonSTTB;
endinterface

//typedef Bit#(64) PCIeWord;



module mkAvalonSinkTB(AvalonSTTB);
//    MMRingBufferSink tbsink <- mkMMRingBufferSink;
    AvalonSinkPCIe sink <- mkAvalonSinkPCIe;
    Reg#(Int#(32)) tick <- mkReg(0);
//   MMRingBufferSource source <- mkMMRingBufferSource;

/*    rule print;
        $display("Hello world\n");
    endrule
*/
    rule ticktock;
        tick <= tick + 1;
    endrule

    rule sink_in;
        PCIeWord invalue;
        invalue.data = extend(pack(tick));
        invalue.be = 8'hff;
        //invalue.parity = 0;
        //invalue.bar = 0;
	invalue.hit = 0;
        invalue.sof = False;
        invalue.eof = False; 
//        sink.asi.asi(data, False, False, False, 8'hff, 8'h00);
        sink.asi.asi(invalue.data, True, invalue.sof, invalue.eof, invalue.be, 0, 0);

        $display("%d: Input", tick);
        //$display("asi_ready = %d", tbsink.sink.asi_ready());
    endrule

    rule ready;
        Bool ready = sink.asi.asi_ready();
        $display("%d: Ready = %d", tick, ready);
    endrule

    rule sink_out;
        PCIeWord out <- sink.receive.get();
        $display("%d: Output %x", tick, pack(out));
    endrule

endmodule

module mkAvalonSourceTB(AvalonSTTB);
//    MMRingBufferSink tbsink <- mkMMRingBufferSink;
    AvalonSourcePCIe source <- mkAvalonSourcePCIe;
    Reg#(Int#(32)) tick <- mkReg(0);
//   MMRingBufferSource source <- mkMMRingBufferSource;

/*    rule print;
        $display("Hello world\n");
    endrule
*/
    rule ticktock;
        tick <= tick + 1;
    endrule

    rule ready;
        source.aso.aso(True);
    endrule

    rule source_out;
//        sink.asi.asi(data, False, False, False, 8'hff, 8'h00);
        Bit#(64) dataout = source.aso.aso_data();

        $display("%x: Output word %x", tick, pack(dataout));
        //$display("asi_ready = %d", tbsink.sink.asi_ready());
    endrule


    rule source_in;
        PCIeWord invalue;
        invalue.data = extend(pack(tick));
        invalue.be = 8'hff;
        //invalue.parity = 0;
        //invalue.bar = 0;
	invalue.hit = 0;
        invalue.sof = False;
        invalue.eof = False; 

        source.send.put(invalue);
        $display("%d: put %x", tick, pack(invalue));
    endrule

endmodule
