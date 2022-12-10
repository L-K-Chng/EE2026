`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2022 19:25:04
// Design Name: 
// Module Name: meditation
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


module meditation(
    input clk, btnU, btnD, btnC, btnL, [15:0] freq_val, [1:0] enable,
    output reg [2:0] chosen_state, reg [3:0] an, reg [6:0] seg
    );
    
    // Meditation params
//      0  med_menu_ez [0:6143]; 
//      1 med_menu_hard [0:6143];
//      2 med_higher [0:6143];   
//      3 med_lower [0:6143];
//      4 med_maintain [0:6143];
//      5 med_done [0:6143]; DEPRECIATED
      reg menustate;
      reg [1:0] med_chosen_difficulty; // 00 easy -> 01 med -> 10 hard -> 11 overflow immediately
      reg [1:0] med_state; // 00 menu -> 01 active -> 10 done
      reg [15:0] med_target_freq; 
      reg [15:0] medCnt;
      reg [31:0] debounce;
     initial begin
        med_chosen_difficulty = 0;
        med_state = 0;
        chosen_state = 0;
        med_target_freq = 0;
        medCnt = 0;
     end       
     
     wire clk_slow;
     reg anCnt;
     clk_sel my_clk(clk, 99, clk_slow);
     always @ (posedge clk_slow)begin
        anCnt <= anCnt + 1;
     end
     // Meditation subroutine
     // med_state 00 menu -> 01 active -> 10 done    
     always @ (posedge clk) begin
     if(enable == 2)
     begin
         if(med_state == 0)
         begin
             an <= 4'b1111;
             seg <= 7'b1111111;  
                                      
             if(btnU) begin
                 med_chosen_difficulty <= 0;
                 chosen_state <= 0;
             end
             else if(btnD) begin
                med_chosen_difficulty <= 1;
                chosen_state <= 1;
             end
             
             if(btnC) begin
                debounce <= debounce + 1;
                if(debounce >= 15000) begin
                    debounce <= 0;
                    med_state <= 1;
                    chosen_state <= 4;
                    //medCnt <= 1;              
                end
             
             end
             // difficulty ctl
             if(med_chosen_difficulty == 0) begin
                 med_target_freq <= 400;
             end
             else if(med_chosen_difficulty == 1) begin
                 med_target_freq <= 800;
             end
         end
         
         else if(med_state == 1)
         begin
             if(freq_val < med_target_freq - 300)
              begin
                 if(anCnt == 0) begin
                    an <= ~4'b0001;
                    seg <= ~7'b0000110;
                 end
                 else if(anCnt == 1) begin
                    an <= ~4'b0010;
                    seg <= ~7'b1110110;
                 end
                chosen_state <= 3;
             end
             else if(freq_val > med_target_freq + 400)
             begin
                if(anCnt == 0) begin
                    seg <= ~7'b0111111;
                    an <= ~4'b0001;
                end
                else if(anCnt == 1) begin
                    an <= ~4'b0010;
                    seg <= ~7'b0111000;
                end
                chosen_state <= 2;
             end
             else begin
                if(anCnt == 0) begin
                     seg <= ~7'b1000000;
                     an <= ~4'b0001;
                 end
                 else if(anCnt == 1) begin
                     an <= ~4'b0010;
                     seg <= ~7'b1000000;
                 end
                chosen_state <= 4;
//                medCnt <= medCnt+1;
//                if(medCnt >= 80000) begin
//                    seg <= ~7'b1111111;
//                    med_state <= 2;
//                    medCnt <= 0;
//                end
             end 
         end            
//         else if(med_state == 2)
//         begin
//             an <= 4'b1011;
//             seg <= 7'b0000111;
//             medCnt <= 0;
//             chosen_state <= 5;
//             if(btnC)
//                 debounce <= debounce + 1;
//                 if(debounce >= 15000) begin
//                     med_state <= 0;
//                     chosen_state <= 0;
//                 end
//         end
     end
     else begin
        med_state <= 0;
        medCnt <= 0;
        chosen_state <= 0;
     end
                     
 end
endmodule
