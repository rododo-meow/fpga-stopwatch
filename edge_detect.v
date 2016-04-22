module edge_detect(raw, pos, neg, clk, n_reset);
input raw, clk, n_reset;
output pos, neg;

reg r0, r1;
assign pos = r0 & ~r1;
assign neg = ~r0 & r1;

always @(posedge clk, negedge n_reset) begin
	if (!n_reset) begin
		r0 <= 0;
		r1 <= 0;
	end else begin
		r0 <= raw;
		r1 <= r0;
	end
end

endmodule