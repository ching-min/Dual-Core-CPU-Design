//Subject:     CO project 2 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//-----------------------------------7---------------------------------------------

module ALU_Ctrl(
          funct_i,
          ALUOp_i,
          ALUCtrl_o
          );
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter

       
//Select exact operation
always@(*)begin
	if(ALUOp_i==3'b110)//addi
		ALUCtrl_o=4'b0010;
	else if(ALUOp_i==3'b111)//slti
		ALUCtrl_o=4'b0111;
	else if(ALUOp_i==3'b001)//beq
		ALUCtrl_o=4'b0110;
	else if(ALUOp_i==3'b000)//lw,sw
		ALUCtrl_o=4'b0010;
	else begin
		case(funct_i[3:0])
		4'b0100:ALUCtrl_o=4'b0000;//and
		4'b0101:ALUCtrl_o=4'b0001;//or
		4'b0000:ALUCtrl_o=4'b0010;//add
		4'b0010:ALUCtrl_o=4'b0110;//sub
		4'b1010:ALUCtrl_o=4'b0111;//slt
		4'b1000:ALUCtrl_o=4'b0011;//mul
		endcase
	end
end
endmodule     





                    
                    