// fma16.sv
// David_Harris@hmc.edu 26 February 2022
// 16-bit floating-point multiply-accumulate
// modified by Cozette Dyer for ECEN 4233 final project 

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

// fmadd: (x*y + z)
// fmsub: (x*y - z)
// fnmadd: -(x*y + z) or -(x*y - z)
// fnmsub: -(x*y - z) or -(x*y) + z

 //    Computes result = (X*Y) + (Z)

module fma16 (x, y, z, mul, add, negr, negz,
	           roundmode, result);
   
   input logic	[15:0]  x, y, z;
   input logic 	       mul, add, negr, negz;
   input logic 	[1:0]   roundmode;
   
   output logic [15:0] result; 

// -------------------- Create variables to hold bits -------//
logic x_sign, y_sign, z_sign, res_sign; // sign bits!
logic [4:0] x_exp, y_exp, z_exp, prod_exp, res_exp; // exponents baby
logic [10:0] x_man, y_man, z_man, prod_man, res_man; // mantissas 
logic [21:0] temp, temp2, temp3; // intermediate results holder
logic [11:0] temp4; // holder of mantissas addition
logic [15:0] prod; // the product sweetie pi 
// Product is X*Y
// Result is the final result of X*Y + Z


// -------------------- Assign bits to variables ----------//
assign x_sign = x[15];
assign y_sign = y[15];
assign z_sign = z[15];

assign x_exp = x[14:10];
assign y_exp = y[14:10];
assign z_exp = z[14:10];

assign x_man = { 1'b1, x[9:0]}; // appended leading 1 to mantissas bc
assign y_man = { 1'b1, y[9:0]}; // actual mantissa is bits [9:0]
assign z_man = { 1'b1, z[9:0]};


// FMA PROCEDURE: 
//    1. multiply significands of X and Y
//    2. add exponents of X and Y
//    3. Determine shift needed, if any
//    4. Shift faction portion of Z to align to product
//    5. Add Z to the product
//    6. Find leading zero for the shift needed for normalization
//    7. Normalize if needed (by shifting and adjusting exponent)
//    8. Round result
//    9. Handle IEEE 754 flags and special cases

// -------------------- Multiply! ---------------------//
assign res_sign = (x_sign ^ y_sign);  // sign bit of result 
assign temp[21:0] = (x_man * y_man); // multiply the mantissas x_man * y_man
assign prod_exp = $signed(x_exp + y_exp + 5'b10001) + temp[21]; // Add by -15 
assign temp2[20:0] = (temp[20:0] >> temp[21]); // shift, if 1; if 0, no change
assign prod_man[10:0] = {1'b1, temp2[19:10]}; // add a leading 1 to mantis bc its the way it is

assign prod[15] = res_sign; 
assign prod[14:10] = prod_exp;
assign prod[9:0] = prod_man[9:0];


// ---------------------- Add! -----------------------//
assign temp3[21:0] = z_man >>> (x_exp-z_exp); // z mantissas buffer with shift **************************
assign temp4[11:0] = x_man + temp3; // buffer of mantissa // line 5 of psuedo

assign res_exp = x_exp + temp4[11]; // temp4 12th bit is either 0 or 1. 
//NEED TO FIND THE LEADING 1 and shift res_exp (MAYBE RENAME) 
// STEP 7 in fma procudure lecture 18 slide something  
// temp4 needs to shift and normalize

assign result[15] = res_sign;
assign result[14:10] = res_exp;
assign result[9:0] = temp4[9:0]; //mantissa of result  

/* //   if (mul) p = x*y
//   else p = x;  
   assign p = mul ? (x*y) : x;
//   if (add) result = p + z;
//   else result = p;
   assign result = add ? (p+z) : p;
// negative result
   if (negr) result = ~result
// negative zero
   if (negz) z = ~z;

   // 00: rz, 01: rne, 10: rp, 11: rn   
   casex (roundmode)
      2'b00: // roundmode = Round to zero;
      2'b01: // roundmode = Round to nearest even;
      2'b10: // roundmode = Round to positive infinity;
      2'b11: // roundmode = Round to nearest;
   endcase // end of rounding mode switch statement 
*/
// ----------------------------------------------------// 

endmodule // end of fma16 module
