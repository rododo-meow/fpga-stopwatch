module timedecoder(cnt, cs0, cs1, s0, s1, m0, m1, h0, h1);
input [63:0] cnt;
output [3:0] cs0, cs1, s0, s1, m0, m1, h0, h1;

wire [63:0] t1, t2, t3, t4, t5, t6, t7, t8;
assign t1 = cnt / 64'd100000;
assign cs0 = t1 % 10;
assign t2 = t1 / 10;
assign cs1 = t2 % 10;
assign t3 = t2 / 10;
assign s0 = t3 % 10;
assign t4 = t3 / 10;
assign s1 = t4 % 6;
assign t5 = t4 / 6;
assign m0 = t5 % 10;
assign t6 = t5 / 10;
assign m1 = t6 % 6;
assign t7 = t6 / 6;
assign h0 = t7 % 10;
assign t8 = t7 / 10;
assign h1 = t8 % 6;

endmodule