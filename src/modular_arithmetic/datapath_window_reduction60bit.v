`timescale 1ns / 1ps

/*
	Modular reduction circuitry by: https://github.com/KULeuven-COSIC/HEAT (modified)
*/

module windowed_reduction60bit (
	input clk, 
	input [59:0]in, 
	output reg [29:0]out);

	parameter modular_index = 0;

	wire [53:0] w1 = in[53:0];
	wire [29:0] T1_out, T2_out, T3_out, T4_out, T5_out, T6_out;

	generate
		if (modular_index==4'd0)
			reduction_table_q1063321601 T1(in[59:54], T1_out);
		else if (modular_index==4'd1)
			reduction_table_q1063452673 T1(in[59:54], T1_out);
		else if (modular_index==4'd2)
			reduction_table_q1064697857 T1(in[59:54], T1_out);
		else if (modular_index==4'd3)
			reduction_table_q1065484289 T1(in[59:54], T1_out);
		else if (modular_index==4'd4)
			reduction_table_q1065811969 T1(in[59:54], T1_out);
		else if (modular_index==4'd5)
			reduction_table_q1068236801 T1(in[59:54], T1_out);
		else if (modular_index==4'd6)
			reduction_table_q1068433409 T1(in[59:54], T1_out);
		else if (modular_index==4'd7)
			reduction_table_q1068564481 T1(in[59:54], T1_out);
		else if (modular_index==4'd8)
			reduction_table_q1069219841 T1(in[59:54], T1_out);
		else if (modular_index==4'd9)
			reduction_table_q1070727169 T1(in[59:54], T1_out);
		else if (modular_index==4'd10)
			reduction_table_q1071513601 T1(in[59:54], T1_out);
		else if (modular_index==4'd11)
			reduction_table_q1072496641 T1(in[59:54], T1_out);
		else
			reduction_table_q1073479681 T1(in[59:54], T1_out);
	endgenerate

	wire [54:0] w2 = w1 + (T1_out<<6'd24);
	wire [48:0] w3 = w2[48:0];

	//-----------------------------------------------------------------------------

	generate
		if (modular_index==4'd0)
			reduction_table_q1063321601 T2(w2[54:49], T2_out);
		else if (modular_index==4'd1)
			reduction_table_q1063452673 T2(w2[54:49], T2_out);
		else if (modular_index==4'd2)
			reduction_table_q1064697857 T2(w2[54:49], T2_out);
		else if (modular_index==4'd3)
			reduction_table_q1065484289 T2(w2[54:49], T2_out);
		else if (modular_index==4'd4)
			reduction_table_q1065811969 T2(w2[54:49], T2_out);
		else if (modular_index==4'd5)
			reduction_table_q1068236801 T2(w2[54:49], T2_out);
		else if (modular_index==4'd6)
			reduction_table_q1068433409 T2(w2[54:49], T2_out);
		else if (modular_index==4'd7)
			reduction_table_q1068564481 T2(w2[54:49], T2_out);
		else if (modular_index==4'd8)
			reduction_table_q1069219841 T2(w2[54:49], T2_out);
		else if (modular_index==4'd9)
			reduction_table_q1070727169 T2(w2[54:49], T2_out);
		else if (modular_index==4'd10)
			reduction_table_q1071513601 T2(w2[54:49], T2_out);
		else if (modular_index==4'd11)
			reduction_table_q1072496641 T2(w2[54:49], T2_out);
		else
			reduction_table_q1073479681 T2(w2[54:49], T2_out);
	endgenerate

	wire [49:0] w4_wire = w3 + (T2_out<<6'd19);
	reg [49:0] w4;

	always @(posedge clk) w4 <= w4_wire;

	wire [43:0] w5 = w4[43:0];

	//-----------------------------------------------------------------------------

	generate
		if (modular_index==4'd0)
			reduction_table_q1063321601 T3(w4[49:44], T3_out);
		else if (modular_index==4'd1)
			reduction_table_q1063452673 T3(w4[49:44], T3_out);
		else if (modular_index==4'd2)
			reduction_table_q1064697857 T3(w4[49:44], T3_out);
		else if (modular_index==4'd3)
			reduction_table_q1065484289 T3(w4[49:44], T3_out);
		else if (modular_index==4'd4)
			reduction_table_q1065811969 T3(w4[49:44], T3_out);
		else if (modular_index==4'd5)
			reduction_table_q1068236801 T3(w4[49:44], T3_out);
		else if (modular_index==4'd6)
			reduction_table_q1068433409 T3(w4[49:44], T3_out);
		else if (modular_index==4'd7)
			reduction_table_q1068564481 T3(w4[49:44], T3_out);
		else if (modular_index==4'd8)
			reduction_table_q1069219841 T3(w4[49:44], T3_out);
		else if (modular_index==4'd9)
			reduction_table_q1070727169 T3(w4[49:44], T3_out);
		else if (modular_index==4'd10)
			reduction_table_q1071513601 T3(w4[49:44], T3_out);
		else if (modular_index==4'd11)
			reduction_table_q1072496641 T3(w4[49:44], T3_out);
		else
			reduction_table_q1073479681 T3(w4[49:44], T3_out);
	endgenerate

	wire [44:0] w6 = w5 + (T3_out<<6'd14);
	wire [38:0] w7 = w6[38:0];

	//-----------------------------------------------------------------------------

	generate
		if (modular_index==4'd0)
			reduction_table_q1063321601 T4(w6[44:39], T4_out);
		else if (modular_index==4'd1)
			reduction_table_q1063452673 T4(w6[44:39], T4_out);
		else if (modular_index==4'd2)
			reduction_table_q1064697857 T4(w6[44:39], T4_out);
		else if (modular_index==4'd3)
			reduction_table_q1065484289 T4(w6[44:39], T4_out);
		else if (modular_index==4'd4)
			reduction_table_q1065811969 T4(w6[44:39], T4_out);
		else if (modular_index==4'd5)
			reduction_table_q1068236801 T4(w6[44:39], T4_out);
		else if (modular_index==4'd6)
			reduction_table_q1068433409 T4(w6[44:39], T4_out);
		else if (modular_index==4'd7)
			reduction_table_q1068564481 T4(w6[44:39], T4_out);
		else if (modular_index==4'd8)
			reduction_table_q1069219841 T4(w6[44:39], T4_out);
		else if (modular_index==4'd9)
			reduction_table_q1070727169 T4(w6[44:39], T4_out);
		else if (modular_index==4'd10)
			reduction_table_q1071513601 T4(w6[44:39], T4_out);
		else if (modular_index==4'd11)
			reduction_table_q1072496641 T4(w6[44:39], T4_out);
		else
			reduction_table_q1073479681 T4(w6[44:39], T4_out);
	endgenerate

	wire [39:0] w8 = w7 + (T4_out<<6'd9);
	wire [33:0] w9 = w8[33:0];

	//-----------------------------------------------------------------------------

	generate
		if (modular_index==4'd0)
			reduction_table_q1063321601 T5(w8[39:34], T5_out);
		else if (modular_index==4'd1)
			reduction_table_q1063452673 T5(w8[39:34], T5_out);
		else if (modular_index==4'd2)
			reduction_table_q1064697857 T5(w8[39:34], T5_out);
		else if (modular_index==4'd3)
			reduction_table_q1065484289 T5(w8[39:34], T5_out);
		else if (modular_index==4'd4)
			reduction_table_q1065811969 T5(w8[39:34], T5_out);
		else if (modular_index==4'd5)
			reduction_table_q1068236801 T5(w8[39:34], T5_out);
		else if (modular_index==4'd6)
			reduction_table_q1068433409 T5(w8[39:34], T5_out);
		else if (modular_index==4'd7)
			reduction_table_q1068564481 T5(w8[39:34], T5_out);
		else if (modular_index==4'd8)
			reduction_table_q1069219841 T5(w8[39:34], T5_out);
		else if (modular_index==4'd9)
			reduction_table_q1070727169 T5(w8[39:34], T5_out);
		else if (modular_index==4'd10)
			reduction_table_q1071513601 T5(w8[39:34], T5_out);
		else if (modular_index==4'd11)
			reduction_table_q1072496641 T5(w8[39:34], T5_out);
		else
			reduction_table_q1073479681 T5(w8[39:34], T5_out);
	endgenerate

	wire [34:0] w10_wire = w9 + (T5_out<<6'd4);
	reg [34:0] w10;

	always @(posedge clk) w10 <= w10_wire;

	wire [29:0] w11 = w10[29:0];

	//-----------------------------------------------------------------------------

	generate
		if (modular_index==4'd0)
			reduction_table_q1063321601 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd1)
			reduction_table_q1063452673 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd2)
			reduction_table_q1064697857 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd3)
			reduction_table_q1065484289 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd4)
			reduction_table_q1065811969 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd5)
			reduction_table_q1068236801 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd6)
			reduction_table_q1068433409 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd7)
			reduction_table_q1068564481 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd8)
			reduction_table_q1069219841 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd9)
			reduction_table_q1070727169 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd10)
			reduction_table_q1071513601 T6({1'b0,w10[34:30]}, T6_out);
		else if (modular_index==4'd11)
			reduction_table_q1072496641 T6({1'b0,w10[34:30]}, T6_out);
		else
			reduction_table_q1073479681 T6({1'b0,w10[34:30]}, T6_out);
	endgenerate

	wire [30:0] w12 = w11 + T6_out;
	wire [31:0] w13, w14;

	//-----------------------------------------------------------------------------

	generate
		if (modular_index==4'd0)
			begin
				assign w13 = w12 - 30'd1063321601;
				assign w14 = w12 - {30'd1063321601, 1'b0};
			end
		else if (modular_index==4'd1)
			begin
				assign w13 = w12 - 30'd1063452673;
				assign w14 = w12 - {30'd1063452673, 1'b0};
			end
		else if (modular_index==4'd2)
			begin
				assign w13 = w12 - 30'd1064697857;
				assign w14 = w12 - {30'd1064697857, 1'b0};
			end
		else if (modular_index==4'd3)
			begin
				assign w13 = w12 - 30'd1065484289;
				assign w14 = w12 - {30'd1065484289, 1'b0};
			end
		else if (modular_index==4'd4)
			begin
				assign w13 = w12 - 30'd1065811969;
				assign w14 = w12 - {30'd1065811969, 1'b0};
			end
		else if (modular_index==4'd5)
			begin
				assign w13 = w12 - 30'd1068236801;
				assign w14 = w12 - {30'd1068236801, 1'b0};
			end
		else if (modular_index==4'd6)
			begin
				assign w13 = w12 - 30'd1068433409;
				assign w14 = w12 - {30'd1068433409, 1'b0};
			end
		else if (modular_index==4'd7)
			begin
				assign w13 = w12 - 30'd1068564481;
				assign w14 = w12 - {30'd1068564481, 1'b0};
			end
		else if (modular_index==4'd8)
			begin
				assign w13 = w12 - 30'd1069219841;
				assign w14 = w12 - {30'd1069219841, 1'b0};
			end
		else if (modular_index==4'd9)
			begin
				assign w13 = w12 - 30'd1070727169;
				assign w14 = w12 - {30'd1070727169, 1'b0};
			end
		else if (modular_index==4'd10)
			begin
				assign w13 = w12 - 30'd1071513601;
				assign w14 = w12 - {30'd1071513601, 1'b0};
			end
		else if (modular_index==4'd11)
			begin
				assign w13 = w12 - 30'd1072496641;
				assign w14 = w12 - {30'd1072496641, 1'b0};
			end
		else if (modular_index==4'd12)
			begin
				assign w13 = w12 - 30'd1073479681;
				assign w14 = w12 - {30'd1073479681, 1'b0};
			end
	endgenerate

	wire [29:0] out_wire = (w14[31]==1'b0) ? w14[29:0]
								:(w13[31]==1'b0) ? w13[29:0]
								:w12[29:0];	
		
	always @(posedge clk) out <= out_wire;
	
endmodule
