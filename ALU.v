//Subject:     CO project 1 - ALU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU(
	rst_n,
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
//I/O ports
input rst_n;
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;

//Internal signals
reg    [32-1:0]  result_o;
wire             zero_o;

//Parameter
reg zero;

//Main function
/*your code here*/
always@(*)begin
	if(rst_n==0)begin
		result_o=32'd0;zero=0;
	end
	else begin
	case(ctrl_i)
		4'b0000:begin//and
			result_o=src1_i&src2_i;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
		4'b0001:begin//or
			result_o=src1_i|src2_i;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
			
		end
		4'b0010:begin//add
			result_o=src1_i+src2_i;
			if(src1_i==32'd0&&src2_i==32'd0)zero=1;
			else if(src2_i[31]==1&&src1_i[31]==0&&src1_i==~(src2_i-1))zero=1;//+=-
			else if(src1_i[31]==1&&src2_i[31]==0&&src2_i==~(src1_i-1))zero=1;
			else
			zero=0;
		end
		4'b0110:begin//sub
			if(src1_i[31]==0&&src2_i[31]==0&&src1_i==src2_i)begin result_o=src1_i-src2_i;zero=1;end//+=+
			else if(src1_i[31]==0&&src2_i[31]==0)begin result_o=src1_i-src2_i;zero=0;end//++
			else if(src1_i[31]==1&&src2_i[31]==0)begin//-+
				result_o=src1_i+(~src2_i)+1;zero=0;
			end
			else if(src1_i[31]==0&&src2_i[31]==1)begin//-+
				result_o=src1_i+(~(src2_i-1));
				if(src1_i==~(src2_i-1))zero=1;
				else zero=0;
			end
			else begin//--
				result_o=src1_i-src2_i;
				if(src1_i==src2_i)zero=1;
				else
				zero=0;
			end
		end
		4'b1100:begin//nor
			result_o=~(src1_i|src2_i);
			if(result_o==32'd0)zero=1;
			else
			zero=0;
			
		end
		4'b1101:begin//nand
			result_o=~(src1_i&src2_i);
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
		4'b0111:begin//slt
			if(src1_i[31]==1&&src2_i[31]==0)result_o=32'd1;//-<+yes
			else if(src1_i[31]==0&&src2_i[31]==1)result_o=32'd0;//+<-no
			else if(src1_i<src2_i)result_o=32'd1;
			else result_o=32'd0;
			if(result_o==32'd0)zero=1;
			else
			zero=0;//----------------
		end
		4'b1000:begin//sgt
			if(src1_i[31]==1&&src2_i[31]==0)result_o=32'd0;//->+no
			else if(src1_i[31]==0&&src2_i[31]==1)result_o=32'd1;//+>-yes
			else if(src1_i>src2_i)result_o=32'd1;
			else result_o=32'd0;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
		4'b1001:begin//sle
			if(src1_i[31]==1&&src2_i[31]==0)result_o=32'd1;//-<=+yes
			else if(src1_i[31]==0&&src2_i[31]==1)result_o=32'd0;//+<=-no
			else if(src1_i<=src2_i)result_o=32'd1;
			else result_o=32'd0;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
		4'b1010:begin//sge
			if(src1_i[31]==1&&src2_i[31]==0)result_o=32'd0;//->=+no
			else if(src1_i[31]==0&&src2_i[31]==1)result_o=32'd1;//+>=-yes
			else if(src1_i>=src2_i)result_o=32'd1;
			else result_o=32'd0;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
		4'b1011:begin//seq
			if(src1_i==src2_i)result_o=32'd1;
			else result_o=32'd0;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
		4'b1110:begin//sne
			if(src1_i!=src2_i)result_o=32'd1;
			else result_o=32'd0;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
		4'b0011:begin//mult
			if(src1_i==32'd0||src2_i==32'd0)begin result_o=32'd0;zero=1;end
			else if(src1_i[31]==1&&src2_i[31]==0)begin result_o=~((~(src1_i-1))*src2_i)+1;zero=0;end
			else if(src1_i[31]==0&&src2_i[31]==1)begin result_o=~((~(src2_i-1))*src1_i)+1;zero=0;end
			else if(src1_i[31]==1&&src2_i[31]==1)begin result_o=(~(src1_i-1))*(~(src2_i-1));zero=0;end
			else begin result_o=src1_i*src2_i; zero=0;end
		end
		4'b0100:begin//seqz
			if(src1_i==32'd0&&src2_i==32'd0)result_o=32'd1;
			else result_o=32'd0;
			if(result_o==32'd0)zero=1;
			else
			zero=0;
		end
	
	endcase	
	end
end
assign zero_o=zero;
endmodule

