module controller(n_reset, startstop, pause, mark, led, mode, en, disp_sel, disp_update, clk, state);
parameter MODE_SPLIT = 0;
parameter MODE_LAP = 1;

parameter S_COUNT = 1'b0;
parameter S_READ = 1'b1;

input n_reset, startstop, pause, mark, state;
output [19:0] led;
output [10:0] en;
input mode;
output [3:0] disp_sel;
output disp_update;
input clk;

reg [19:0] led, running, reading;
reg disp_update;
reg [3:0] disp_sel, running_disp_sel, reading_disp_sel;
reg [10:0] en;
reg _mode;
wire pos_startstop, pos_mark, pos_pause;
reg internal_pause, internal_disp_pause;

edge_detect startstop_detect(
	.raw(startstop),
	.clk(clk),
	.n_reset(n_reset),
	.pos(pos_startstop)
);

edge_detect mark_detect(
	.raw(mark),
	.clk(clk),
	.n_reset(n_reset),
	.pos(pos_mark)
);

edge_detect pause_detect(
	.raw(pause),
	.clk(clk),
	.n_reset(n_reset),
	.pos(pos_pause)
);

function [19:0] set_field;
input [19:0] ori;
input [1:0] field;
input [3:0] offset;
begin
	set_field = ori & (~(2'b11 << (offset * 2))) | (field << (offset * 2));
end
endfunction

always @(reading_disp_sel)
	if (reading_disp_sel == 10)
		reading <= {10{2'b10}};
	else
		reading = 2'b10 << ((9 - reading_disp_sel) * 2);
		
always @(state, internal_disp_pause)
	if (state == S_COUNT)
		disp_update <= !internal_disp_pause;
	else
		disp_update <= 1;

always @(reading, running, state)
	case (state)
	S_COUNT: led <= running;
	S_READ: led <= reading;
	default: led <= 0;
	endcase
	
always @(reading_disp_sel, running_disp_sel, state)
	case (state)
	S_COUNT: disp_sel <= running_disp_sel;
	S_READ: disp_sel <= reading_disp_sel;
	default: disp_sel <= 0;
	endcase

always @(running_disp_sel, internal_pause, _mode)
	if (internal_pause)
		en <= 0;
	else
		case (_mode)
		MODE_SPLIT: en <= ~((11'b1 << running_disp_sel) - 11'b1);
		default: en <= {1'b1, 10'b1 << running_disp_sel};
		endcase

always @(negedge n_reset) begin
	_mode = mode;
end

always @(posedge clk, negedge n_reset) begin
	if (!n_reset) begin
		internal_pause <= 1;
	end else if (state == S_COUNT) begin
		if (pos_startstop) internal_pause <= ~internal_pause;
	end
end

always @(posedge clk, negedge n_reset) begin
	if (!n_reset) begin
		running_disp_sel <= 0;
		reading_disp_sel <= 0;
		case (_mode)
		MODE_SPLIT: running <= {10{2'b01}};
		default: running <= {{2'b01},{9{2'b00}}};
		endcase
	end else if (state == S_COUNT) begin
		if (pos_mark && running_disp_sel < 9) begin
			running_disp_sel <= running_disp_sel + 4'd1;
			case (_mode)
			MODE_SPLIT: running <= set_field(running, 2'b10, 9 - running_disp_sel);
			default: running <= set_field(set_field(running, 2'b10, 9 - running_disp_sel), 2'b01, 8 - running_disp_sel);
			endcase
		end
	end else if (state == S_READ) begin
		case ({pos_pause,pos_startstop})
		2'b01: if (reading_disp_sel < 9 || (reading_disp_sel == 9 && _mode == MODE_LAP)) reading_disp_sel <= reading_disp_sel + 4'd1;
		2'b10: if (reading_disp_sel > 0) reading_disp_sel <= reading_disp_sel - 4'd1;
		endcase
	end
end

always @(posedge clk, negedge n_reset) begin
	if (!n_reset)
		internal_disp_pause <= 0;
	else if (state == S_COUNT && pos_pause)
		internal_disp_pause <= ~internal_disp_pause;
end

endmodule