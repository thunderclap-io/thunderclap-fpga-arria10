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
// PCIe-specifc byte swapping functions
// (intended for 64 bit PCIe datapath)

// note there's an internal byteSwap which only works for Bit(32)

function Bit#(64) byteSwap64(Bit#(64) in);
	Bit#(64) out;
	out[7:0] = in[63:56];
	out[15:8] = in[55:48];
	out[23:16] = in[47:40];
	out[31:24] = in[39:32];
	out[39:32] = in[31:24];
	out[47:40] = in[23:16];
	out[55:48] = in[15:8];
	out[63:56] = in[7:0];
	return out;
endfunction

function Bit#(64) wordSwap(Bit#(64) in);
	 Bit#(64) out;
	 out[63:32] = in[31:0];
	 out[31:0]  = in[63:32];
	 return out;
endfunction

function Bit#(64) byteSwap32in64(Bit#(64) in);
	 Bit#(64) out;
	 out[63:32] = {in[39:32], in[47:40], in[55:48], in[63:56]};
	 out[31:0] = {in[7:0], in[15:8], in[23:16], in[31:24]};
	 return out;
endfunction

function Bit#(64) byteSwapBottom32(Bit#(64) in);
	 Bit#(64) out;
	 out[63:32] = in[63:32];
	 out[31:0] = {in[7:0], in[15:8], in[23:16], in[31:24]};
	 return out;
endfunction

function Bit#(64) rxWord1Swap(Bit#(64) in);
	 Bit#(64) out;
	 out[63:32] = in[31:0];
	 out[31:0]  = {in[39:32], in[47:40], in[55:48], in[63:56]};
	 return out; 
endfunction

function Bit#(64) txWord1Swap(Bit#(64) in);
	 Bit#(64) out;
	 out[31:0] = in[63:32];
	 out[63:32]  = {in[7:0], in[15:8], in[23:16], in[31:24]};
	 return out; 
endfunction

