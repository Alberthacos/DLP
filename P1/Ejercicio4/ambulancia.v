//
//module music(clk, speaker); //Ambulance Siren
////input clk;
////output speaker;
////reg [27:0] tone;
////always @(posedge clk) tone <= tone+1;
////wire [6:0] fastsweep = (tone[22] ? tone[21:15] : ~tone[21:15]);
////wire [6:0] slowsweep = (tone[25] ? tone[24:18] : ~tone[24:18]);
////wire [14:0] clkdivider = {2'b01, (tone[27] ? slowsweep : fastsweep), 6'b000000};
////reg [14:0] counter;
//
//always @(posedge clk) if(counter==0) counter <= clkdivider; else counter <= counter-1;
//reg speaker;
//always @(posedge clk) if(counter==0) speaker <= ~speaker;
//endmodule
//
module music(clk, speaker,s1); //Police Siren
input clk,s1;
output speaker;
reg [22:0] tone;
always @(posedge clk) tone <= tone+1;
wire [6:0] ramp = (tone[22] ? tone[21:15] : ~tone[21:15]);
wire [14:0] clkdivider = {2'b01, ramp, 6'b000000};
reg [14:0] counter;

always @(posedge clk) if(counter==0) counter <= clkdivider; else counter <= counter-1;
reg speaker;
always @(posedge clk) if(counter==0 & s1 == 0) speaker <= ~speaker;
else speaker <= 0;
endmodule

//
//module music (clk,speaker,s1,s2);
//input clk;
//input s1;
//input s2;
//output speaker;
//reg [27:0] tone; //ambulance 
//reg [22:0] tone1;//police
//
//always @(posedge clk) 
//begin
//    if (s1 & ~s2) tone <= tone+1;
//    else if (s2 & ~s1)tone1 <= tone1+1;
//end
//
//wire [6:0] fastsweep = (tone[22] ? tone[21:15] : ~tone[21:15]);
//wire [6:0] slowsweep = (tone[25] ? tone[24:18] : ~tone[24:18]);
////wire [14:0] clkdivider = {2'b01, (tone[27] ? slowsweep : fastsweep), 6'b000000};
//reg [14:0] counter;
//
//wire [6:0] ramp = (tone1[22] ? tone1[21:15] : ~tone1[21:15]);
//
//wire [14:0] clkdivider1 = {2'b01, ramp, 6'b000000};
//wire [14:0] clkdivider = {2'b01, (tone[27] ? slowsweep : fastsweep), 6'b000000};
//
//
//always @(posedge clk) 
//if (s1 == 1 & s2 ==0) 
//begin
//    if(counter==0) counter <= clkdivider1; 
//    else counter <= counter-1;
//    if(counter==0) speaker <= ~speaker;
//end
//else if (s2 == 1 & s1 == 0)
//begin
//    if(counter==0) counter <= clkdivider; 
//    else counter <= counter-1;
//    if(counter==0) speaker <= ~speaker;
//end
//reg speaker;
//endmodule


