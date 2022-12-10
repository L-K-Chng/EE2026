`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2022 15:23:27
// Design Name: 
// Module Name: oled_coordinate
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


module my_pixel_index(
    input [12:0]pixel_index,
    output [6:0]x, [6:0]y
    );
    assign x = pixel_index % 96; 
    assign y = pixel_index / 96;
endmodule
