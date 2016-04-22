module clk_10_to_10ms(clk_10, clk_10ms, n_reset);
input clk_10;
output clk_10ms;
input n_reset;

reg [16:0] cnt;

assign clk_10ms = cnt < 16'd50000;
always @(posedge clk_10, negedge n_reset)
	if (!n_reset)
		cnt = 0;
	else if (cnt >= 17'd100000)
		cnt = 0;
	else
		cnt = cnt + 17'd1;
	
endmodule