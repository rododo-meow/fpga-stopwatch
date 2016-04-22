`timescale 1ns/1ps

module stopwatch_bench();
reg CLOCK_50;
reg [3:0] KEY;

stopwatch stopwatch(
	.CLOCK_50(CLOCK_50),
	.KEY(KEY)
);

initial CLOCK_50 = 0;
always #10 CLOCK_50 = ~CLOCK_50;

initial begin
	KEY = 4'b1110;
	#1000 KEY = 4'b1111;
	#1000 KEY = 4'b1101;
	#1000 KEY = 4'b1111;
	#100000 KEY = 4'b0111;
	#1000 KEY = 4'b1111;
	#200000 $stop();
end

endmodule