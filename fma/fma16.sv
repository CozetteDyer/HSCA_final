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

// ----------------------------------------------------//
   if (mul) p = x * y;
   else p = x;

// can this be done? check again next week when we die                  ~~~
   if (mul) begin
      p = x * y; 
      if (add = 0) fmul();                                              // ~~ CHECK MEE
   end // end of mul = 1 if loop
   else p = x;
// test, remove this whole section if this cannot be done               ~~~

   if (add) result = p + z;
   else result = p;

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

