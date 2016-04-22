module led_driver(mode, clk, led, n_reset);
parameter MODE_DOWN = 2'b00;
parameter MODE_BLINK = 2'b01;
parameter MODE_UP = 2'b10;

input [1:0] mode;
input clk, n_reset;
output led;

reg _led;
assign led = ~(mode == MODE_DOWN) & ((mode == MODE_UP) | _led);

always @(posedge clk, negedge n_reset)
	if (!n_reset)
		_led <= 0;
	else
		_led <= ~_led;
	
endmodule