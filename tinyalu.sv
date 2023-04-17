
typedef enum int unsigned {
	OP_MUL=0,
	OP_DIV,
	OP_ADD,
	OP_SUB,
	OP_SLL,
	OP_SRL,
	OP_SLT,
	OP_AND,
	OP_OR,
	OP_XOR
} op_name;


module tinyalu #(
	parameter OP_WIDTH = 5,
	parameter DELAY = 3
)(
	input					clk,
	input					rst_n,
	input [31:0]			in1,
	input [31:0]			in2,
	input [OP_WIDTH-1:0]    op,
	input					valid,
	output					ready,
	output	[31:0]			result,
	output					done
);


logic[31:0] result_r, result_rc;
logic done_rc, done_r;
logic [DELAY-1:0] delay_r, delay_rc;

always_comb begin
	done_rc = delay_rc[0];
	if (|delay_r[DELAY-1:1]) begin
		delay_rc = {1'h0, delay_r[DELAY-1:1]};
	end else begin
		if (op[OP_MUL] | op[OP_DIV]) begin
			delay_rc[DELAY-1] = 1'h1;
			result_rc = op[OP_MUL] ? in1*in2 : in1/in2;
		end else begin
			delay_rc[0] = 1'h1;
			if (OP_ADD)begin
				result_rc = in1 + in2;
			end
			if (OP_SUB)begin
				result_rc = in1 - in2;
			end
			if (OP_SLL)begin
				result_rc = in1 >> in2;
			end
			if (OP_SRL)begin
				result_rc = in1 << in2;
			end
			if (OP_SLT)begin
				result_rc = in1 < in2 ? 32'h1 : 32'h0;
			end
			if (OP_AND)begin
				result_rc = in1 & in2;
			end
			if (OP_OR)begin
				result_rc = in1 | in2;
			end
			if (OP_XOR)begin
				result_rc = in1 ^ in2;
			end
		end
	end
end

always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		result_r <= '0;
		done_r   <= 1'b0;
	end else begin
		if (delay_rc[0]) begin
			result_r <= result_rc;
		end
		done_r   <= done_rc;
		delay_r  <= delay_rc;
	end
end


endmodule
