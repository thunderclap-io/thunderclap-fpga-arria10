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

import AvalonST::*;
import AvalonMM::*;
import GetPut::*;
import ClientServer::*;
import Connectable::*;
import FIFOF::*;


typedef Bit#(32) DataType;
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
    Reg#(Bool) next <- mkReg(True);
    FIFOF#(PCIeWord) txfifo <- mkUGSizedFIFOF(64);

    rule serviceMMSlave;
        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req <- slave.client.request.get();
        AvalonMMResponse#(DataType) response = 32'hcafecafe;
        PCIeWord amendedWord = currentpcieword;
        $display("request");
        if (req matches tagged AvalonWrite { address:.address, byteenable:.be, burstcount:.burstcount})
        begin
            $display("write %x",address);
            case (address)
                0:  begin
                        amendedWord.data[31:0] = req.AvalonWrite.writedata;
                        if (txfifo.notFull)
                        begin
                            txfifo.enq(amendedWord);
                            $display("txfifo enqueued %x", amendedWord);
                        end
                    end
                1:  begin
                        amendedWord.data[63:32] = req.AvalonWrite.writedata;
                    end
                2:  begin
                        amendedWord.bar = req.AvalonWrite.writedata[7:0];
                        amendedWord.parity = req.AvalonWrite.writedata[15:8];
                        amendedWord.be = req.AvalonWrite.writedata[23:16];
                        amendedWord.sop = unpack(req.AvalonWrite.writedata[24]);
                        amendedWord.eop = unpack(req.AvalonWrite.writedata[25]);
                    end
                3:  begin
                    end
            endcase
        currentpcieword <= amendedWord;
        slave.client.response.put(response);
        end

        else if (req matches tagged AvalonRead{ address:.address, byteenable:.be, burstcount:.burstcount})
            begin
                $display("read %x",address);
                slave.client.response.put(32'h00c0ffee);
            end
//        $display("address=%x", address);

    endrule

    rule sendpcieword;
        if (txfifo.notEmpty)
        begin
            let pciedata = txfifo.first();
            txfifo.deq();
            fifoToStream.send.put(pciedata);
            $display("PCIe word %x sent", pciedata);
        end
    endrule

    rule nextprint;
        $display("next=%d, txfifo.empty=%d, txfifo.full=%d",next, !txfifo.notEmpty(), !txfifo.notFull());
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
    Reg#(Bool) writing <- mkReg(False);
//   MMRingBufferSource source <- mkMMRingBufferSource;

/*    rule print;
        $display("Hello world\n");
    endrule
*/
    rule ticktock;
        tick <= tick + 1;
    endrule
/*
    rule sink_in;
        PCIeWord invalue;
        invalue.data = extend(pack(tick));
        invalue.be = 8'hff;
        invalue.parity = 0;
        invalue.bar = 0;
        invalue.sop = True;
        invalue.eop = False; 
//        sink.asi.asi(data, False, False, False, 8'hff, 8'h00);
        dut.streamSink.asi(invalue.data, True, invalue.sop, invalue.eop, invalue.be, invalue.parity, invalue.bar);

        $display("%d: asi_ready = %d", tick, dut.streamSink.asi_ready());
        if (dut.streamSink.asi_ready)
            $display("%d: Input", tick);
    endrule

    rule ready;
        Bool ready = dut.streamSink.asi_ready();
        $display("%d: Ready = %d", tick, ready);
    endrule
*/
    rule source_out if (dut.streamSource.aso_valid);
        $display("%d: stream out data=%x, eop=%d, sop=%d, be=%x, parity=%x, bar=%x", tick,
            dut.streamSource.aso_data,
            dut.streamSource.aso_eop,
            dut.streamSource.aso_sop,
            dut.streamSource.aso_be,
            dut.streamSource.aso_parity,
            dut.streamSource.aso_bar);
    endrule

    rule source_enable;
        // always ready
        dut.streamSource.aso(True);
    endrule

    rule write;
//        AvalonMMRequest#(DataType, AddressType, BurstWidth, ByteEnable) req =
//            tagged AvalonRead { address:8'h12, byteenable:1 };
        Bit#(8) address = extend(pack(tick)[5:3]);
        dut.mmSlave.avs(32'h01234567, address, False, writing, 1, 0);
        writing <= !writing;
        if (writing)
            $display("%d: write request addr %x", tick,address);
    endrule

    rule readdata if (dut.mmSlave.avs_readdatavalid);
        $display("%d: read response %x", tick, dut.mmSlave.avs_readdata());
    endrule

//    rule sink_out;
//        PCIeWord out <- dut.streamSink.receive.get();
//        $display("%d: Output %x", tick, pack(out));
//    endrule

endmodule

