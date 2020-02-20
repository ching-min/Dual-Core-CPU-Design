module forward(
               memrd,wbrd,exrs,exrt,memwb,wbwb,forwarda,forwardb
               );	   
			
//I/O ports               
input   [5-1:0] memrd;          
input   [5-1:0] wbrd;
input   [5-1:0] exrs;
input   [5-1:0] exrt;
input	memwb,wbwb;
output  [2-1:0] forwarda; 
output  [2-1:0] forwardb;

//Internal Signals
reg  [2-1:0] forwarda; 
reg  [2-1:0] forwardb;

//Main function
always@(*)begin
	if((memwb)&&(memrd!=0)&&(memrd==exrs))
	forwarda=2'b10;
	else if((wbwb)&&(wbrd!=0)&&(wbrd==exrs))
	forwarda=2'b01;
	else
	forwarda=2'b00;
	
	if((memwb)&&(memrd!=0)&&(memrd==exrt))
	forwardb=2'b10;
	else if((wbwb)&&(wbrd!=0)&&(wbrd==exrt))
	forwardb=2'b01;
	else
	forwardb=2'b00;
end
endmodule