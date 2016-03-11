/*-
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Copyright (c) 2015-2018 A. Theodore Markettos
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
// PCIeBuffer.bsv

import AvalonSTPCIe::*;
import AvalonMM::*;
import GetPut::*;
import ClientServer::*;
import Connectable::*;
import FIFOF::*;
import PCIE::*;
import PCIeByteSwap::*;

typedef Bit#(64) DataType;
typedef Bit#(8) AddressType;
typedef 0 BurstWidth;
typedef 1 ByteEnable;


interface PCIePacketReceiver;
    interface AvalonSinkExtPCIe streamSink;
    interface AvalonSlaveExt#(DataType, AddressType, BurstWidth, ByteEnable) mmSlave;
endinterface: PCIePacketReceiver

module mkPCIePacketReceiver(PCIePacketReceiver);
    AvalonSinkPCIe streamToFIFO <- mkAvalonSinkPCIe;
    AvalonSlave#(DataType, AddressType, BurstWidth, ByteEnable) slave <- mkAvalonSlave;
    Reg#(PCIeWord) currentpcieword <- mkReg(unpack(0));
    Reg#(Bool) next <- mkReg(True);
    FIFOF#(PCIeWord) rxfifo <- mkUGSizedFIFOF(1024);
    Reg#(Bool) fourDWord <- mkReg(True);
    Reg#(UInt#(10)) dwordCounter <- mkReg(10'h0);


    rule serviceMMSlave;
        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req <- slave.client.request.get();
        AvalonMMResponse#(DataType) responseWrapped = 64'hfeeb1ec0ffeefeed;
	DataType response = 64'hdeadfacebeefcafe;
        $display("request");
        if (req matches tagged AvalonRead { address:.address, byteenable:.be, burstcount:.burstcount})
        begin
            $display("read %x",address);
            case (address)
                0:  begin
                        response = rxfifo.first().data;
                        $display("trigger pcieword=%x", rxfifo.first()); 
                        if (rxfifo.notEmpty)
                            rxfifo.deq();
                    end
                1:  begin
//                        response = rxfifo.first().data[63:32];
                        response = rxfifo.first().data;
                    end
                2:  begin
//                        response = {38'b0, pack(rxfifo.first().eof), pack(rxfifo.first().sof), rxfifo.first().be, 8'b0, 8'b0}; //rxfifo.first().parity,  rxfifo.first().bar};
                        response = byteSwap64({rxfifo.first().eof ? 8'hEE:8'h0, rxfifo.first().sof ? 8'h55:8'h0, 22'b0,
				pack(rxfifo.first().eof), pack(rxfifo.first().sof), rxfifo.first().be, 8'b0, 8'b0}); //rxfifo.first().parity,  rxfifo.first().bar};
                    end
                3:  begin
                        response = byteSwap64(signExtend(pack(rxfifo.notEmpty)));
                    end
            endcase
	responseWrapped = response;	// convert from a data word into a response packet
        slave.client.response.put(responseWrapped);
        end

        else if (req matches tagged AvalonWrite{ writedata:.data, address:.address, byteenable:.be, burstcount:.burstcount})
            $display("write %x",address);
//        $display("address=%x", address);

    endrule

    rule fetchpcieword;
        PCIeWord pciedataUnswapped <- streamToFIFO.receive.get();
	PCIeWord pciedataSwapped;

	pciedataSwapped.sof = pciedataUnswapped.sof;
	pciedataSwapped.eof = pciedataUnswapped.eof;
	pciedataSwapped.hit = pciedataUnswapped.hit;

	// header fields have a different byteswapping from data fields
	// the length of the header can be either 3 or 4 dwords, and the start
	// of data can change based on whether it is Q-word (16 byte) aligned or not 

	// we need to know whether the TLP is a 3 or 4 D-word TLP from 64-bit dword 0
	// to decide how to byteswap dword 1
	if (pciedataUnswapped.sof)
	begin // first word, so make a note of packet format
	   fourDWord <= unpack(pciedataUnswapped.data[29]);
	   dwordCounter <= 1;
	   pciedataSwapped.data = byteSwap32in64(pciedataUnswapped.data);
	   $display("PCIe packet start, dwordCounter=%d, fourDWord=%d, unswapped word 0 = %x", dwordCounter, fourDWord, pciedataUnswapped.data);
	end else begin
	   dwordCounter <= dwordCounter + 1;
	   case (dwordCounter)	      // count words beginning at the second (ie the mixed header/data dword)
	   	1: begin	      // if a 3 dword TLP, have to apply data swap and header swap on each half
			if (fourDWord) begin // else a straight header swap
			   pciedataSwapped.data = byteSwap32in64(pciedataUnswapped.data); // header swap
			end else begin
			   pciedataSwapped.data = byteSwapBottom32(pciedataUnswapped.data); // mixed swap
			end
		   end
		default: begin
			 pciedataSwapped.data = pciedataUnswapped.data;
		   end
	   endcase
	end

	// in all data words the byte enables are reversed, and they are ignore for header words.
	// so swap them assuming they're always data
	pciedataSwapped.be = pciedataUnswapped.be;

        if (rxfifo.notFull)
        begin
            rxfifo.enq(pciedataSwapped);
            $display("PCIe word[%d] arrived as %x, swapped into %x, 4DWordTLP=%x, sof=%d, eof=%d, be.in=%x, be.swapped=%x",
	    	dwordCounter, pciedataUnswapped, pciedataSwapped, fourDWord,
		pciedataUnswapped.sof, pciedataUnswapped.eof, pciedataUnswapped.be, pciedataSwapped.be);
        end else begin
            $display("junked");
        end
        next <= False;
    endrule

    rule nextprint;
        $display("next=%d, rxfifo.empty=%d",next, !rxfifo.notEmpty());
    endrule

    interface streamSink = streamToFIFO.asi;
    interface mmSlave = slave.avs;


endmodule


interface PCIePacketReceiverTB;
endinterface

//typedef Bit#(64) PCIeWord;


module mkPCIePacketReceiverTB(PCIePacketReceiverTB);
//    MMRingBufferSink tbsink <- mkMMRingBufferSink;
//    AvalonSinkPCIe sink <- mkAvalonSinkPCIe;
    PCIePacketReceiver dut <- mkPCIePacketReceiver;
    AvalonMaster#(DataType, AddressType, BurstWidth, ByteEnable) master <- mkAvalonMaster;

    //mkConnection(master.avm, dut.mmSlave);

    Reg#(Int#(64)) tick <- mkReg(0);
    Reg#(Int#(10)) wordCounter <- mkReg(0);
    Reg#(Bool) reading <- mkReg(False);
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
        invalue.data = extend(pack(tick)) ^ 64'h01234567A9ABCDEF;
        invalue.be = pack(tick)[12:5];
	invalue.hit = 0;
        //invalue.parity = 0;
        //invalue.bar = 0;
	Int#(10) wordCounterNext = (wordCounter==8) ? 0:wordCounter+1;
	wordCounter <= wordCounterNext;
	invalue.sof = (wordCounterNext == 0);
        invalue.eof = False; 
//        sink.asi.asi(data, False, False, False, 8'hff, 8'h00);
        dut.streamSink.asi(invalue.data, True, invalue.sof, invalue.eof, invalue.be, 0, 0); //invalue.parity, invalue.bar);

        $display("%d: asi_ready = %d", tick, dut.streamSink.asi_ready());
        if (dut.streamSink.asi_ready)
            $display("%d: Input word %d", tick, wordCounter);
    endrule

    rule ready;
        Bool ready = dut.streamSink.asi_ready();
        $display("%d: Ready = %d", tick, ready);
    endrule

    rule read;
//        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req =
//            tagged AvalonRead { address:8'h12, byteenable:1 };
        Bit#(8) address = extend(pack(tick)[5:3]);
        dut.mmSlave.avs(64'hfaceb00cdeadbeef, address, reading, False, 1, 0);
        reading <= !reading;
        if (reading)
            $display("%d: read request addr %x", tick,address);
    endrule

    rule readdata if (dut.mmSlave.avs_readdatavalid);
        $display("%d: read response %x", tick, dut.mmSlave.avs_readdata());
    endrule

//    rule sink_out;
//        PCIeWord out <- dut.streamSink.receive.get();
//        $display("%d: Output %x", tick, pack(out));
//    endrule

endmodule

