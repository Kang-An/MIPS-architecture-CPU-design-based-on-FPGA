`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:38:31 07/01/2015 
// Design Name: 
// Module Name:    ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ALU(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [4:0] ALUCtr,
    output Zero,
    output reg[31:0] ALURes // ALU������
    );
reg[31:0] HI;
reg[31:0] LO;
reg OverFlow;
reg [31:0] i;
reg j;
reg [31:0] TmpForSrcB;
reg [64:0] A;
reg [64:0] B;
reg [64:0] Temp;
reg [31:0] TmpForSrcA;
assign Zero = (ALURes == 0)? 1:0;//ALURes 0 ��ת
always @(SrcA or SrcB or ALUCtr)
begin 
	OverFlow = 0;	
	TmpForSrcB = 0;
	HI = 0;
	LO = 0;
	A = 0;
	B = 0;
	case(ALUCtr)	
		5'b00000: ALURes = SrcA & SrcB;
		5'b00001: ALURes = SrcA | SrcB;
		5'b00010: ALURes = SrcA + SrcB;
		5'b00011: // my div
		begin
			ALURes = SrcA / SrcB;
			LO = SrcA / SrcB;
			HI = SrcA % SrcB;
		end	
			
		5'b00100: // my mul
		begin
			A = SrcA[31:31]?{32'hffffffff, SrcA} : {32'h00000000, SrcA};
			B = SrcB[31:31]?{32'hffffffff, SrcB} : {32'h00000000, SrcB};
			Temp = A * B ;
			ALURes = Temp[31:0];
			HI = Temp[63:32];
			LO = Temp[31:0];
		end
		
		5'b00101: ALURes = (SrcB << SrcA);  // my : sllv (�߼��ɱ�����)
		5'b00110: ALURes = SrcA - SrcB;
		5'b00111: ALURes = SrcA < SrcB ? 1:0;
		5'b01000: ALURes = (SrcB >> SrcA);  // my : srav (�߼��ɱ�����)
		5'b01001: ALURes = (SrcA ^ SrcB);  // my : xor
		5'b01010: ALURes = {1'b0,SrcA} <{1'b0, SrcB}? 1:0;
		
		5'b01011:
		begin
			j = SrcB[31:31];
			TmpForSrcB = SrcB;
			TmpForSrcA = SrcA;
			/*
			for(i = 0; i < TmpForSrcA; i = i+1)
			begin
				ALURes = {j,31'h0} | (ALURes >> 1);	                
			end
			*/
			TmpForSrcB = TmpForSrcB>>SrcA;
			if (j)
			begin
				ALURes = {~(TmpForSrcB[31:31]), TmpForSrcB[30:0]};
			end
			else
			begin
				ALURes = TmpForSrcB;
			end
			/*
			i = 0;
			while(i < TmpForSrcA)
			begin
				ALURes = {j,31'h0} | (ALURes >> 1);	 
				i = i + 1;
			end
			*/
		end
		
		5'b01100: ALURes = ~(SrcA | SrcB);
		5'b01101: ALURes = ~(SrcA - SrcB);
		5'b01110: ALURes = (SrcA >= 0)?0:1;
		5'b01111: ALURes = (SrcA >0)?0:1;
		5'b10000: ALURes = (SrcA <= 0)?0:1;
		5'b10001: ALURes = (SrcA < 0)?0:1;
		5'b10010: 
		begin
			ALURes = SrcA + SrcB;
			if ((SrcA[31] != SrcB[31]) || (SrcA[31] == SrcB[31] && ALURes[31] == SrcA[31]))
				begin
					OverFlow = 1'b0;
				end
			else 
				if (SrcA[31] == SrcB[31] && ALURes[31] != SrcA[31])
				begin
					OverFlow = 1'b1;
				end
		end
		5'b10011: 
		begin
			TmpForSrcB = SrcB;
			TmpForSrcB[31] = (TmpForSrcB[31]+1)%2;
			ALURes = SrcA + TmpForSrcB;
			if ((SrcA[31] != TmpForSrcB[31]) || (SrcA[31] == TmpForSrcB[31] && ALURes[31] == SrcA[31]))
				begin
					OverFlow = 1'b0;
				end
			else 
				if (SrcA[31] == TmpForSrcB[31] && ALURes[31] != SrcA[31])
				begin
					OverFlow = 1'b1;
				end
		end
		5'b10100:
		begin
			ALURes = {1'b0,SrcA} / {1'b0,SrcB};
			LO = {1'b0,SrcA} / {1'b0,SrcB};
			HI = {1'b0,SrcA} % {1'b0,SrcB};
		end
		
		5'b10101:
		begin
			Temp ={32'b0,SrcA}*{32'b0,SrcB};
			HI = Temp[63:32];
			LO = Temp[31:0];
			ALURes = Temp[31:0];
		end
		
		default: ALURes = 32'h0;
	endcase
end

endmodule
