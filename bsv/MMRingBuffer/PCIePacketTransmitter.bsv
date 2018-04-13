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
// PCIePacketTx.bsv

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


interface PCIePacketTransmitter;
    interface AvalonSourceExtPCIe streamSource;
    interface AvalonSlaveExt#(DataType, AddressType, BurstWidth, ByteEnable) mmSlave;
endinterface: PCIePacketTransmitter


interface PCIePacketTransmitterTB;
endinterface

//typedef Bit#(64) PCIeWord;


module mkPCIePacketTransmitter(PCIePacketTransmitter);
    AvalonSourcePCIe fifoToStream <- mkAvalonSourcePCIe;
    AvalonSlave#(DataType, AddressType, BurstWidth, ByteEnable) slave <- mkAvalonSlave;
    Reg#(PCIeWord) currentpcieword <- mkReg(unpack(0));
//    Reg#(Bool) next <- mkReg(True);
    Reg#(Bool) go <- mkReg(False);
    FIFOF#(PCIeWord) txfifo <- mkUGSizedFIFOF(64);
    Reg#(Bool) fourDWord <- mkReg(True);
    Reg#(UInt#(10)) dwordCounter <- mkReg(10'h0);

    rule serviceMMSlave;
        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req <- slave.client.request.get();
        AvalonMMResponse#(DataType) response = 64'hdeadfacebeefcafe;
        PCIeWord amendedWord = currentpcieword;
        $display("request");
        if (req matches tagged AvalonWrite { address:.address, byteenable:.be, burstcount:.burstcount})
        begin
	    // for words which we want to transfer verbatim from BERI, we have to 
	    DataType writedataBERI = byteSwap64(req.AvalonWrite.writedata);
            $display("write %x",address);
            case (address)
                0:  begin
                        amendedWord.data = req.AvalonWrite.writedata;
                        if (txfifo.notFull)
                        begin
                            txfifo.enq(amendedWord);
                            $display("txfifo enqueued %x", amendedWord);
                        end
                    end
                1:  begin
                        amendedWord.data = req.AvalonWrite.writedata;
                    end
                2:  begin
                        //amendedWord.bar = writedataBERI[7:0];
                        //amendedWord.parity = writedataBERI[15:8];
                        amendedWord.be = writedataBERI[23:16];
                        amendedWord.sof = unpack(writedataBERI[24]);
                        amendedWord.eof = unpack(writedataBERI[25]);
			amendedWord.hit = 0;
			$display("Framing bits written: sofreg=%d, eofreg=%d, bereg=%x", amendedWord.sof, amendedWord.eof, amendedWord.be);
                    end
                3:  begin
			go <= unpack(writedataBERI[0]);
                    end
            endcase
        currentpcieword <= amendedWord;
        slave.client.response.put(response);
        end

        else if (req matches tagged AvalonRead{ address:.address, byteenable:.be, burstcount:.burstcount})
            begin
                $display("read %x",address);
                slave.client.response.put(byteSwap64(64'hfaceb00c00c0ffee));
            end
//        $display("address=%x", address);

    endrule

    rule sendpcieword;
        if (txfifo.notEmpty && go)
        begin
            PCIeWord pciedataUnswapped = txfifo.first();
            txfifo.deq();

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
		// we think we receive words byte-swapped-within-64 from
		// Avalon, so we have to look the 'fmt' bits in the twisted
		// position
	       Bool fourDWordNext = unpack(pciedataUnswapped.data[5]);
    	       fourDWord <= fourDWordNext;
	       dwordCounter <= 1;
	       pciedataSwapped.data = pciedataUnswapped.data; //byteSwap32in64(pciedataUnswapped.data);
	       $display("PCIe packet start, dwordCounter=%d, fourDWord (this packet)=%d, unswapped word 0 = %x", dwordCounter, fourDWordNext, pciedataUnswapped.data);
	    end else begin
	       dwordCounter <= dwordCounter + 1;
	       case (dwordCounter)	      // count words beginning at the second (ie the mixed header/data dword)
		    1: begin	      // if a 3 dword TLP, have to apply data swap and header swap on each half
			    if (fourDWord) begin // else a straight header swap
			       pciedataSwapped.data = pciedataUnswapped.data; //byteSwap32in64(pciedataUnswapped.data); // header swap
    			       $display("Header word 2/3 swap");
			    end else begin
			       pciedataSwapped.data = pciedataUnswapped.data; //byteSwapBottom32(pciedataUnswapped.data); // mixed swap
    			       $display("Header word 2/data word 0 swap");
			    end
		       end
		    default: begin
		    	     // no need to swap as Avalon and PCIe data are little endian
			     pciedataSwapped.data = pciedataUnswapped.data;
    			     $display("Data swap");
		       end
	       endcase
	    end

	    // in all data words the byte enables are reversed, and they are ignore for header words.
	    // so swap them assuming they're always data
	    //pciedataSwapped.be = reverseBits(pciedataUnswapped.be);
	    pciedataSwapped.be = pciedataUnswapped.be;


            fifoToStream.send.put(pciedataSwapped);
            $display("PCIe word[%d] received from MM=%x, sent swapped=%x", dwordCounter, pciedataUnswapped, pciedataSwapped);
        end
    endrule

    rule nextprint;
        $display("go=%d, txfifo.empty=%d, txfifo.full=%d",go, !txfifo.notEmpty(), !txfifo.notFull());
    endrule

    interface streamSource = fifoToStream.aso;
    interface mmSlave = slave.avs;


endmodule



module mkPCIePacketTransmitterTB(PCIePacketTransmitterTB);
//    MMRingBufferSink tbsink <- mkMMRingBufferSink;
//    AvalonSinkPCIe sink <- mkAvalonSinkPCIe;
    PCIePacketTransmitter dut <- mkPCIePacketTransmitter;
    AvalonMaster#(DataType, AddressType, BurstWidth, ByteEnable) master <- mkAvalonMaster;

    //mkConnection(master.avm, dut.mmSlave);

    Reg#(Int#(32)) tick <- mkReg(0);
    Reg#(Int#(10)) wordCounter <- mkReg(0);
    Reg#(Bool) writing <- mkReg(False);
//   MMRingBufferSource source <- mkMMRingBufferSource;

/*    rule print;
        $display("Hello world\n");
    endrule
*/
    rule ticktock;
        tick <= tick + 1;
    endrule

    rule source_out if (dut.streamSource.aso_valid);
        $display("%d: stream out data=%x, eop=%d, sop=%d, be=%x, parity=%x, bar=%x", tick,
            dut.streamSource.aso_data,
            dut.streamSource.aso_eop,
            dut.streamSource.aso_sop,
            dut.streamSource.aso_be,
		0, 0);
//            dut.streamSource.aso_parity,
//            dut.streamSource.aso_bar);
    endrule

    rule source_enable;
        // always ready
        dut.streamSource.aso(True);
    endrule

    rule write;
//        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req =
//            tagged AvalonRead { address:8'h12, byteenable:1 };

        Bit#(8) address = extend(pack(tick)[3:1]);

	// count 8 words in a packet, but only count the words we actually wrote data,
	// not the ones where our sequential register writes hit something else
	Int#(10) wordCounterNext = (wordCounter==8) ? 0:((address==0 && writing) ? wordCounter+1:wordCounter);
	wordCounter <= wordCounterNext;

	Bit#(64) data = 64'h0123456789abcdef ^ zeroExtend(pack(tick));
	Bool sof = (wordCounter == 0);
	Bool eof = (wordCounter == 3);
	Bit#(8) be = 8'h7b;
	if (address == 2) begin
	   data[24] = pack(sof);
	   data[25] = pack(eof);
	   data[23:16] = be;
	end
	if (address == 3) begin
	   data[0] = 1;
	end
        dut.mmSlave.avs(byteSwap64(data), address, False, writing, 1, 0);
        writing <= !writing;
        if (writing)
            $display("%d: write request addr %x, BERI data=%x, avalon data=%x, sopin=%x, eopin=%x, bein=%x, wordCounter=%d",
	    		  tick,address, data, byteSwap64(data), sof, eof, be, wordCounter);
    endrule

    rule readdata if (dut.mmSlave.avs_readdatavalid);
        $display("%d: read response %x", tick, dut.mmSlave.avs_readdata());
    endrule

//    rule sink_out;
//        PCIeWord out <- dut.streamSink.receive.get();
//        $display("%d: Output %x", tick, pack(out));
//    endrule

endmodule

