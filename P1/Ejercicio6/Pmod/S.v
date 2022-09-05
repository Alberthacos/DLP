`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:22:25 09/04/2022
// Design Name:   SPI_ctrl_ALS
// Module Name:   C:/Users/amf01/Documents/DLP/P1/Ejercicio6/Pmod/S.v
// Project Name:  Pmod
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SPI_ctrl_ALS
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module S;

	// Inputs
	reg clk;
	reg rst;
	reg SDO;

	// Outputs
	wire CS;
	wire SCK;
	wire [7:0] data;
	wire [7:0] DISPLAY;
	wire [3:0] AN;

	// Instantiate the Unit Under Test (UUT)
	SPI_ctrl_ALS uut (
		.clk(clk), 
		.rst(rst), 
		.CS(CS), 
		.SDO(SDO), 
		.SCK(SCK), 
		.data(data), 
		.DISPLAY(DISPLAY), 
		.AN(AN)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		SDO = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule

