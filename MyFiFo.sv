typedef enum logic[1:0] {
	IDLE=0,
	WR_DATA=1
} M_state;

module FIFO(
	input			clk,
	input			rst_n,

	input			S_valid,
	input [31:0]	S_addr,
	input [31:0]	S_data,
	output          S_ready,

	output [31:0]	M1_addr,
	output [31:0]	M1_data,
	output			M1_valid,
	input			M1_ready,

	output [31:0]	M2_addr,
	output [31:0]	M2_data,
	output			M2_valid,
	input			M2_ready
);

M_state M1_st, M1_st_nxt;
M_state M2_st, M2_st_nxt;


always_comb begin
	case(M1_st)
		IDLE: begin
			if (S_valid == 1'h1 && S_addr[31:28] == 'h0) begin
				
			end
		end
		WR_DATA: begin

		end
	endcase
end


always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		M1_st <= IDLE;
		M2_st <= IDLE;
	end else begin
		M1_st <= M1_st_nxt;
		M2_st <= M2_st_nxt;
	end
end





endmodule
