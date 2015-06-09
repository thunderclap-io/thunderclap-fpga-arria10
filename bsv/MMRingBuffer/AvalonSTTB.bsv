//import MMRingBuffer::*;
import AvalonST::*;
import GetPut::*;

interface AvalonSTTB;
endinterface

//typedef Bit#(64) PCIeWord;

typedef struct {
    Bit#(8)     be;
    Bit#(8)     parity;
    Bit#(8)     bar;
    Bool        sop;
    Bool        eop;
    Bit#(64)    data;
//    Bit#(22)    pad;
} PCIeWord deriving (Bits, Eq);



module mkAvalonSinkTB(AvalonSTTB);
//    MMRingBufferSink tbsink <- mkMMRingBufferSink;
    AvalonSink#(PCIeWord) sink <- mkAvalonSink;
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
        invalue.parity = 0;
        invalue.bar = 0;
        invalue.sop = False;
        invalue.eop = False; 
//        sink.asi.asi(data, False, False, False, 8'hff, 8'h00);
        sink.asi.asi(invalue, True);

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
    AvalonSource#(PCIeWord) source <- mkAvalonSource;
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
        PCIeWord dataout = source.aso.aso_data();

        $display("%x: Output word %x", tick, pack(dataout));
        //$display("asi_ready = %d", tbsink.sink.asi_ready());
    endrule


    rule source_in;
        PCIeWord invalue;
        invalue.data = extend(pack(tick));
        invalue.be = 8'hff;
        invalue.parity = 0;
        invalue.bar = 0;
        invalue.sop = False;
        invalue.eop = False; 

        source.send.put(invalue);
        $display("%d: put %x", tick, pack(invalue));
    endrule

endmodule
