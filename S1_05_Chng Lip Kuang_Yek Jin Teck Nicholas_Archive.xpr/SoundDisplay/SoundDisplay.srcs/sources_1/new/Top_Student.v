`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//
//  LAB SESSION DAY (Delete where applicable): MONDAY P.M, TUESDAY P.M, WEDNESDAY P.M, THURSDAY A.M., THURSDAY P.M
//
//  STUDENT A NAME: 
//  STUDENT A MATRICULATION NUMBER: 
//
//  STUDENT B NAME: 
//  STUDENT B MATRICULATION NUMBER: 
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input basys_clock,
    input  J_MIC3_Pin3,   // Connect from this signal to Audio_Capture.v
    output J_MIC3_Pin1,   // Connect to this signal from Audio_Capture.v
    output J_MIC3_Pin4,    // Connect to this signal from Audio_Capture.v
    // Other IO
    input btnL, btnR, btnU, btnC, btnD,
    input [15:0]sw,
    
    output reg [15:0]led,
    output [7:0]JC,
    output reg [3:0]an = 4'b1111,
    output reg [6:0] seg = 7'b1111111
    
    );
    // Main menu config
    reg [15:0] mainmenu [0:6143];
    reg [15:0] mainmenu2 [0:6143];
    reg menustate;
    initial begin
        $readmemh("mainmenu.mem", mainmenu);
        $readmemh("mainmenu2.mem", mainmenu2);
    end
    
    // Clock setup
    wire clk_6p25mhz;
    wire clk_20khz;
    wire clk_10hz;
    wire clk_12p5mhz;
    wire clk_25mhz;
    wire clk_50khz;
    
    // Mic variables
    wire [11:0]sample; 

    // OLED variables
    wire frame_begin, sending_pixels, sample_pixel;
    wire [4:0] teststate;
    wire [12:0] pixel_index;
    reg[15:0] oled_data;
    
    // HIIT task variables
    wire [15:0]oled_hiit;
    wire [7:0]seg_hiit;
    wire [3:0]an_hiit;
    wire [15:0]led_hiit;
    
    clk_sel s_clk_20khz(basys_clock, 2499, clk_20khz);
    clk_sel s_clk_10hz(basys_clock, 4999999, clk_10hz);
    clk_sel s_clk_6p25mhz(basys_clock, 7, clk_6p25mhz);
    clk_sel s_clk_12p5mhz(basys_clock, 3, clk_12p5mhz);
    clk_sel s_clk_25mhz(basys_clock, 1,clk_25mhz);
    clk_sel s_clk_50khz(basys_clock, 999, clk_50khz);
          
          
    Audio_Capture mic_in(
        .CLK(basys_clock), 
        .cs(clk_20khz),
        .MISO(J_MIC3_Pin3),
        .clk_samp(J_MIC3_Pin1),
        .sclk(J_MIC3_Pin4),
        .sample(sample)
        );
     
   
   initial begin
     oled_data = 0;
   end
  
   // sum_for_the_team = 8+5 = 13
   
   Oled_Display my_oled_unit(
     .clk(clk_6p25mhz),
     .reset(0),
     .frame_begin(frame_begin),
     .sending_pixels(sending_pixels),
     .sample_pixel(sample_pixel),
     .pixel_index(pixel_index),
     .pixel_data(oled_data),
     .teststate(teststate),
     .cs(JC[0]),
     .sdin(JC[1]),
     .sclk(JC[3]),
     .d_cn(JC[4]),
     .resn(JC[5]),
     .vccen(JC[6]),
     .pmoden(JC[7])
   );
   //improvement tasks
   reg [1:0]selected_mode = 0;
   reg reset = 0; //to toggle reset.
   //reg reset = 1; //to toggle reset.
   //to show HIIT improvement task
   test_mod mode2(
        .basys_clock(basys_clock),
        .btnU(btnU),
        .btnC(btnC),
        .btnD(btnD),
        .pixel_index(pixel_index),
        .mic_in(sample),
        .reset(reset),
        //new stuff
        .enable(selected_mode),
        .seg_hiit(seg_hiit),
        .an_hiit(an_hiit),
        .led_hiit(led_hiit),
        .oled_hiit(oled_hiit)
       );

  
  // Oled drawer
  wire [6:0]y;
  wire [6:0]x;
  my_pixel_index m_pi(.pixel_index(pixel_index), .x(x), .y(y));
    
  wire [2:0] greenBus;
  wire led14_foo;
  oled_border_ctl m_border_ctl(.basys_clock(basys_clock), .clk_12p5mhz(clk_12p5mhz), .clk_10hz(clk_10hz), .btnU(btnU), .led14(led14_foo), .greenBus(greenBus));
  wire [2:0] rectBus;
  wire led12_foo;
  oled_rectangles m_rectagles(.basys_clock(basys_clock), .clk_25mhz(clk_25mhz), .clk_10hz(clk_10hz), .btnD(btnD), .led12(led12_foo), .rectBus(rectBus));

// Combined task 3 (AVI) 
  reg [2:0] combined_state;
  reg [11:0] curr_mic_val = 0;
  reg [11:0] peak_val = 0;
  
  // Custom manual segment display
  wire [3:0] an_menu; wire [6:0] seg_menu;
  wire [3:0] an_debug; wire [6:0] seg_debug;
  seg_manual seg_man_menu(.clk(clk_20khz), 
        .v_an0(~7'b0111110), .v_an1(~7'b0110111), .v_an2(~7'b1111001), .v_an3(~7'b0110111), .an(an_menu), .seg(seg_menu)); 
  seg_manual seg_man_debug( .clk(clk_20khz),
        .v_an0(~7'b1111101), .v_an1(~7'b1111111), .v_an2(~7'b1111001), .v_an3(~7'b0111111), .an(an_debug), .seg(seg_debug)); 
  
  // Meditation Params
  // Frequency counter handler
    reg [7:0] freq_peak_cnt;
    wire [15:0] freq_val;
    reg [11:0] peak_value_freq;
    reg [11:0] curr_value_freq;
    always @ (posedge clk_50khz) begin
      // sample 
          freq_peak_cnt <= freq_peak_cnt + 1;  
          curr_value_freq <= sample;
          if (curr_value_freq > peak_value_freq)
              peak_value_freq <= curr_value_freq;
          if(freq_peak_cnt == 0 && sample < 2300) // reset peak_value_freq if it is not sustained
              peak_value_freq <= 0;
    end
    freq_cnt m_freq_cnt(.sample_clock(clk_50khz), .sample(sample), .peak_val(peak_value_freq) , .freq_val(freq_val));
  
      // meditation data
      wire [2:0] meditation_chosen;
      wire [3:0] med_an; wire [6:0] med_seg;
      wire led15;
      meditation m_meditation(.clk(clk_50khz), .enable(selected_mode), .btnU(btnU), .btnD(btnD), .btnC(btnC), .btnL(btnL), .freq_val(freq_val), .chosen_state(meditation_chosen), .an(med_an), .seg(med_seg));
      
      reg [15:0] med_menu_ez [0:6143];
      reg [15:0] med_menu_hard [0:6143];
      reg [15:0] med_higher [0:6143];   
      reg [15:0] med_lower [0:6143];
      reg [15:0] med_maintain [0:6143];
//      reg [15:0] med_done [0:6143];
      
      initial begin
           $readmemh("med_easy.mem", med_menu_ez);
           $readmemh("med_hard.mem", med_menu_hard);
           $readmemh("med_lower.mem", med_lower);
           $readmemh("med_higher.mem", med_higher);
           $readmemh("med_maintain.mem", med_maintain);
//           $readmemh("med_done.mem", med_done);
           
       end
  
  
  
  always @ (posedge basys_clock)
  begin  
    //to reset everything. Takes priority
    if (sw[15]) begin
        reset <= 1;
        selected_mode <= 0;
        an <= 4'b1111;
        seg <= 8'b11111111;
        led <= 0;
    end
    // STATE 0: MENU
    else if(!sw[0] && !sw[1] && !sw[2])
    begin
       // set seg state
       an <= an_menu;
       seg <= seg_menu;
       led <= 0;
       if (btnD)
            menustate <= 1;
       else if(btnU)
            menustate <= 0;
       if(menustate == 0) begin
            oled_data <= mainmenu[pixel_index];
        //type here, if btnC, then select hiit mode.
            if (btnC && selected_mode != 2)
                selected_mode <= 1; 
        end
        //menu state = 1.
       else if (menustate == 1) begin
        oled_data <= mainmenu2[pixel_index];
        //type here, if btnC, then select meditation mode.
            if (btnC && selected_mode != 1)
                selected_mode <= 2;
        end
        //has to be put outside to take priority over other functions. Later then see how to debug. 
        /*if (selected_mode == 1)
            oled_data <= oled_hiit;*/
    end
    // STATE 1: DEBUG, BORDERS
    else if(sw[0] && !sw[1] && !sw[2]) begin
        // set seg state
        an <= an_debug;
        seg <= seg_debug;
            
        led[14] <= led14_foo;
        if( ((x >= 1 && x <= 94) && (y == 1 || y == 63)) || ((x == 1 || x == 94) && (y >= 1 && y <= 63)) ) begin
            oled_data <= 16'b11111_000000_00000;
        end
        else if (((x>=3&&x<=92) && ((y>=3&&y<=5)||(y<=61&&y>=59))) || (((x>=3&&x<=5)||(x<=92&&x>=89)) && (y>=3 && y<=61)) ) begin
            oled_data <= 16'b11111_001111_00000;
        end
        else if(greenBus >= 1 && (((x >= 7 && x <= 87) && (y == 7 || y == 57)) || ((x == 7 || x == 87) && (y >= 7 && y <= 57)))) begin
            oled_data <= 16'b00000_111111_00000;
        end
        else if (greenBus >= 2 && (((x >= 9 && x <= 85) && (y == 9 || y == 55)) || ((x == 9 || x == 85) && (y >= 9 && y <= 55)))) begin
            oled_data <= 16'b00000_111111_00000;
        end
        else if(greenBus >= 3 && (((x >= 11 && x <= 83) && (y == 11 || y == 53)) || ((x == 11 || x == 83) && (y >= 11 && y <= 53)))) begin
            oled_data <= 16'b00000_111111_00000;
        end
        else if(greenBus == 4 && (((x >= 13 && x <= 81) && (y == 13 || y == 51)) || ((x == 13 || x == 81) && (y >= 13 && y <= 51)))) begin
            oled_data <= 16'b00000_111111_00000;
        end
        else begin
            oled_data <= 16'b00000_000000_00000;
        end
    end // individual border
    // STATE 2: DEBUG, RECTANGLES
    else if (sw[1] && !sw[0] && !sw[2]) begin // Rectangle individual activity (LK)
        // set seg state
        an <= an_debug;
        seg <= seg_debug;
        
        led[12] <= led12_foo;
        if (rectBus == 0) begin        
             //this will be the bottom red rectangle
            if ((x>=43 && x<53) && (y>=53 && y<58))             
                oled_data <= 16'b11111_000000_00000;        
            //orange rectangle above red
            else if ((x>=43 && x<53) && (y>=45 && y<50))               
                oled_data <= 16'b11111_000111_00000;               
            else              
                oled_data <= 0;                                  
            end
        else if (rectBus == 1) begin             
                //this will be the bottom red rectangle
                if ((x>=43 && x<53) && (y>=53 && y<58))               
                    oled_data <= 16'b11111_000000_00000;               
                //orange rectangle above red
                else if ((x>=43 && x<53) && (y>=45 && y<50))               
                    oled_data <= 16'b11111_000111_00000;               
                //green rectangle above orange
                else if ((x>=43 && x<53) && (y>=37 && y<42))                
                    oled_data <= 16'b00000_111111_00000;                
                else                
                    oled_data <= 0;
                //debounced signal                             
            end 
        else if (rectBus == 2) begin        
                //this will be the bottom red rectangle
                if ((x>=43 && x<53) && (y>=53 && y<58))               
                    oled_data <= 16'b11111_000000_00000;                
                //orange rectangle above red
                else if ((x>=43 && x<53) && (y>=45 && y<50))               
                    oled_data <= 16'b11111_000111_00000;                
                //green rectangle above orange
                else if ((x>=43 && x<53) && (y>=37 && y<42))                
                    oled_data <= 16'b00000_111111_00000;               
                //dimmer green rectangle
                else if ((x>=43 && x<53) && (y>=29 && y<34))               
                    oled_data <= 16'b00000_001111_00000;                
                //black
                else               
                    oled_data <= 0;               
            end                        
        else if (rectBus == 3) begin        
            //this will be the bottom red rectangle
            if ((x>=43 && x<53) && (y>=53 && y<58))               
               oled_data <= 16'b11111_000000_00000;                
            //orange rectangle above red
            else if ((x>=43 && x<53) && (y>=45 && y<50))               
               oled_data <= 16'b11111_000111_00000;               
            //green rectangle above orange
            else if ((x>=43 && x<53) && (y>=37 && y<42))
               oled_data <= 16'b00000_111111_00000;               
            //dimmer green rectangle
            else if ((x>=43 && x<53) && (y>=29 && y<34))               
                oled_data <= 16'b00000_001111_00000;                
            //even dimmer green rectangle
            else if ((x>=43 && x<53) && (y>=21 && y<26))               
                oled_data <= 16'b00000_000011_00000;                
            //black
            else
                oled_data <= 0;

        end             
    end
    // STATE 3: DEBUG, AVI
    else if (sw[2]) begin
        // set seg state
        
        an <= 4'b1111;
        seg <= 8'b11111111;
        case (combined_state)
            0:
            begin
                seg <= 8'b11000000;
                an <= 4'b1110;
                led <= 16'b0000000000000000;
                oled_data <= 0;
            end
            1:
            begin
                seg <= 8'b11111001;
                an <= 4'b1110;
                led <= 16'b0000000000000001;
                // Red border
                if( ((x >= 1 && x <= 94) && (y == 1 || y == 63)) || ((x == 1 || x == 94) && (y >= 1 && y <= 63)) ) begin
                    oled_data <= 16'b11111_000000_00000;
                end
                
                // Rectangles
                else if ((x>=43 && x<53) && (y>=48 && y<53))               
                   oled_data <= 16'b11111_000000_00000;
                else
                   oled_data <= 0;
            end
            2:
            begin
                seg <= 8'b10100100;
                an <= 4'b1110;
                led <= 16'b0000000000000011;
                
                // Red and orange border
                if( ((x >= 1 && x <= 94) && (y == 1 || y == 63)) || ((x == 1 || x == 94) && (y >= 1 && y <= 63)) ) begin
                                    oled_data <= 16'b11111_000000_00000;
                end
                else if (((x>=3&&x<=92) && ((y>=3&&y<=5)||(y<=61&&y>=59))) || (((x>=3&&x<=5)||(x<=92&&x>=89)) && (y>=3 && y<=61)) ) begin
                            oled_data <= 16'b11111_001111_00000;
                end
                
                // Rectangles
                else if ((x>=43 && x<53) && (y>=48 && y<53))
                    oled_data <= 16'b11111_000000_00000;
                else if ((x>=43 && x<53) && (y>=40 && y<45))
                    oled_data <= 16'b11111_000111_00000;
                else
                    oled_data <= 0;
            end
            3:
            begin
                seg <= 8'b10110000;
                an <= 4'b1110;
                led <= 16'b0000000000000111;
                
                // Red, orange, green 1
                if( ((x >= 1 && x <= 94) && (y == 1 || y == 63)) || ((x == 1 || x == 94) && (y >= 1 && y <= 63)) ) begin
                                    oled_data <= 16'b11111_000000_00000;
                end
                else if (((x>=3&&x<=92) && ((y>=3&&y<=5)||(y<=61&&y>=59))) || (((x>=3&&x<=5)||(x<=92&&x>=89)) && (y>=3 && y<=61)) ) begin
                            oled_data <= 16'b11111_001111_00000;
                end
                else if(((x >= 7 && x <= 87) && (y == 7 || y == 57)) || ((x == 7 || x == 87) && (y >= 7 && y <= 57))) begin
                            oled_data <= 16'b00000_111111_00000;
                end
                
                // Rectangles
                else if ((x>=43 && x<53) && (y>=48 && y<53))
                    oled_data <= 16'b11111_000000_00000;
                else if ((x>=43 && x<53) && (y>=40 && y<45))
                    oled_data <= 16'b11111_000111_00000;
                else if ((x>=43 && x<53) && (y>=32 && y<37))
                    oled_data <= 16'b00000_111111_00000;
                else
                    oled_data <= 0;
            end
            4:
            begin
                seg <= 8'b10011001;
                an <= 4'b1110;
                led <= 16'b0000000000001111;
                
                // Red, orange, green 1,2
                if( ((x >= 1 && x <= 94) && (y == 1 || y == 63)) || ((x == 1 || x == 94) && (y >= 1 && y <= 63)) ) begin
                    oled_data <= 16'b11111_000000_00000;
                end
                else if (((x>=3&&x<=92) && ((y>=3&&y<=5)||(y<=61&&y>=59))) || (((x>=3&&x<=5)||(x<=92&&x>=89)) && (y>=3 && y<=61)) ) begin
                    oled_data <= 16'b11111_001111_00000;
                end
                else if(((x >= 7 && x <= 87) && (y == 7 || y == 57)) || ((x == 7 || x == 87) && (y >= 7 && y <= 57))) begin
                            oled_data <= 16'b00000_111111_00000;
                end                
                else if (((x >= 9 && x <= 85) && (y == 9 || y == 55)) || ((x == 9 || x == 85) && (y >= 9 && y <= 55))) begin
                            oled_data <= 16'b00000_111111_00000;
                end
              
                
                // Rectangles
                else if ((x>=43 && x<53) && (y>=48 && y<53))
                    oled_data <= 16'b11111_000000_00000;
                else if ((x>=43 && x<53) && (y>=40 && y<45))
                    oled_data <= 16'b11111_000111_00000;
                else if ((x>=43 && x<53) && (y>=32 && y<37))
                    oled_data <= 16'b00000_111111_00000;
                else if ((x>=43 && x<53) && (y>=24 && y<29))               
                    oled_data <= 16'b00000_001111_00000;
                else
                    oled_data <= 0;
            end
            5:
            begin
                seg <= 8'b10010010;
                an <= 4'b1110;
                led <= 16'b0000000000011111;
                // Red, orange, green 1,2,3
                if( ((x >= 1 && x <= 94) && (y == 1 || y == 63)) || ((x == 1 || x == 94) && (y >= 1 && y <= 63)) ) begin
                                    oled_data <= 16'b11111_000000_00000;
                end
                else if (((x>=3&&x<=92) && ((y>=3&&y<=5)||(y<=61&&y>=59))) || (((x>=3&&x<=5)||(x<=92&&x>=89)) && (y>=3 && y<=61)) ) begin
                            oled_data <= 16'b11111_001111_00000;
                end
                else if(((x >= 7 && x <= 87) && (y == 7 || y == 57)) || ((x == 7 || x == 87) && (y >= 7 && y <= 57))) begin
                            oled_data <= 16'b00000_111111_00000;
                end                
                else if (((x >= 9 && x <= 85) && (y == 9 || y == 55)) || ((x == 9 || x == 85) && (y >= 9 && y <= 55))) begin
                            oled_data <= 16'b00000_111111_00000;
                end
                else if (((x >= 11 && x <= 83) && (y == 11 || y == 53)) || ((x == 11 || x == 83) && (y >= 11 && y <= 53))) begin
                            oled_data <= 16'b00000_111111_00000;
                end                
                
                // Rectangles
                else if ((x>=43 && x<53) && (y>=48 && y<53))
                    oled_data <= 16'b11111_000000_00000;
                else if ((x>=43 && x<53) && (y>=40 && y<45))
                    oled_data <= 16'b11111_000111_00000;
                else if ((x>=43 && x<53) && (y>=32 && y<37))
                    oled_data <= 16'b00000_111111_00000;
                else if ((x>=43 && x<53) && (y>=24 && y<29))               
                    oled_data <= 16'b00000_001111_00000;
                else if ((x>=43 && x<53) && (y>=16 && y<21))               
                    oled_data <= 16'b00000_000011_00000;
                else
                    oled_data <= 0;
            end
            default:
            begin
                led <= 16'b1111111111111111;                
            end
        endcase     
    end
    if (selected_mode == 1) begin
    
        oled_data <= oled_hiit;
        led <= led_hiit;
        seg <= seg_hiit;
        an <= an_hiit;
    end
    else if (selected_mode == 2)begin
        led <= freq_val;
        an <= med_an;
        seg <= med_seg;
        case(meditation_chosen)
        0: begin
            oled_data <= med_menu_ez[pixel_index];
        end
        1: begin
            oled_data <= med_menu_hard[pixel_index];
        end
        2: begin
            oled_data <= med_lower[pixel_index];
        end
        3: begin
            oled_data <= med_higher[pixel_index];
        end
        4: begin
            oled_data <= med_maintain[pixel_index];
        end
//        5:begin
//            oled_data <= med_done[pixel_index];
//        end
        default: begin
            oled_data <= med_maintain[pixel_index];
        end
        endcase
        
    end
    /*else begin
        //select hiit mode
        if (selected_mode == 1)
            oled_data <= oled_hiit;
    end*/ 
end

// combined task clock ctl
reg [31:0] count2;
 always @ (posedge clk_20khz)begin
      count2 <= count2 + 1;  
      curr_mic_val <= sample;
      if (curr_mic_val > peak_val)
          peak_val <= curr_mic_val;
      if (count2 == 4000) begin
          if (peak_val < 2300)
              combined_state <= 0;
          else if (peak_val >= 2300 && peak_val < 2600)
              combined_state <= 1;
          else if (peak_val >= 2600 && peak_val < 2900)
              combined_state <= 2;
          else if (peak_val >= 2900 && peak_val < 3300)
              combined_state <= 3;
          else if (peak_val >= 3300 && peak_val < 3700)
              combined_state <= 4;
          else
              combined_state <= 5;
          count2 <= 0;
          peak_val <= 0;
      end 
  end
//  audio_vol_indicator avi(.clk_20khz(clk_20khz), .current_mic_value(sample), .led(led[3:0]));
      
endmodule