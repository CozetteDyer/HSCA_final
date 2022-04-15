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
   if (mul) csam11(p,x,y); // p = x*y
   else p = x;

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

module csam11 (Z, X, Y);

        input logic [10:0] Y;
        input logic [10:0] X;
        output logic [21:0] Z;


        logic [10:0] P0;
        logic [10:0] carry1;
        logic [10:0] sum1;
        logic [10:0] P1;
        logic [10:0] carry2;
        logic [10:0] sum2;
        logic [10:0] P2;
        logic [10:0] carry3;
        logic [10:0] sum3;
        logic [10:0] P3;
        logic [10:0] carry4;
        logic [10:0] sum4;
        logic [10:0] P4;
        logic [10:0] carry5;
        logic [10:0] sum5;
        logic [10:0] P5;
        logic [10:0] carry6;
        logic [10:0] sum6;
        logic [10:0] P6;
        logic [10:0] carry7;
        logic [10:0] sum7;
        logic [10:0] P7;
        logic [10:0] carry8;
        logic [10:0] sum8;
        logic [10:0] P8;
        logic [10:0] carry9;
        logic [10:0] sum9;
        logic [10:0] P9;
        logic [10:0] carry10;
        logic [10:0] sum10;
        logic [10:0] P10;
        logic [10:0] carry11;
        logic [10:0] sum11;
        logic [20:0] carry12;


        // generate the partial products.
        and pp1(P0[10], X[10], Y[0]);
        and pp2(P0[9], X[9], Y[0]);
        and pp3(P0[8], X[8], Y[0]);
        and pp4(P0[7], X[7], Y[0]);
        and pp5(P0[6], X[6], Y[0]);
        and pp6(P0[5], X[5], Y[0]);
        and pp7(P0[4], X[4], Y[0]);
        and pp8(P0[3], X[3], Y[0]);
        and pp9(P0[2], X[2], Y[0]);
        and pp10(P0[1], X[1], Y[0]);
        and pp11(P0[0], X[0], Y[0]);
        and pp12(sum1[10], X[10], Y[1]);
        and pp13(P1[9], X[9], Y[1]);
        and pp14(P1[8], X[8], Y[1]);
        and pp15(P1[7], X[7], Y[1]);
        and pp16(P1[6], X[6], Y[1]);
        and pp17(P1[5], X[5], Y[1]);
        and pp18(P1[4], X[4], Y[1]);
        and pp19(P1[3], X[3], Y[1]);
        and pp20(P1[2], X[2], Y[1]);
        and pp21(P1[1], X[1], Y[1]);
        and pp22(P1[0], X[0], Y[1]);
        and pp23(sum2[10], X[10], Y[2]);
        and pp24(P2[9], X[9], Y[2]);
        and pp25(P2[8], X[8], Y[2]);
        and pp26(P2[7], X[7], Y[2]);
        and pp27(P2[6], X[6], Y[2]);
        and pp28(P2[5], X[5], Y[2]);
        and pp29(P2[4], X[4], Y[2]);
        and pp30(P2[3], X[3], Y[2]);
        and pp31(P2[2], X[2], Y[2]);
        and pp32(P2[1], X[1], Y[2]);
        and pp33(P2[0], X[0], Y[2]);
        and pp34(sum3[10], X[10], Y[3]);
        and pp35(P3[9], X[9], Y[3]);
        and pp36(P3[8], X[8], Y[3]);
        and pp37(P3[7], X[7], Y[3]);
        and pp38(P3[6], X[6], Y[3]);
        and pp39(P3[5], X[5], Y[3]);
        and pp40(P3[4], X[4], Y[3]);
        and pp41(P3[3], X[3], Y[3]);
        and pp42(P3[2], X[2], Y[3]);
        and pp43(P3[1], X[1], Y[3]);
        and pp44(P3[0], X[0], Y[3]);
        and pp45(sum4[10], X[10], Y[4]);
        and pp46(P4[9], X[9], Y[4]);
        and pp47(P4[8], X[8], Y[4]);
        and pp48(P4[7], X[7], Y[4]);
        and pp49(P4[6], X[6], Y[4]);
        and pp50(P4[5], X[5], Y[4]);
        and pp51(P4[4], X[4], Y[4]);
        and pp52(P4[3], X[3], Y[4]);
        and pp53(P4[2], X[2], Y[4]);
        and pp54(P4[1], X[1], Y[4]);
        and pp55(P4[0], X[0], Y[4]);
        and pp56(sum5[10], X[10], Y[5]);
        and pp57(P5[9], X[9], Y[5]);
        and pp58(P5[8], X[8], Y[5]);
        and pp59(P5[7], X[7], Y[5]);
        and pp60(P5[6], X[6], Y[5]);
        and pp61(P5[5], X[5], Y[5]);
        and pp62(P5[4], X[4], Y[5]);
        and pp63(P5[3], X[3], Y[5]);
        and pp64(P5[2], X[2], Y[5]);
        and pp65(P5[1], X[1], Y[5]);
        and pp66(P5[0], X[0], Y[5]);
        and pp67(sum6[10], X[10], Y[6]);
        and pp68(P6[9], X[9], Y[6]);
        and pp69(P6[8], X[8], Y[6]);
        and pp70(P6[7], X[7], Y[6]);
        and pp71(P6[6], X[6], Y[6]);
        and pp72(P6[5], X[5], Y[6]);
        and pp73(P6[4], X[4], Y[6]);
        and pp74(P6[3], X[3], Y[6]);
        and pp75(P6[2], X[2], Y[6]);
        and pp76(P6[1], X[1], Y[6]);
        and pp77(P6[0], X[0], Y[6]);
        and pp78(sum7[10], X[10], Y[7]);
        and pp79(P7[9], X[9], Y[7]);
        and pp80(P7[8], X[8], Y[7]);
        and pp81(P7[7], X[7], Y[7]);
        and pp82(P7[6], X[6], Y[7]);
        and pp83(P7[5], X[5], Y[7]);
        and pp84(P7[4], X[4], Y[7]);
        and pp85(P7[3], X[3], Y[7]);
        and pp86(P7[2], X[2], Y[7]);
        and pp87(P7[1], X[1], Y[7]);
        and pp88(P7[0], X[0], Y[7]);
        and pp89(sum8[10], X[10], Y[8]);
        and pp90(P8[9], X[9], Y[8]);
        and pp91(P8[8], X[8], Y[8]);
        and pp92(P8[7], X[7], Y[8]);
        and pp93(P8[6], X[6], Y[8]);
        and pp94(P8[5], X[5], Y[8]);
        and pp95(P8[4], X[4], Y[8]);
        and pp96(P8[3], X[3], Y[8]);
        and pp97(P8[2], X[2], Y[8]);
        and pp98(P8[1], X[1], Y[8]);
        and pp99(P8[0], X[0], Y[8]);
        and pp100(sum9[10], X[10], Y[9]);
        and pp101(P9[9], X[9], Y[9]);
        and pp102(P9[8], X[8], Y[9]);
        and pp103(P9[7], X[7], Y[9]);
        and pp104(P9[6], X[6], Y[9]);
        and pp105(P9[5], X[5], Y[9]);
        and pp106(P9[4], X[4], Y[9]);
        and pp107(P9[3], X[3], Y[9]);
        and pp108(P9[2], X[2], Y[9]);
        and pp109(P9[1], X[1], Y[9]);
        and pp110(P9[0], X[0], Y[9]);
        and pp111(sum10[10], X[10], Y[10]);
        and pp112(P10[9], X[9], Y[10]);
        and pp113(P10[8], X[8], Y[10]);
        and pp114(P10[7], X[7], Y[10]);
        and pp115(P10[6], X[6], Y[10]);
        and pp116(P10[5], X[5], Y[10]);
        and pp117(P10[4], X[4], Y[10]);
        and pp118(P10[3], X[3], Y[10]);
        and pp119(P10[2], X[2], Y[10]);
        and pp120(P10[1], X[1], Y[10]);
        and pp121(P10[0], X[0], Y[10]);

        // Array Reduction
        half_adder  HA1(carry1[9],sum1[9],P1[9],P0[10]);
        half_adder  HA2(carry1[8],sum1[8],P1[8],P0[9]);
        half_adder  HA3(carry1[7],sum1[7],P1[7],P0[8]);
        half_adder  HA4(carry1[6],sum1[6],P1[6],P0[7]);
        half_adder  HA5(carry1[5],sum1[5],P1[5],P0[6]);
        half_adder  HA6(carry1[4],sum1[4],P1[4],P0[5]);
        half_adder  HA7(carry1[3],sum1[3],P1[3],P0[4]);
        half_adder  HA8(carry1[2],sum1[2],P1[2],P0[3]);
        half_adder  HA9(carry1[1],sum1[1],P1[1],P0[2]);
        half_adder  HA10(carry1[0],sum1[0],P1[0],P0[1]);
        full_adder  FA1(carry2[9],sum2[9],P2[9],sum1[10],carry1[9]);
        full_adder  FA2(carry2[8],sum2[8],P2[8],sum1[9],carry1[8]);
        full_adder  FA3(carry2[7],sum2[7],P2[7],sum1[8],carry1[7]);
        full_adder  FA4(carry2[6],sum2[6],P2[6],sum1[7],carry1[6]);
        full_adder  FA5(carry2[5],sum2[5],P2[5],sum1[6],carry1[5]);
        full_adder  FA6(carry2[4],sum2[4],P2[4],sum1[5],carry1[4]);
        full_adder  FA7(carry2[3],sum2[3],P2[3],sum1[4],carry1[3]);
        full_adder  FA8(carry2[2],sum2[2],P2[2],sum1[3],carry1[2]);
        full_adder  FA9(carry2[1],sum2[1],P2[1],sum1[2],carry1[1]);
        full_adder  FA10(carry2[0],sum2[0],P2[0],sum1[1],carry1[0]);
        full_adder  FA11(carry3[9],sum3[9],P3[9],sum2[10],carry2[9]);
        full_adder  FA12(carry3[8],sum3[8],P3[8],sum2[9],carry2[8]);
        full_adder  FA13(carry3[7],sum3[7],P3[7],sum2[8],carry2[7]);
        full_adder  FA14(carry3[6],sum3[6],P3[6],sum2[7],carry2[6]);
        full_adder  FA15(carry3[5],sum3[5],P3[5],sum2[6],carry2[5]);
        full_adder  FA16(carry3[4],sum3[4],P3[4],sum2[5],carry2[4]);
        full_adder  FA17(carry3[3],sum3[3],P3[3],sum2[4],carry2[3]);
        full_adder  FA18(carry3[2],sum3[2],P3[2],sum2[3],carry2[2]);
        full_adder  FA19(carry3[1],sum3[1],P3[1],sum2[2],carry2[1]);
        full_adder  FA20(carry3[0],sum3[0],P3[0],sum2[1],carry2[0]);
        full_adder  FA21(carry4[9],sum4[9],P4[9],sum3[10],carry3[9]);
        full_adder  FA22(carry4[8],sum4[8],P4[8],sum3[9],carry3[8]);
        full_adder  FA23(carry4[7],sum4[7],P4[7],sum3[8],carry3[7]);
        full_adder  FA24(carry4[6],sum4[6],P4[6],sum3[7],carry3[6]);
        full_adder  FA25(carry4[5],sum4[5],P4[5],sum3[6],carry3[5]);
        full_adder  FA26(carry4[4],sum4[4],P4[4],sum3[5],carry3[4]);
        full_adder  FA27(carry4[3],sum4[3],P4[3],sum3[4],carry3[3]);
        full_adder  FA28(carry4[2],sum4[2],P4[2],sum3[3],carry3[2]);
        full_adder  FA29(carry4[1],sum4[1],P4[1],sum3[2],carry3[1]);
        full_adder  FA30(carry4[0],sum4[0],P4[0],sum3[1],carry3[0]);
        full_adder  FA31(carry5[9],sum5[9],P5[9],sum4[10],carry4[9]);
        full_adder  FA32(carry5[8],sum5[8],P5[8],sum4[9],carry4[8]);
        full_adder  FA33(carry5[7],sum5[7],P5[7],sum4[8],carry4[7]);
        full_adder  FA34(carry5[6],sum5[6],P5[6],sum4[7],carry4[6]);
        full_adder  FA35(carry5[5],sum5[5],P5[5],sum4[6],carry4[5]);
        full_adder  FA36(carry5[4],sum5[4],P5[4],sum4[5],carry4[4]);
        full_adder  FA37(carry5[3],sum5[3],P5[3],sum4[4],carry4[3]);
        full_adder  FA38(carry5[2],sum5[2],P5[2],sum4[3],carry4[2]);
        full_adder  FA39(carry5[1],sum5[1],P5[1],sum4[2],carry4[1]);
        full_adder  FA40(carry5[0],sum5[0],P5[0],sum4[1],carry4[0]);
        full_adder  FA41(carry6[9],sum6[9],P6[9],sum5[10],carry5[9]);
        full_adder  FA42(carry6[8],sum6[8],P6[8],sum5[9],carry5[8]);
        full_adder  FA43(carry6[7],sum6[7],P6[7],sum5[8],carry5[7]);
        full_adder  FA44(carry6[6],sum6[6],P6[6],sum5[7],carry5[6]);
        full_adder  FA45(carry6[5],sum6[5],P6[5],sum5[6],carry5[5]);
        full_adder  FA46(carry6[4],sum6[4],P6[4],sum5[5],carry5[4]);
        full_adder  FA47(carry6[3],sum6[3],P6[3],sum5[4],carry5[3]);
        full_adder  FA48(carry6[2],sum6[2],P6[2],sum5[3],carry5[2]);
        full_adder  FA49(carry6[1],sum6[1],P6[1],sum5[2],carry5[1]);
        full_adder  FA50(carry6[0],sum6[0],P6[0],sum5[1],carry5[0]);
        full_adder  FA51(carry7[9],sum7[9],P7[9],sum6[10],carry6[9]);
        full_adder  FA52(carry7[8],sum7[8],P7[8],sum6[9],carry6[8]);
        full_adder  FA53(carry7[7],sum7[7],P7[7],sum6[8],carry6[7]);
        full_adder  FA54(carry7[6],sum7[6],P7[6],sum6[7],carry6[6]);
        full_adder  FA55(carry7[5],sum7[5],P7[5],sum6[6],carry6[5]);
        full_adder  FA56(carry7[4],sum7[4],P7[4],sum6[5],carry6[4]);
        full_adder  FA57(carry7[3],sum7[3],P7[3],sum6[4],carry6[3]);
        full_adder  FA58(carry7[2],sum7[2],P7[2],sum6[3],carry6[2]);
        full_adder  FA59(carry7[1],sum7[1],P7[1],sum6[2],carry6[1]);
        full_adder  FA60(carry7[0],sum7[0],P7[0],sum6[1],carry6[0]);
        full_adder  FA61(carry8[9],sum8[9],P8[9],sum7[10],carry7[9]);
        full_adder  FA62(carry8[8],sum8[8],P8[8],sum7[9],carry7[8]);
        full_adder  FA63(carry8[7],sum8[7],P8[7],sum7[8],carry7[7]);
        full_adder  FA64(carry8[6],sum8[6],P8[6],sum7[7],carry7[6]);
        full_adder  FA65(carry8[5],sum8[5],P8[5],sum7[6],carry7[5]);
        full_adder  FA66(carry8[4],sum8[4],P8[4],sum7[5],carry7[4]);
        full_adder  FA67(carry8[3],sum8[3],P8[3],sum7[4],carry7[3]);
        full_adder  FA68(carry8[2],sum8[2],P8[2],sum7[3],carry7[2]);
        full_adder  FA69(carry8[1],sum8[1],P8[1],sum7[2],carry7[1]);
        full_adder  FA70(carry8[0],sum8[0],P8[0],sum7[1],carry7[0]);
        full_adder  FA71(carry9[9],sum9[9],P9[9],sum8[10],carry8[9]);
        full_adder  FA72(carry9[8],sum9[8],P9[8],sum8[9],carry8[8]);
        full_adder  FA73(carry9[7],sum9[7],P9[7],sum8[8],carry8[7]);
        full_adder  FA74(carry9[6],sum9[6],P9[6],sum8[7],carry8[6]);
        full_adder  FA75(carry9[5],sum9[5],P9[5],sum8[6],carry8[5]);
        full_adder  FA76(carry9[4],sum9[4],P9[4],sum8[5],carry8[4]);
        full_adder  FA77(carry9[3],sum9[3],P9[3],sum8[4],carry8[3]);
        full_adder  FA78(carry9[2],sum9[2],P9[2],sum8[3],carry8[2]);
        full_adder  FA79(carry9[1],sum9[1],P9[1],sum8[2],carry8[1]);
        full_adder  FA80(carry9[0],sum9[0],P9[0],sum8[1],carry8[0]);
        full_adder  FA81(carry10[9],sum10[9],P10[9],sum9[10],carry9[9]);
        full_adder  FA82(carry10[8],sum10[8],P10[8],sum9[9],carry9[8]);
        full_adder  FA83(carry10[7],sum10[7],P10[7],sum9[8],carry9[7]);
        full_adder  FA84(carry10[6],sum10[6],P10[6],sum9[7],carry9[6]);
        full_adder  FA85(carry10[5],sum10[5],P10[5],sum9[6],carry9[5]);
        full_adder  FA86(carry10[4],sum10[4],P10[4],sum9[5],carry9[4]);
        full_adder  FA87(carry10[3],sum10[3],P10[3],sum9[4],carry9[3]);
        full_adder  FA88(carry10[2],sum10[2],P10[2],sum9[3],carry9[2]);
        full_adder  FA89(carry10[1],sum10[1],P10[1],sum9[2],carry9[1]);
        full_adder  FA90(carry10[0],sum10[0],P10[0],sum9[1],carry9[0]);

        // Generate lower product bits YBITS
        buf b1(Z[0], P0[0]);
        assign Z[1] = sum1[0];
        assign Z[2] = sum2[0];
        assign Z[3] = sum3[0];
        assign Z[4] = sum4[0];
        assign Z[5] = sum5[0];
        assign Z[6] = sum6[0];
        assign Z[7] = sum7[0];
        assign Z[8] = sum8[0];
        assign Z[9] = sum9[0];
        assign Z[10] = sum10[0];

        // Final Carry Propagate Addition
        half_adder CPA1(carry11[0],Z[11],carry10[0],sum10[1]);
        full_adder CPA2(carry11[1],Z[12],carry10[1],carry11[0],sum10[2]);
        full_adder CPA3(carry11[2],Z[13],carry10[2],carry11[1],sum10[3]);
        full_adder CPA4(carry11[3],Z[14],carry10[3],carry11[2],sum10[4]);
        full_adder CPA5(carry11[4],Z[15],carry10[4],carry11[3],sum10[5]);
        full_adder CPA6(carry11[5],Z[16],carry10[5],carry11[4],sum10[6]);
        full_adder CPA7(carry11[6],Z[17],carry10[6],carry11[5],sum10[7]);
        full_adder CPA8(carry11[7],Z[18],carry10[7],carry11[6],sum10[8]);
        full_adder CPA9(carry11[8],Z[19],carry10[8],carry11[7],sum10[9]);
        full_adder CPA10(Z[21],Z[20],carry10[9],carry11[8],sum10[10]);

endmodule