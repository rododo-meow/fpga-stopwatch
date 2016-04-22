module clk_10_to_ms(clk_10, clk_ms, n_reset);
parameter T = 10;
parameter bits = 23;

input clk_10;
output clk_ms;
input n_reset;

reg [(bits - 1):0] cnt;
reg clk_ms;

always @(posedge clk_10, negedge n_reset) begin
	if (!n_reset)
		cnt <= 0;
	else if (cnt >= (T * 10000))
		cnt <= 0;
	else
		cnt <= cnt + {{(bits - 1){1'b0}},{1'd1}};
end

always @(posedge clk_10) clk_ms <= cnt < ((T * 10000) / 2);
	
endmodule