//Subject:     CO project 4 - Pipe CPU 1
//--------------------------------------------------------------------------------
//Version:     1
module Pipe_CPU_1(
        clk_i,
		rst_n,
		instr_o,//register
		datamemory_o,
		pc_in_o,
		mem
		);   
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_n;
input [32-1:0] instr_o;
input	[31:0] 	datamemory_o;
output [32-1:0] pc_in_o;
output [107-1:0] mem;
/****************************************
Internal signal
****************************************/
/**** IF stage ****/
wire [32-1:0] pc_in_i;//1
wire [32-1:0] pc_in_o;

wire [32-1:0] sum_o;//2
wire [32-1:0] instr_o;//3
wire pcwrite;
/**** ID stage ****/
wire [64-1:0] if_o;
wire [32-1:0] RSdata_o;//reg
wire [32-1:0] RTdata_o; 
wire [31:0] sign;//after sign extend
wire    [3-1:0] ALU_op_o;//6decoder
wire            ALUSrc_o;
wire            RegWrite_o;//wb
wire 			memtoreg;//wb
wire            RegDst_o;
wire            Branch_o;
//wire 			jump_o;
//wire 	[2-1:0]	branchtype_o;

wire 			memread;
wire 			memwrite;
//control signal


/**** EX stage ****/
wire [153-1:0] ex;//id/ex output
//control signal
wire [32-1:0] alu_i;//mux1,alu
wire        [4-1:0] ALUCtrl_o;
wire    [32-1:0]  result_o;//9ALU
wire zero_o;
wire [5-1:0] Rd;//destination address
wire [31:0] signshift;//sign shift
wire [31:0] pc_sum;//adder2
/**** MEM stage ****/
wire [107-1:0] mem;
//control signal
wire	[31:0] 		datamemory_o;

/**** WB stage ****/
wire [71-1:0] wb;
//control signal
wire [32-1:0] RDdata_i;
wire sel;//to and
wire [10-1:0] muxcontrol;
wire [2-1:0] forwarda;
wire [2-1:0] forwardb;

/****************************************
Instnatiate modules
****************************************/
//Instantiate the components in IF stage
MUX_2to1 #(.size(32)) Mux4(
		.data0_i(sum_o),
        .data1_i(mem[101:70]),
        .select_i(sel),
        .data_o(pc_in_i)
        );
ProgramCounter PC(
	.clk_i(clk_i),      
	.rst_i (rst_n), 
	.pcwrite(pcwrite),
	.pc_in_i(pc_in_i) ,   
	.pc_out_o(pc_in_o) 
        );//check

/*Instruction_Memory IM(
        .addr_i(pc_in_o),  
	    .instr_o(instr_o)   
	    );//check*/
			
Adder Add_pc(
        .src1_i(pc_in_o),     
	    .src2_i(32'd4),     
	    .sum_o(sum_o)   
		);//check
wire ifidwrite;
wire exflush;wire flush;//flush if/id	
hazard h(
				.sel(sel),
               .idrs(if_o[25:21]),
			   .idrt(if_o[20:16]),
			   .exrt(ex[9:5]),
			   .exmemread(ex[149]),
			   .pcwrite(pcwrite),
			   .ifidwrite(ifidwrite),
			   .muxctrl(muxctrl),.flush(flush),
			   .exflush(exflush)
               );
		
		   
IF_ID IF(       //N is the total length of input/output
			.flush(flush),
			.ifidwrite(ifidwrite),
            .rst_i(rst_n),
			.clk_i(clk_i),   
			.data_i({sum_o,instr_o}),
			.data_o(if_o)
		);
		
//Instantiate the components in ID stage
Reg_File RF(
		.clk_i(clk_i),      
	    .rst_n(rst_n) ,     
        .RSaddr_i(if_o[25:21]) ,  
        .RTaddr_i(if_o[20:16]) ,  
        .RDaddr_i(wb[4:0]) , 
        .RDdata_i(RDdata_i)  , 
        .RegWrite_i (wb[70]),///----------------------
        .RSdata_o(RSdata_o) ,  
        .RTdata_o(RTdata_o)  
		);

Decoder Control(
		.instr_op_i(if_o[31:26]), 
	    .RegWrite_o(RegWrite_o), 
	    .ALU_op_o(ALU_op_o),   
	    .ALUSrc_o(ALUSrc_o),   
	    .RegDst_o(RegDst_o),   
		.Branch_o(Branch_o),	
		.memtoreg(memtoreg),
		.memread(memread),
		.memwrite(memwrite)	
		);

MUX_2to1 #(.size(10)) Mux7(
		.data0_i(10'd0),
        .data1_i({RegWrite_o,memtoreg,Branch_o,memread,memwrite
,RegDst_o,ALU_op_o,ALUSrc_o}),
        .select_i(muxctrl),
        .data_o(muxcontrol)
        );
Sign_Extend Sign_Extend(
		.data_i(if_o[15:0]),
        .data_o(sign)
		);	

Pipe_Reg #(.size(153)) ID_EX(
			.rst_i(rst_n),
			.clk_i(clk_i),   
.data_i({muxcontrol,if_o[63:32]
,RSdata_o,RTdata_o,sign,if_o[25:21],if_o[20:16],if_o[15:11]}),
			.data_o(ex)
		);
wire [32-1:0] src1;
wire [32-1:0] src2;
MUX_3to1 #(.size(32))Mux5(
               .data0_i(ex[110:79]),
               .data1_i(RDdata_i),
			   .data2_i(mem[68:37]),//----------
               .select_i(forwarda),
               .data_o(src1)
               );

MUX_3to1 #(.size(32)) Mux6(
               .data0_i(ex[78:47]),
               .data1_i(RDdata_i),
			   .data2_i(mem[68:37]),//--------------
               .select_i(forwardb),
               .data_o(src2)
               );	
MUX_2to1 #(.size(32)) Mux1(
		.data0_i(src2),
        .data1_i(ex[46:15]),
        .select_i(ex[143]),
        .data_o(alu_i)
        );		   
		
//Instantiate the components in EX stage	   
ALU ALU(
		.rst_n(rst_n),
		.src1_i(src1),
	    .src2_i(alu_i),
	    .ctrl_i(ALUCtrl_o),
	    .result_o(result_o),
		.zero_o(zero_o)
		);
		
ALU_Ctrl ALU_Control(
		.funct_i(ex[20:15]),  //notice!! 
        .ALUOp_i(ex[146:144]),   
        .ALUCtrl_o(ALUCtrl_o)
		);
		
MUX_2to1 #(.size(5)) Mux2(
		.data0_i(ex[9:5]),
        .data1_i(ex[4:0]),
        .select_i(ex[147]),
        .data_o(Rd)
        );
Shift_Left_Two_32 Shifter1(
        .data_i(ex[46:15]),
        .data_o(signshift)
        ); //add
Adder Adder2(
        .src1_i(ex[142:111]),     
	    .src2_i(signshift),     
	    .sum_o(pc_sum)      
	    );//add 
forward fa(
            .memrd(mem[4:0]),
			.wbrd(wb[4:0]),
			.exrs(ex[14:10]),
			.exrt(ex[9:5]),
			.memwb(mem[106]),
			.wbwb(wb[70]),
			.forwarda(forwarda),
			.forwardb(forwardb)
               );
wire [5-1:0] exmux;
MUX_2to1 #(.size(5)) Mux9(
		.data0_i(5'd0),
        .data1_i(ex[152:148]),
        .select_i(exflush),
        .data_o(exmux)
        );	
Pipe_Reg #(.size(107)) EX_MEM(
			.rst_i(rst_n),
			.clk_i(clk_i),   
			.data_i({exmux,pc_sum,zero_o,result_o,src2,Rd}),
			.data_o(mem)
		);
			   
//Instantiate the components in MEM stage
/*Data_Memory DM(
		.clk_i(clk_i),
		.addr_i(mem[68:37]),
		.data_i(mem[36:5]),
		.MemRead_i(mem[103:103]),
		.MemWrite_i(mem[102:102]),
		.data_o(datamemory_o)
	    );*/

assign sel=mem[69]&mem[104];
Pipe_Reg #(.size(71)) MEM_WB(
			.rst_i(rst_n),
			.clk_i(clk_i),   
			.data_i({mem[106:105],datamemory_o,mem[68:37],mem[4:0]}),
			.data_o(wb)
		);

//Instantiate the components in WB stage
MUX_2to1 #(.size(32)) Mux3(
		.data0_i(wb[36:5]),
        .data1_i(wb[68:37]),
        .select_i(wb[69:69]),
        .data_o(RDdata_i)
        );

/****************************************
signal assignment
****************************************/	
endmodule

