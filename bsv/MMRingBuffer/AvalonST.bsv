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

package AvalonST;

import GetPut::*;
import FIFOF::*;


(* always_ready, always_enabled *)
interface AvalonSourceExt#(type dataT);
  method Action aso(Bool ready);
  method dataT aso_data;
  method Bool aso_valid;
  method Bool aso_sop;
  method Bool aso_eop;
  method Bit#(8) aso_be;
  method Bit#(8) aso_parity;
  method Bit#(8) aso_bar;
endinterface

interface AvalonSource#(type dataT);
  interface AvalonSourceExt#(dataT) aso;
  interface Put#(dataT) send;
endinterface

typedef struct {
	Bit#(16)	magic;
	Bit#(8)		be;
	Bit#(8)		parity;
	Bit#(8)		bar;
	Bool		sop;
	Bool		eop;
	Bit#(22)	pad;
} StatusWord deriving (Bits, Eq);

/*
function Bit#(64) packStatus(Bool sop, Bool eop, Bit#(8) be, Bit#(8) parity, Bit#(8) bar);
	Bit#(64) statusWord = (64'hc0de << 52) | (extend(bar)<<24) | (extend(parity)<<16) |
		(extend(be)<<8) | (extend(pack(eop))<<1) | (extend(pack(sop)));
	return statusWord;
endfunction
*/

module mkAvalonSource(AvalonSource#(dataT))
provisos(Bits#(dataT,dataWidth),
	Add#(unused, 64, dataWidth));

  Wire#(Maybe#(dataT)) data <- mkDWire(Invalid);
//  Wire#(Maybe#(Bit#(64))) status <- mkDWire(Invalid);
  PulseWire isReady <- mkPulseWire;

  Reg#(StatusWord) statusLatched <- mkReg(unpack(0));


  interface AvalonSourceExt aso;
    method Action aso(ready);
      if (ready) begin
        isReady.send();
      end
    endmethod
    method aso_data = fromMaybe(?,data);
    method aso_sop = statusLatched.sop;
    method aso_eop = statusLatched.sop;
    method aso_parity = statusLatched.parity;
    method aso_be = statusLatched.be;
    method aso_bar = statusLatched.bar;
    method aso_valid = isValid(data);
  endinterface

  interface Put send;
    method Action put(x) if (isReady);
      StatusWord status = unpack(truncate(pack(x)));
      if (status.magic == 16'hc0de)
	statusLatched <= status;
      else
        data <= Valid(x);
    endmethod
  endinterface

endmodule


(* always_ready, always_enabled *)
interface AvalonSinkExt#(type dataT);
  method Action asi(dataT data, Bool valid, Bool sop, Bool eop, Bit#(8) be, Bit#(8) parity);
  method Bool asi_ready;
endinterface

interface AvalonSink#(type dataT);
  interface AvalonSinkExt#(dataT) asi;
  interface Get#(dataT) receive;
endinterface


module mkAvalonSink(AvalonSink#(dataT))
provisos(Bits#(dataT,64));
//	 Add#(0,dataWidth,64));
//	 Min#(dataWidth,64,64));
//provisos(Bits#(dataT,dataWidth));

  FIFOF#(dataT) queue <- mkGLFIFOF(True,False);
  Reg#(StatusWord) statusBuffer <- mkReg(unpack(0));
  Reg#(Bool) statusEnqueued <- mkReg(False);

  interface AvalonSinkExt asi;
    method Action asi(data,valid,sop,eop,be,parity);
	StatusWord status;
	status.sop = sop;
	status.eop = eop;
	status.be  = be;
	status.parity = parity;
	status.magic = 16'hc0de;
	status.bar = 0;
	status.pad = 22'h0;
//      let statusPacked = extend(pack(status));
      if (statusEnqueued && queue.notFull) begin
	queue.enq(unpack(truncate(pack(statusBuffer))));
	statusEnqueued <= False;
      end
      else if (valid && queue.notFull) begin
        queue.enq(data);
	statusBuffer <= status;
	statusEnqueued <= True;
//		queue.enq(unpack(truncate(pack(status))));
      end
    endmethod
    method asi_ready = queue.notFull && (!statusEnqueued);
  endinterface

  interface receive = toGet(queue);

endmodule


endpackage
