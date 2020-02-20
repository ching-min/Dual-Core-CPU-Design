module hazard(
				sel,
               idrs,
			   idrt,
			   exrt,
			   exmemread,
			   pcwrite,
			   ifidwrite,
			   muxctrl,
			   flush,
			   exflush
               );

parameter size = 0;			   
			
//I/O ports  
input sel;             
input   [5-1:0] idrs;          
input   [5-1:0] idrt; 
input   [5-1:0] exrt; 
input   exmemread;
output reg muxctrl; 
output reg pcwrite;
output  reg ifidwrite;
output reg flush;
output reg exflush;
//Internal Signals
//reg     [size-1:0] data_o;

//Main function
always@(*)begin
	if(exmemread&&((exrt==idrs)||(exrt==idrt)))begin
		//stall
		pcwrite=1'b0;
		ifidwrite=1'b0;
		muxctrl=1'b0;
		flush=1'b1;
		exflush=1'b1;
		
	end
	else if(sel)begin
		pcwrite=1'b1;
		ifidwrite=1'b1;
		muxctrl=1'b0;
		flush=1'b0;
		exflush=1'b0;
		end
	else begin
		pcwrite=1'b1;
		ifidwrite=1'b1;
		muxctrl=1'b1;
		flush=1'b1;
		exflush=1'b1;
	end
end
endmodule