///////////////////////////////////////////
// lzd.sv
//
// Written: James.Stine@okstate.edu 1 February 2021
// Modified: 
//
// Purpose: Integer Divide instructions
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
// OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////

module lzd2 (P, V, B);

   input logic  [1:0] B;

   output logic P;
   output logic V;

   assign V = B[0] | B[1];
   //assign P = B[0] & ~B[1];
   assign P = ~B[1];   
   
endmodule // lo2

module lzd_hier #(parameter WIDTH=8) 
   (input logic [WIDTH-1:0]          B,
    output logic [$clog2(WIDTH)-1:0] ZP,
    output logic 		     ZV);

   if (WIDTH == 128)
     lzd128 lzd127 (ZP, ZV, B);	      
   else if (WIDTH == 64)
     lzd64 lzd64 (ZP, ZV, B);	   
   else if (WIDTH == 32)
     lzd32 lzd32 (ZP, ZV, B);
   else if (WIDTH == 16)
     lzd16 lzd16 (ZP, ZV, B);
   else if (WIDTH == 8)
     lzd8 lzd8 (ZP, ZV, B);
   else if (WIDTH == 4)
     lzd4 lzd4 (ZP, ZV, B);

endmodule // lzd_hier

module lzd4 (ZP, ZV, B);

   input logic [3:0]  B;

   logic  	       ZPa;
   logic  	       ZPb;
   logic 	       ZVa;
   logic 	       ZVb;   

   output logic [1:0]  ZP;
   output logic        ZV;

   lzd2 l1(ZPa, ZVa, B[1:0]);
   lzd2 l2(ZPb, ZVb, B[3:2]);

   assign ZP[0:0] = ZVb ? ZPb : ZPa;
   assign ZP[1]   = ~ZVb;
   assign ZV = ZVa | ZVb;

endmodule // lzd4

module lzd8 (ZP, ZV, B);

   input logic [7:0]  B;

   logic [1:0] 	       ZPa;
   logic [1:0] 	       ZPb;
   logic 	       ZVa;
   logic 	       ZVb;   

   output logic [2:0]  ZP;
   output logic        ZV;

   lzd4 l1(ZPa, ZVa, B[3:0]);
   lzd4 l2(ZPb, ZVb, B[7:4]);

   assign ZP[1:0] = ZVb ? ZPb : ZPa;
   assign ZP[2]   = ~ZVb;
   assign ZV = ZVa | ZVb;

endmodule // lzd8

module lzd16 (ZP, ZV, B);

   input logic [15:0]  B;

   logic [2:0] 	       ZPa;
   logic [2:0] 	       ZPb;
   logic 	       ZVa;
   logic 	       ZVb;   

   output logic [3:0]  ZP;
   output logic        ZV;

   lzd8 l1(ZPa, ZVa, B[7:0]);
   lzd8 l2(ZPb, ZVb, B[15:8]);

   assign ZP[2:0] = ZVb ? ZPb : ZPa;
   assign ZP[3]   = ~ZVb;
   assign ZV = ZVa | ZVb;

endmodule // lzd16

module lzd32 (ZP, ZV, B);

   input logic [31:0] B;

   logic [3:0] 	      ZPa;
   logic [3:0] 	      ZPb;
   logic 	      ZVa;
   logic 	      ZVb;
   
   output logic [4:0] ZP;
   output logic       ZV;
   
   lzd16 l1(ZPa, ZVa, B[15:0]);
   lzd16 l2(ZPb, ZVb, B[31:16]);
   
   assign ZP[3:0] = ZVb ? ZPb : ZPa;
   assign ZP[4]   = ~ZVb;
   assign ZV = ZVa | ZVb;

endmodule // lzd32

module lzd64 (ZP, ZV, B);

   input logic [63:0]  B;
   
   logic [4:0] 	       ZPa;
   logic [4:0] 	       ZPb;
   logic 	       ZVa;
   logic 	       ZVb;
   
   output logic [5:0]  ZP;
   output logic        ZV;
   
   lzd32 l1(ZPa, ZVa, B[31:0]);
   lzd32 l2(ZPb, ZVb, B[63:32]);
   
   assign ZP[4:0] = ZVb ? ZPb : ZPa;
   assign ZP[5]   = ~ZVb;
   assign ZV = ZVa | ZVb;

endmodule // lzd64

module lzd128 (ZP, ZV, B);

   input logic [127:0]  B;
   
   logic [5:0] 	       ZPa;
   logic [5:0] 	       ZPb;
   logic 	       ZVa;
   logic 	       ZVb;
   
   output logic [6:0]  ZP;
   output logic        ZV;
   
   lzd64 l1(ZPa, ZVa, B[64:0]);
   lzd64 l2(ZPb, ZVb, B[127:63]);
   
   assign ZP[5:0] = ZVb ? ZPb : ZPa;
   assign ZP[6]   = ~ZVb;
   assign ZV = ZVa | ZVb;

endmodule // lzd128
