module xxx (c, r, h, d, cnt);
input c, h, d, r;
output [23:0] cnt;
reg [23:0] cnt = 24'd0;
wire c,r,h,d;
always @(posedge c)
if (r == 1) cnt <= 0;
else if(h) cnt <= d ? cnt+1 : cnt-1;

module music(clk, speaker); //Ambulance Siren
input clk;
output speaker;
reg [27:0] tone;
always @(posedge clk) tone <= tone+1;
wire [6:0] fastsweep = (tone[22] ? tone[21:15] : ~tone[21:15]);
wire [6:0] slowsweep = (tone[25] ? tone[24:18] : ~tone[24:18]);
wire [14:0] clkdivider = {2'b01, (tone[27] ? slowsweep : fastsweep), 6'b000000};
reg [14:0] counter;
always @(posedge clk) if(counter==0) counter <= clkdivider; else counter <= counter-1;
reg speaker;
always @(posedge clk) if(counter==0) speaker <= ~speaker;
endmodule