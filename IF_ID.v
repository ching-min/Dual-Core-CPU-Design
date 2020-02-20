module IF_ID(
			flush,
			ifidwrite,
            rst_i,
			clk_i,   
			data_i,
			data_o
);
					
input                    flush;
input                    ifidwrite;
input                    rst_i;
input                    clk_i;		  
input      [64-1: 0] data_i;
output reg [64-1: 0] data_o;
	  
always @(posedge clk_i or negedge  rst_i) begin
	if( rst_i == 0) data_o <= 0;
    
	else if(ifidwrite)
		data_o <= data_i;
end

endmodule