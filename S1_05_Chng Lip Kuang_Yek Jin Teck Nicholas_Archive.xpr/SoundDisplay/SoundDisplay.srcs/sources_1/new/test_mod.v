`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2022 21:26:23
// Design Name: 
// Module Name: test_mod
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

module test_mod(
    input basys_clock,
    input btnU,
    input btnC,
    input btnD,
    input [12:0] pixel_index,
    input [11:0] mic_in,
    input reset,
    input [1:0] enable,
    output reg [7:0] seg_hiit = 8'b11111111,
    output reg [3:0] an_hiit = 4'b1111,
    output reg [15:0] led_hiit = 0,
    output reg [15:0] oled_hiit
    );
reg [15:0]hiit_menu[0:6143];    
reg [15:0]select_workout[0:6143];
reg [15:0]select_workout2[0:6143];
reg [15:0]getready[0:6143];
reg [15:0]kneebent0[0:6143];
reg [15:0]restcycle[0:6143];
reg [15:0]completion[0:6143];
reg [15:0]pushup0[0:6143];
reg [15:0]pushup1[0:6143];
reg [15:0]situp0[0:6143];
reg [15:0]situp1[0:6143];
reg [15:0]squat0[0:6143];
reg [15:0]squat1[0:6143];
reg [15:0]jumpingjacks0[0:6143];
reg [15:0]jumpingjacks1[0:6143];
reg [15:0]legraise0[0:6143];
reg [15:0]legraise1[0:6143];
reg [15:0]kangaroohop0[0:6143];
reg [15:0]kangaroohop1[0:6143];
reg [15:0]lunges0[0:6143];
reg [15:0]lunges1[0:6143];
reg [15:0]bearcrawl0[0:6143];
reg [15:0]bearcrawl1[0:6143];
reg [31:0] rest_duration;
initial begin
    $readmemh("hiit_menu.mem", hiit_menu);
    $readmemh("select_workout.mem", select_workout);
    $readmemh("select_workout2.mem", select_workout2);  
    $readmemh("getready.mem", getready);
    $readmemh("kneebent0.mem", kneebent0);
    $readmemh("restcycle.mem", restcycle);
    $readmemh("completion.mem", completion);
    $readmemh("pushup0.mem", pushup0);
    $readmemh("pushup1.mem", pushup1);
    $readmemh("situp0.mem", situp0);
    $readmemh("situp1.mem", situp1);
    $readmemh("squat0.mem", squat0);
    $readmemh("squat1.mem", squat1);
    $readmemh("jumpingjacks0.mem", jumpingjacks0);
    $readmemh("jumpingjacks1.mem", jumpingjacks1);
    $readmemh("legraise0.mem", legraise0);
    $readmemh("legraise1.mem", legraise1);
    $readmemh("kangaroohop0.mem", kangaroohop0);
    $readmemh("kangaroohop1.mem", kangaroohop1);
    $readmemh("lunges0.mem", lunges0);
    $readmemh("lunges1.mem", lunges1);
    $readmemh("bearcrawl0.mem", bearcrawl0);
    $readmemh("bearcrawl1.mem", bearcrawl1);
    rest_duration = 15;
end
reg [31:0] debouncing_count = 0;
reg started = 0;
reg [1:0]select_state = 0;
reg [1:0]selected_workout = 0;
reg [1:0] workout_routine = 0;
//var name
reg finished = 0;
reg work_or_rest = 1;
reg [31:0] one_sec_count = 0;
reg paused = 0;
reg [31:0] timer;
reg [2:0] started_count = 0;
reg started_workout = 0;
reg [3:0] pause_remaining = 0;
reg [2:0] reps = 0;
reg [31:0] remaining = 0;
reg an_count = 0;

wire clk_1khz;
clk_sel my_clk(basys_clock, 99999, clk_1khz);

always @ (posedge clk_1khz) begin //anode count
    an_count <= (an_count == 1) ? 0 : an_count + 1;
end
          
always @ (posedge basys_clock)begin
    
    if (enable != 1) begin //reset
            timer = 0;
            select_state = 0;
            started = 0;
            debouncing_count = 0;
            selected_workout = 0;
            workout_routine = 0;
            finished = 0;
            work_or_rest = 1;
            one_sec_count = 0;
            started_count = 0;
            started_workout = 0;
            reps = 0;
            remaining = 0;
            rest_duration = 15; //set back to 15
            //set back to original
            led_hiit = 0;
            an_hiit = 4'b1111;
            seg_hiit = 8'b11111111;           
    end 
    
    //initial state will be main menu. Directed to main menu of HIIT.     
    if (started == 0)
    begin
        oled_hiit <= hiit_menu[pixel_index];
        //After pressing begin button. go to the routine selection page.
        if(select_state == 0) begin        
            if (btnC) begin
                debouncing_count <= debouncing_count +1;
                if (debouncing_count == 30000000) begin
                    debouncing_count <= 0;                
                    select_state <= 1;
                end
            end
        end
        //Go to the second option in the routine selection page.
//        else if (select_state == 1 && btnD)begin
//            debouncing_count <= debouncing_count +1;
//            if (debouncing_count == 30000000) begin
//                debouncing_count <= 0;
//                select_state <= 2;
//            end
//        end
//        //Go back to first option in the routine selection page.
//        else if (select_state == 2 && btnU)begin
//            debouncing_count <= debouncing_count +1;
//            if (debouncing_count == 30000000) begin
//                debouncing_count <= 0;
//                select_state <= 1;
//            end
//        end
        //selecting one of the two workout routines. Show menu with top option.
        if (select_state == 1)begin
            oled_hiit <= select_workout[pixel_index];
            if (btnC)begin
                debouncing_count <= debouncing_count + 1;
                if(debouncing_count == 30000000) begin
                    debouncing_count <= 0;            
                    selected_workout <= 1;
                    started <= 1;
                end
            end
            else if (btnD) begin
                debouncing_count <= debouncing_count +1;
                if (debouncing_count == 30000000) begin
                    debouncing_count <= 0;
                    select_state <= 2;
                end
            end         
        end
        //Show menu with bottom option
        else if (select_state == 2)begin
            oled_hiit <= select_workout2[pixel_index];
            if (btnC)begin
                debouncing_count <= debouncing_count + 1;
                if(debouncing_count == 30000000) begin
                    debouncing_count <= 0;
                    selected_workout <= 2;
                    started <= 1;
                end              
            end
            else if (btnU) begin
                debouncing_count <= debouncing_count +1;
                if (debouncing_count == 30000000) begin
                    debouncing_count <= 0;
                    select_state <= 1;
                end
            end
        end   
    end
    //pressed start button already. Condition is started = 1. User has selected a workout. Use the condition of selected_workout to choose activity.
    else begin //selected a workout  
        if (~finished)
        begin
            one_sec_count <= one_sec_count+1;
            if(one_sec_count == 100000000) begin //1 sec has passed
                    timer <= timer + 1;
                    one_sec_count <= 0;
                    //3 seconds to prepare before starting.
                    started_count = (started_count == 3) ? started_count : started_count+1;
                    started_workout = (started_count == 3) ? 1 : 0;
                    one_sec_count <= 0;
            end 
            if (~started_workout)
            begin
                oled_hiit <= getready[pixel_index];
                timer <= 0;
            end
            else begin
                if(btnC) begin
                    debouncing_count <= debouncing_count + 1;
                    if(debouncing_count == 30000000) begin
                        debouncing_count <= 0;
                        if(work_or_rest) begin //currently in work cycle
                            timer <= 0;
                            reps = (reps == 4) ? reps : reps + 1;
                        end
                        else
                            timer <= rest_duration;
                    end
                end
                if (work_or_rest)
                begin //work cycle
                remaining <= 30 - timer;
                if (remaining % 2 == 0) begin
                    if(reps == 0) begin //first exercise
                        if (selected_workout == 1) begin
                            //change the exercise
                            oled_hiit <= pushup0[pixel_index];                                                 
                        end
                        else if (selected_workout == 2) begin
                            //change the exercise
                            oled_hiit <= situp0[pixel_index];
                        end
                    end
                    else if (reps == 1) begin //second exercise
                        if (selected_workout == 1) begin
                            oled_hiit <= squat0[pixel_index];  
                         end   
                        else if (selected_workout == 2) begin
                            oled_hiit <= jumpingjacks0[pixel_index];                      
                        end
                    end
                    else if(reps == 2) begin //third exercise
                        if (selected_workout == 1) begin
                            oled_hiit <= legraise0[pixel_index];                
                        end
                        else if (selected_workout == 2) begin
                            oled_hiit <= kangaroohop0[pixel_index];                       
                        end
                    end
                    else if(reps == 3) begin //fourth exercise
                        if (selected_workout == 1) begin
                            oled_hiit <= bearcrawl0[pixel_index];
                        end
                        else if (selected_workout == 2) begin
                            oled_hiit <= lunges0[pixel_index];
                        end
                    end
                end
                else begin //display stop position
                    if(reps == 0) begin //first exercise
                        if (selected_workout == 1) begin
                            oled_hiit <= pushup1[pixel_index];
                        end
                        else if (selected_workout == 2) begin
                            oled_hiit <= situp1[pixel_index];
                        end
                    end
                    else if (reps == 1) begin //second exercise
                        if (selected_workout == 1) begin
                            oled_hiit <= squat1[pixel_index];
                        end
                        else if (selected_workout == 2) begin
                            oled_hiit <= jumpingjacks1[pixel_index];                     
                        end
                    end
                    else if(reps == 2) begin //third exercise
                        if(selected_workout == 1) begin //display upper
                            oled_hiit <= legraise1[pixel_index];   
                        end
                        else if (selected_workout == 2) begin
                            oled_hiit <= kangaroohop1[pixel_index];   
                        end
                    end
                    else if(reps == 3) begin //fourth exercise
                        if (selected_workout == 1) begin
                            oled_hiit <= bearcrawl1[pixel_index];
                        end
                        else if (selected_workout == 2) begin
                            oled_hiit <= lunges1[pixel_index];
                        end                        
                    end               
                end
                if(timer == 0)
                    led_hiit <= 16'b0111_1111_1111_1111;
                else if(timer == 2)
                    led_hiit <= 16'b0011_1111_1111_1111;
                else if(timer == 4)
                    led_hiit <= 16'b0001_1111_1111_1111;
                else if(timer == 6)
                    led_hiit <= 16'b0000_1111_1111_1111;
                else if(timer == 8)
                    led_hiit <= 16'b0000_0111_1111_1111;
                else if(timer == 10)
                    led_hiit <= 16'b0000_0011_1111_1111;
                else if(timer == 12)
                    led_hiit <= 16'b0000_0001_1111_1111;
                else if(timer == 14)
                    led_hiit <= 16'b0000_0000_1111_1111;
                else if(timer == 16)
                    led_hiit <= 16'b0000_0000_0111_1111;
                else if(timer == 18)
                    led_hiit <= 16'b0000_0000_0011_1111;
                else if(timer == 20)
                    led_hiit <= 16'b0000_0000_0001_1111;
                else if(timer == 22)
                    led_hiit <= 16'b0000_0000_0000_1111;
                else if(timer == 24)
                    led_hiit <= 16'b0000_0000_0000_0111;
                else if(timer == 26)
                    led_hiit <= 16'b0000_0000_0000_0011;
                else if(timer == 28) 
                    led_hiit <= 16'b0000_0000_0000_0001;
                else if(timer == 30) begin
                    led_hiit <= 16'b0000_0000_0000_0000;
                    work_or_rest <= 1-work_or_rest; //toggle to rest cycle
                    timer <= 0;
                    reps = reps+1;
                    if(reps == 4) begin
                        finished <= 1;
                    end
                end               
                end  //end of work cycle
                else begin //rest cycle
                    if(~finished) begin
                        oled_hiit <= restcycle[pixel_index]; //display don't give up screen
                        led_hiit <= 0;
                        remaining <= rest_duration - timer;
                        if(timer == rest_duration) begin
                            timer <= 0;
                            work_or_rest <= 1-work_or_rest; //toggle to work cycle
                        end
                    end              
                end //rest cycle end  
                case (an_count)
                    0:
                    begin
                        an_hiit <= 4'b1110;
                        if(remaining == 0 || remaining == 10 || remaining == 20 || remaining == 30)
                            seg_hiit <= 8'b11000000;
                        else if(remaining == 1 || remaining == 11 || remaining == 21)
                            seg_hiit <= 8'b11111001;
                        else if(remaining == 2 || remaining == 12 || remaining == 22)
                            seg_hiit <= 8'b10100100;  
                        else if(remaining == 3 || remaining == 13 || remaining == 23)
                            seg_hiit <= 8'b10110000; 
                        else if(remaining == 4 || remaining == 14 || remaining == 24)
                            seg_hiit <= 8'b10011001;  
                        else if(remaining == 5 || remaining == 15 || remaining == 25)
                            seg_hiit <= 8'b10010010;  
                        else if(remaining == 6 || remaining == 16 || remaining == 26)
                            seg_hiit <= 8'b10000010; 
                        else if(remaining == 7 || remaining == 17 || remaining == 27)
                            seg_hiit <= 8'b11111000; 
                        else if(remaining == 8 || remaining == 18 || remaining == 28)
                            seg_hiit <= 8'b10000000; 
                        else if(remaining == 9 || remaining == 19 || remaining == 29)
                            seg_hiit <= 8'b10010000;
                    end
                    1:
                    begin
                        an_hiit <= 4'b1101;
                        if(remaining >= 0 && remaining <= 9)
                            seg_hiit <= 8'b11000000;
                        else if(remaining >= 10 && remaining <= 19)
                            seg_hiit <= 8'b11111001;
                        else if(remaining >= 20 && remaining <= 29)
                            seg_hiit <= 8'b10100100;
                        else
                            seg_hiit <= 8'b10110000;                    
                    end              
                endcase                      
            end            
        end //~finished end 
        else begin
            oled_hiit <= completion[pixel_index]; //display well done
            an_hiit <= 4'b1111;
            seg_hiit <= 7'b1111111;
        end 
        
    end// else statement end
end// end of posedge block.
    
endmodule
