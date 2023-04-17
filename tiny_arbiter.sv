
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

	output			m1_valid,
	input			m1_ready,
	output [31:0]	m1_data,
	output [31:0]	m1_addr,

	output			m2_valid,
	input			m2_ready,
	output [31:0]	m2_data,
	output [31:0]	m2_addr
);



typedef enum logic {
	IDLE   =0,
	WR_DATA=1
} master_state;



master_state   m1_st, m1_st_nxt;
logic		 m1_valid_rc, m1_valid_r;
logic [31:0] m1_data_rc,  m1_data_r;
logic [31:0] m1_addr_rc,  m1_addr_r;

master_state   m2_st, m2_st_nxt;
logic		 m2_valid_rc, m2_valid_r;
logic [31:0] m2_data_rc,  m2_data_r;
logic [31:0] m2_addr_rc,  m2_addr_r;


logic dec_m1, dec_m2;

assign m1_valid = m1_valid_r;
assign m1_data = m1_data_r;
assign m1_addr = m1_addr_r;

assign s_ready = (dec_m1 == 1'h1 && (m1_st == IDLE || m1_ready == 1'h1)) ||
		 (dec_m2 == 1'h1 && (m2_st == IDLE || m2_ready == 1'h1));

always_comb begin
	dec_m1 = s_valid & (s_addr[31:28] == BASE_M1[31:28]);
	m1_st_nxt = m1_st;
	m1_valid_rc = m1_valid_r;
	m1_addr_rc = m1_addr_r;
	m1_data_rc = m1_data_r;
	case(m1_st)
		IDLE: begin
			if (dec_m1) begin
				m1_st_nxt = WR_DATA;
				m1_valid_rc = 1'h1;
				m1_addr_rc = s_addr;
				m1_data_rc = s_data;
			end
		end
		WR_DATA: begin
			if (dec_m1 & m1_ready) begin
				m1_st_nxt = WR_DATA;
				m1_valid_rc = 1'h1;
				m1_addr_rc = s_addr;
				m1_data_rc = s_data;
			end
			else if (m1_ready) begin
				m1_st_nxt = IDLE;
				m1_valid_rc = 1'h0;
			end else begin
				m1_st_nxt = m1_st;
				m1_valid_rc = m1_valid_r;
			end
		end
	endcase
end

always_comb begin
	dec_m2 = s_valid & (s_addr[31:28] == BASE_M2[31:28]);
	m2_st_nxt = m2_st;
	m2_valid_rc = m2_valid_r;
	m2_addr_rc = m2_addr_r;
	m2_data_rc = m2_data_r;
	case(m2_st)
		IDLE: begin
			if (dec_m2) begin
				m2_st_nxt = WR_DATA;
				m2_valid_rc = 1'h1;
				m2_addr_rc = s_addr;
				m2_data_rc = s_data;
			end
		end
		WR_DATA: begin
			if (dec_m2 & m2_ready) begin
				m2_st_nxt = WR_DATA;
				m2_valid_rc = 1'h1;
				m2_addr_rc = s_addr;
				m2_data_rc = s_data;
			end
			else if (m2_ready) begin
				m2_st_nxt = IDLE;
				m2_valid_rc = 1'h0;
			end else begin
				m2_st_nxt = m2_st;
				m2_valid_rc = m2_valid_r;
			end
		end
	endcase
end

always_ff @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		m1_st 	   <= IDLE;
		m1_valid_r <= 'h0;
		m1_data_r  <= 'h0;
		m1_addr_r  <= 'h0;

		m2_st 	   <= IDLE;
		m2_valid_r <= 'h0;
		m2_data_r  <= 'h0;
		m2_addr_r  <= 'h0;
	end else begin
		m1_st 	   <= m1_st_nxt ;
		m1_valid_r <= m1_valid_rc;
		m1_data_r  <= m1_data_rc;
		m1_addr_r  <= m1_addr_rc;

		m2_st 	   <= m2_st_nxt ;
		m2_valid_r <= m2_valid_rc;
		m2_data_r  <= m2_data_rc;
		m2_addr_r  <= m2_addr_rc;
	end
end




endmodule
