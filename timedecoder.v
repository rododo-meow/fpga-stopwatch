module timedecoder(cnt, cs0, cs1, s0, s1, m0, m1);
input [63:0] cnt;
output [3:0] cs0, cs1, s0, s1, m0, m1;

assign cs0 = (cnt / 100000) % 10;
assign cs1 = (cnt / 1000000) % 10;
assign s0 = (cnt / 10000000) % 10;
assign s1 = (cnt / 100000000) % 6;
assign m0 = (cnt / 600000000) % 10;
assign m1 = (cnt / 6000000000) % 6;

endmodule