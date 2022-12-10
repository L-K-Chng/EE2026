`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2022 17:26:12
// Design Name: 
// Module Name: seg_manual
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


module seg_manual(
    input clk, [6:0] v_an0, v_an1, v_an2, v_an3,
    output reg [3:0] an, reg [6:0] seg
    );
    // use this module to display hardcoded text on each of the anodes
    reg [1:0] cnt;
    always @ (posedge clk) begin
        cnt <= cnt + 1;
        if(cnt == 0) begin 
            an <= 4'b1110;
            seg <= v_an0;
        end
        else if(cnt == 1) begin
            an <= 4'b1101;
            seg <= v_an1;
        end
        else if (cnt == 2) begin
            an <= 4'b1011;
            seg <= v_an2;
        end
        else if (cnt == 3) begin
            an <= 4'b0111;        
            seg <= v_an3;
        end
    end
endmodule
