module counter(clk, n_reset, en, cnt);
input clk, n_reset, en;
output [63:0] cnt;
reg [63:0] cnt;

always @(posedge clk, negedge n_reset)
	if (!n_reset)
		cnt = 0;
	else if (en)
		cnt = cnt + 1;
		
endmodule