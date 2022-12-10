`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2022 00:12:10
// Design Name: 
// Module Name: oled_border_ctl
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


module oled_border_ctl(
    input basys_clock, clk_12p5mhz, clk_10hz, btnU,
    output reg led14,
    output reg [2:0] greenBus
    );
    
    reg [31:0] ledCnt; // hold for 3s
    reg [31:0] pulseCnt; // check for new pulse
    reg canToggle;
    reg hold3s;

    always @ (posedge clk_12p5mhz) begin
        if(btnU == 1 && pulseCnt == 0 && ledCnt == 0) begin
            // toggle greenBus iff ledCnt ==0
            greenBus <= (greenBus == 4)? 0:greenBus+1;
        end
    end
    
    // Prevent further clicks
    always @ (posedge clk_12p5mhz) begin
        if(btnU && pulseCnt == 0)begin
            ledCnt <= ledCnt +1;
        end
        
        if(ledCnt != 0) begin
            led14 <= 1;
            ledCnt <= (ledCnt == 35_000_000)? 0:ledCnt+1;
//            ledCnt <= (ledCnt == 70_000_000)? 0:ledCnt+1;
        end
        else begin
            led14 <= 0;
        end
    end
    // create a counter to keep track of when btnU is on
    // when btnU is released, reset to zero
    always@(posedge clk_12p5mhz) begin
        if(btnU)begin
            pulseCnt <= (pulseCnt == 0)? 1:pulseCnt+1;
        end
        else begin
            pulseCnt <= 0;
        end
    end 
    
endmodule
