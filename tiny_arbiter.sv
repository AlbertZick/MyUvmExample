typedef enum logic {
	IDLE   =0,
	WR_DATA=1
} master_state;

module tiny_arbiter #(
	parameter BASE_M1 = 32'h0000_0000,
	parameter BASE_M2 = 32'h2000_0000
) (
	input clk,
	input rst_n,

	input			s_valid,
	output			s_ready,
	input [31:0]	s_data,
	input [31:0]	s_addr,

	input			m1_valid,
	output			m1_ready,
	input [31:0]	m1_data,
	input [31:0]	m1_addr,

	input			m2_valid,
	output			m2_ready,
	input [31:0]	m2_data,
	input [31:0]	m2_addr
);

master_state   m1_st, m1_st_nxt;
logic		 m1_valid_rc, m1_valid_r;
logic 		 m1_ready_rc, m1_ready_r;
logic [31:0] m1_data_rc,  m1_data_r;
logic [31:0] m1_addr_rc,  m1_addr_r;


master_state   m2_st, m2_st_nxt;


logic dec_m1, dec_m2;

always_comb begin
	dec_m1 == s_valid & (s_addr[31:28] == BASE_M1[31:28]);
	dec_m2 == s_valid & (s_addr[31:28] == BASE_M2[31:28]);
	m1_st_nxt = m1_st;
	m2_st_nxt = m2_st;
	case(m1_st)
		IDLE: begin
			if (dec_m1) begin
				m1_st_nxt = WR_DATA;
				m1_valid_rc = 1'h1;
			end
		end
		WR_DATA: begin
			if (dec_m1 & m1_ready) begin
				m1_st_nxt = WR_DATA;
				m1_valid_rc = 1'h1;
			end else begin
				
			end
		end
	endcase
end



always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m1_valid_r <= 'h0;
		m1_ready_r <= 'h0;
		m1_data_r  <= 'h0;
		m1_addr_r  <= 'h0;
	end else begin
		m1_valid_r <= m1_valid_rc;
		m1_ready_r <= m1_ready_rc;
		m1_data_r  <= m1_data_rc;
		m1_addr_r  <= m1_addr_rc;
	end
end


endmodule
