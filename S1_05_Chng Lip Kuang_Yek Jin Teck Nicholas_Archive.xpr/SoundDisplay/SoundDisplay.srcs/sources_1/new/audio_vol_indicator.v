`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2022 16:01:16
// Design Name: 
// Module Name: audio_vol_indicator
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


module audio_vol_indicator(
    input clk_20khz,
    input [11:0]current_mic_value, //sample
    output reg [3:0]led
    );
    reg [31:0]count;
    reg [11:0]peak_value;
    
    initial begin
        led <= 4'b0000;
    end
    
    always @ (posedge clk_20khz) begin
        count <= count + 1;
        // read value of mic
        if(current_mic_value > peak_value) begin
            peak_value <= current_mic_value;
        end
        if(count == 2000) begin //0.1s
            // update LEDs
            if(peak_value < 2300) begin
                led <= 4'b0000;
            end
            else if(peak_value >= 2300 && peak_value < 2700) begin
                led <= 4'b0001;
            end
            if(peak_value >= 2700 && peak_value < 3200) begin
                led <= 4'b0011;
            end
            if(peak_value >= 3200 && peak_value < 4000) begin
                led <= 4'b0111;
            end
            if(peak_value >= 4000) begin
                led <= 4'b1111;
            end
            // reset cnt
            count <= 0;
            // reset peak
            peak_value = 0;
        end
    end
    
endmodule
