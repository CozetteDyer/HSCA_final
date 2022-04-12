module lzd #(parameter WIDTH=64) 
   (Sum, NormCnt, Valid);

   input logic [WIDTH-1:0]          Sum;
   
   output logic 		    Valid;   
   output logic [$clog2(WIDTH)-1:0] NormCnt;
   
   // LZD : behavior?
   logic [$clog2(WIDTH)-1:0] 	    i;
   always_comb begin
      i = 0;
      while (~Sum[WIDTH-1-i] && $unsigned(i) <= $unsigned(WIDTH-1)) 
	i = i+1;  
      NormCnt = i;    // compute shift count
   end
   assign Valid = |Sum;   

endmodule // lzd
