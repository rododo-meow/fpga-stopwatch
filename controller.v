module controller(n_reset, startstop, pause, mark, running, mode, en, disp_sel, disp_update, clk);
parameter MODE_SPLIT = 0;
parameter MODE_LAP = 1;

input n_reset, startstop, pause, mark;
output [19:0] running;
output [10:0] en;
input mode;
output [3:0] disp_sel;
output disp_update;
input clk;

reg disp_update;
reg [3:0] disp_sel;
reg [10:0] en;
reg [19:0] running;
reg _mode;
reg state;
localparam S_COUNT = 1'b0;
localparam S_READ = 1'b1;
wire pos_startstop, pos_mark, pos_pause;

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

always @(negedge n_reset) begin
	_mode = mode;
	state = S_COUNT;
end

always @(posedge clk, negedge n_reset) begin
	if (!n_reset) begin
		en <= 11'b0;
	end else if (pos_startstop) begin
		case (en)
		11'b0:
			case (_mode)
			MODE_SPLIT: en <= ~((11'b1 << disp_sel) - 11'b1);
			default: en <= {1'b1, 10'b1 << disp_sel};
			endcase
		default: en <= 11'b0;
		endcase
	end else if (pos_mark) begin
		case (en)
		11'b0: en <= en;
		default:
			case (_mode)
			MODE_SPLIT: en <= ~((11'b1 << (disp_sel + 1)) - 11'b1);
			default: en <= {1'b1, 10'b1 << (disp_sel + 1)};
			endcase
		endcase
	end
end

always @(posedge clk, negedge n_reset) begin
	if (!n_reset) begin
		case (_mode)
		MODE_SPLIT: disp_sel <= 4'd0;
		default: disp_sel <= 4'd0;
		endcase
	end else if (pos_mark) begin
		case (state)
		S_COUNT: begin
			if (mark) disp_sel <= disp_sel + 4'd1;
		end
		S_READ: begin
			if (mark) disp_sel <= disp_sel - 4'd1;
			else disp_sel <= disp_sel + 4'd1;
		end
		default: disp_sel <= 4'd0;
		endcase
	end
end

always @(posedge clk, negedge n_reset) begin
	if (!n_reset)
		disp_update <= 1;
	else if (pos_pause)
		disp_update <= ~disp_update;
end

function [19:0] set_field;
input [19:0] ori;
input [1:0] field;
input [3:0] offset;
begin
	set_field = ori & (~(2'b11 << (offset * 2))) | (field << (offset * 2));
end
endfunction

always @(posedge clk, negedge n_reset) begin
	if (!n_reset)
		case (_mode)
		MODE_SPLIT: running <= {10{2'b01}};
		default: running <= {{2'b01},{9{2'b00}}};
		endcase
	else if (pos_mark)
		case (_mode)
		MODE_SPLIT:
			running <= set_field(running, 2'b10, 9 - disp_sel);
		default:
			running <= set_field(set_field(running, 2'b10, 9 - disp_sel), 2'b01, 8 - disp_sel);
		endcase
end

endmodule