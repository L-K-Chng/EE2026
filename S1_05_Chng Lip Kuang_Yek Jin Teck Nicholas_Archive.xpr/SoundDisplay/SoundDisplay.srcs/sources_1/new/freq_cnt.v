`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.10.2022 12:53:57
// Design Name: 
// Module Name: freq_cnt
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


module freq_cnt(
        input sample_clock, [11:0] sample, [11:0] peak_val,
        output reg [15:0] freq_val
    );
    // zero crossing frequency counter
    // output frequency values of 100 - 17kHZ
    reg [31:0] sample_cnt;    
    reg [15:0] crosses;
    reg [15:0] last_freq;
    reg upwards; //maybe use to determine dxn
    initial begin
        upwards = 1;
    end
    
    always @ (posedge sample_clock) begin
        // sample_cnt = (Tsample)/(1/f_sample);;0.005s
        sample_cnt = (sample_cnt == 250)? 0: sample_cnt + 1; 
        // sample a range of values
        if(peak_val > 2300) begin
            if(sample >= peak_val/2 && upwards == 1) begin
                crosses <= (crosses == 16'b1111_1111_1111_1111)? crosses: crosses + 1;
                upwards <= 0;
            end
            else if (sample <= peak_val/2 && upwards == 0) begin
                crosses <= (crosses == 16'b1111_1111_1111_1111)? crosses: crosses  + 1;
                upwards <= 1;     
            end
        end
        // reset counters and update freq value
        // frequncy = crosses * (1/T)
        if(sample_cnt == 0) begin
            last_freq <= crosses*200/2;
            crosses <= 0;
        end
        freq_val <= last_freq;
    end
    
    
endmodule
