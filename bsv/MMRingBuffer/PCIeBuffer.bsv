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

import AvalonST::*;
import AvalonMM::*;
import GetPut::*;
import ClientServer::*;
import Connectable::*;


typedef Bit#(32) DataType;
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

    rule serviceMMSlave;
        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req <- slave.client.request.get();
        $display("request");
        if (req matches tagged AvalonRead { address:.address, byteenable:.be, burstcount:.burstcount})
        begin
            $display("read %x",address);
            case (address)
                0:  begin
                        $display("trigger pcieword=%x", currentpcieword); 
                        next <= True;
                    end
//                1:
//                2:
//                3:
            endcase
        end
        else if (req matches tagged AvalonWrite{ writedata:.data, address:.address, byteenable:.be, burstcount:.burstcount})
            $display("write %x",address);
//        $display("address=%x", address);

    endrule

    rule fetchpcieword if (next);
        let pcieword <- streamToFIFO.receive.get();
        currentpcieword <= pcieword;
        $display("PCIe word %x arrived", pcieword);
        next <= False;
    endrule

    rule nextprint;
        $display("next=%d",next);
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

    Reg#(Int#(32)) tick <- mkReg(0);
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
        invalue.data = extend(pack(tick));
        invalue.be = 8'hff;
        invalue.parity = 0;
        invalue.bar = 0;
        invalue.sop = False;
        invalue.eop = False; 
//        sink.asi.asi(data, False, False, False, 8'hff, 8'h00);
        dut.streamSink.asi(invalue.data, True, invalue.sop, invalue.eop, invalue.be, invalue.parity, invalue.bar);

        $display("%d: Input", tick);
        //$display("asi_ready = %d", tbsink.sink.asi_ready());
    endrule

    rule ready;
        Bool ready = dut.streamSink.asi_ready();
        $display("%d: Ready = %d", tick, ready);
    endrule

    rule read;
//        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req =
//            tagged AvalonRead { address:8'h12, byteenable:1 };
        dut.mmSlave.avs(32'hdeadbeef, extend(pack(tick)[3:1]), reading, False, 1, 0);
        reading <= !reading;
        if (reading)
            $display("%d: read request", tick);
    endrule

    rule readdata if (dut.mmSlave.avs_readdatavalid);
        $display("%d: read response", tick);
    endrule

//    rule sink_out;
//        PCIeWord out <- dut.streamSink.receive.get();
//        $display("%d: Output %x", tick, pack(out));
//    endrule

endmodule

