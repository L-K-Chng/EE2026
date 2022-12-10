`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.09.2022 15:16:50
// Design Name: 
// Module Name: clk_sel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_sel(
    input basys_clock, [31:0] m_value,
    output reg clkout = 0
    );
    // Basysclk == 100Mhz
    // cnt toggle where cnt = fBasys/(2*ftarget)-1
    reg [31:0] cnt = 0;
    always @ (posedge basys_clock)
    begin
        cnt <= (cnt == m_value)? 0:cnt+1;
        clkout <= (cnt == 0)? ~clkout:clkout;
    end
endmodule
