/*-
 * Copyright (c) 2013 Alex Horsman
 * All rights reserved.
 *
 * This software was developed by SRI International and the University of
 * Cambridge Computer Laboratory under DARPA/AFRL contract FA8750-10-C-0237
 * ("CTSRD"), as part of the DARPA CRASH research programme.
 *
 * @BERI_LICENSE_HEADER_START@
 *
 * Licensed to BERI Open Systems C.I.C. (BERI) under one or more contributor
 * license agreements.  See the NOTICE file distributed with this work for
 * additional information regarding copyright ownership.  BERI licenses this
 * file to you under the BERI Hardware-Software License, Version 1.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at:
 *
 *   http://www.beri-open-systems.org/legal/license-1-0.txt
 *
 * Unless required by applicable law or agreed to in writing, Work distributed
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * @BERI_LICENSE_HEADER_END@
 */

package AvalonSTPCIe;

import GetPut::*;
import FIFOF::*;
import PCIE::*;

/*
typedef struct {
    Bit#(8)     be;
    Bit#(8)     parity;
    Bit#(8)     bar;
    Bool        sop;
    Bool        eop;
    Bit#(64)    data;
//    Bit#(22)    pad;
} PCIeWord deriving (Bits, Eq);
*/

typedef TLPData#(8) PCIeWord;


(* always_ready, always_enabled *)
interface AvalonSourceExtPCIe;
  method Action aso(Bool ready);
  method Bit#(64) aso_data;
  method Bool aso_valid;
  method Bool aso_sop;
  method Bool aso_eop;
  method Bit#(8) aso_be;
  method Bit#(8) aso_parity;
  method Bit#(8) aso_bar;
  method Bool aso_err;
endinterface

interface AvalonSourcePCIe;
  interface AvalonSourceExtPCIe aso;
  interface Put#(PCIeWord) send;
endinterface


module mkAvalonSourcePCIe(AvalonSourcePCIe);
//provisos(Bits#(PCIeWord,dataWidth));

  Wire#(Maybe#(PCIeWord)) data <- mkDWire(Invalid);
  PulseWire isReady <- mkPulseWire;

  interface AvalonSourceExtPCIe aso;
    method Action aso(ready);
      if (ready) begin
        isReady.send();
      end
    endmethod

    method aso_data = fromMaybe(?,data).data;
    method aso_valid = isValid(data);
    method aso_sop = fromMaybe(?,data).sof;
    method aso_eop = fromMaybe(?,data).eof;
    method aso_bar = 0; //fromMaybe(?,data).bar;
    method aso_be = fromMaybe(?,data).be;
    method aso_parity = 0; //fromMaybe(?,data).parity;
    method aso_err = False;
  endinterface

  interface Put send;
    method Action put(x) if (isReady);
      data <= Valid(x);
    endmethod
  endinterface

endmodule


(* always_ready, always_enabled *)
interface AvalonSinkExtPCIe;
  method Action asi(Bit#(64) data, Bool valid, Bool sop, Bool eop, Bit#(8) be, Bit#(8) parity, Bit#(8) bar);
  method Bool asi_ready;
endinterface

interface AvalonSinkPCIe;
  interface AvalonSinkExtPCIe asi;
  interface Get#(PCIeWord) receive;
endinterface


module mkAvalonSinkPCIe(AvalonSinkPCIe);
//provisos(Bits#(dataT,dataWidth));

  FIFOF#(PCIeWord) queue <- mkGLFIFOF(True,False);

  interface AvalonSinkExtPCIe asi;
    method Action asi(data,valid,sop,eop,be,parity,bar);
      if (valid && queue.notFull) begin
        PCIeWord tfr;
        tfr.data = data;
        tfr.sof = sop;
        tfr.eof = eop;
        tfr.be = be;
        //tfr.parity = parity;
        //tfr.bar = bar;
	tfr.hit = 0; // unused Xilinx-ism
        queue.enq(tfr);
      end
    endmethod
    method asi_ready = queue.notFull;
  endinterface

  interface receive = toGet(queue);

endmodule


endpackage
