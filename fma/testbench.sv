/* verilator lint_off STMTDLY */
module testbench_fma16();
   
   logic                clk;
   logic 		reset;
   logic [15:0] 	x, y, z, rexpected;
   logic [15:0] 	result;
   logic [7:0] 		ctrl;
   logic [3:0] 		flagsexpected;
   logic 		mul, add, negp, negz;
   logic [1:0] 		roundmode;
   logic [31:0] 	vectornum, errors;
   logic [75:0] 	testvectors[10000:0];

  // instantiate device under test
  fma16 dut(x, y, z, mul, add, negp, negz, roundmode, result);

  // generate clock
  always 
    begin
      clk = 1; #5; clk = 0; #5;
    end

  // at start of test, load vectors and pulse reset
  initial
    begin
      $readmemh("work/fmul_0.tv", testvectors);
      vectornum = 0; errors = 0;
      reset = 1; #22; reset = 0;
    end

  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1; {x, y, z, ctrl, rexpected, flagsexpected} = testvectors[vectornum];
      {roundmode, mul, add, negp, negz} = ctrl[5:0];
    end

   // check results on falling edge of clk
   always @(negedge clk)
     if (~reset) begin // skip during reset
	// check result     
	// *** should also add tests on flags eventually	
	if (result !== rexpected) begin  
           $display("Error: inputs %h * %h + %h", x, y, z);
           $display("  result = %h (%h expected)", result, rexpected);
           errors = errors + 1;
	end
	vectornum = vectornum + 1;
	if (testvectors[vectornum] === 'x) begin 
           $display("%d tests completed with %d errors", 
	            vectornum, errors);
           $stop;
	end
     end // if (~reset)
   
endmodule // testbench_fma16

