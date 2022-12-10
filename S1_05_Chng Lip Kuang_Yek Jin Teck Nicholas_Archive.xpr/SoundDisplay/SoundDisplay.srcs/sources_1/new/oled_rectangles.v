`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.10.2022 06:20:48
// Design Name: 
// Module Name: oled_rectangles
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


module oled_rectangles(
    input basys_clock, clk_25mhz, clk_10hz, btnD,
    output reg led12,
    output reg [2:0] rectBus
    );
    
    reg [31:0] ledCnt; // hold for 3s
    reg [31:0] pulseCnt; // check for new pulse
    reg canToggle;
    reg hold3s;

    always @ (posedge clk_25mhz) begin
        if(btnD == 1 && pulseCnt == 0 && ledCnt == 0) begin
            // toggle greenBus iff ledCnt ==0
            rectBus <= (rectBus == 3)? 0:rectBus+1;
        end
    end
    
    // Prevent further clicks
    always @ (posedge clk_25mhz) begin
        if(btnD && pulseCnt == 0)begin
            ledCnt <= ledCnt +1;
        end
        
        if(ledCnt != 0) begin
            led12 <= 1;
            ledCnt <= (ledCnt == 125000000 )? 0:ledCnt+1;
        end
        else begin
            led12 <= 0;
        end
    end
    // create a counter to keep track of when btnU is on
    // when btnU is released, reset to zero
    always@(posedge clk_25mhz) begin
        if(btnD)begin
            pulseCnt <= (pulseCnt == 0)? 1:pulseCnt+1;
        end
        else begin
            pulseCnt <= 0;
        end
    end 
endmodule
