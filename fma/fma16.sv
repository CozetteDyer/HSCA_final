// fma16.sv
// David_Harris@hmc.edu 26 February 2022
// 16-bit floating-point multiply-accumulate

// Operation: general purpose multiply, add, fma, with optional negation
//   If mul=1, p = x * y.  Else p = x.
//   If add=1, result = p + z.  Else result = p.
//   If negr or negz = 1, negate result or z to handle negations and subtractions
//   fadd:   mul = 0, add = 1, negr = 0, negz = 0
//   fsub:   mul = 0, add = 1, negr = 0, negz = 1
//   fmul:   mul = 1, add = 0, negr = 0, negz = 0
//   fmadd:  mul = 1, add = 1, negr = 0, negz = 0
//   fmsub:  mul = 1, add = 1, negr = 0, negz = 1
//   fnmadd: mul = 1, add = 1, negr = 1, negz = 0
//   fnmsub: mul = 1, add = 1, negr = 1, negz = 1

//    Computes result = (X*Y) + (Z)

module fma16 (x, y, z, mul, add, negr, negz,
	           roundmode, result);
   
   input logic [15:0]  x, y, z, p;   
   input logic 	     mul, add, negr, negz;
   input logic [1:0]   roundmode;
   
   output logic [15:0] result;

// -------------------- Assign bits to variables --------------------------------//
logic xsign, ysign, zsign, rsign; // sign bits!
logic [4:0] xexp, yexp, zexp, rexp; // exponents baby
logic [10:0] xman, yman, zman, rman; // mantissas 
logic [21:0] intRes, intRes2; // intermediate result

assign xsign = x[15];
assign ysign = y[15];
assign zsign = z[15];

assign xexp = x[14:10];
assign yexp = y[14:10];
assign zexp = z[14:10];

assign xman = { 1'b1, x[9:0]}; // appended leading 1 to mantissas
assign yman = { 1'b1, y[9:0]}; // i think
assign zman = { 1'b1, z[9:0]};

rsign[15] = xsign^ysign;

assign intRes[21:0] = (xman * yman);
assign rexp = $signed(xexp + yexp + 5'b10001) + intRes[21]; // shift by -15 
assign intRes2[20:0] = (intRes[20:0] >> intRes[21]); // shift if 1; if o, not
assign rman[10:0] = {1'b1, intRes2[19:10]};

assign result[15] = rsign;
assign result[14:10] = rexp;
assign result[9:0] = rman[9:0];


//   if (mul) p = x*y
//   else p = x;
   assign p = mul ? x*y : x;

//   if (add) result = p + z;
//   else result = p;
   assign result = add ? p+z : p;
   
// negative result
   if (negr) result = ~result;
      
// negative zero
   if (negz) z = ~z;

   // 00: rz, 01: rne, 10: rp, 11: rn   
   casex (roundmode)
      2'b00: // roundmode = Round to zero;
      2'b01: // roundmode = Round to nearest even;
      2'b10: // roundmode = Round to positive infinity;
      2'b11: // roundmode = Round to nearest;
   endcase // end of rounding mode switch statement 

// ----------------------------------------------------// 

endmodule // end of fma16 module

module half_adder (Cout, Sum, A, B);

   input logic A,B;
   output logic Sum,Cout;

   xor xor1(Sum,A,B);
   and and1(Cout,A,B);

endmodule // end of Half Adder


module full_adder (Cout, Sum, A, B, Cin);

   input logic A,B,Cin;
   output logic Sum,Cout;
   wire S1,C1,C2;

   half_adder ha1(C1,S1,A,B);
   half_adder ha2(C2,Sum,S1,Cin);
   or or1(Cout,C1,C2);

endmodule // end of Full Adder
