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
	KEY = 4'b0000;
	#1000 KEY[0] = 4'b0001;
	#1000000000 KEY[0] = 4'b0000;
	#1000 KEY[0] = 4'b0001;
	#2000000000 $stop();
end

endmodule