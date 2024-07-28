`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
//
// Create Date: 14.07.2021 13:47:50
// Design Name: axis_gpio
// Module Name: axis_gpio
// Project Name: axis_gpio
// Target Devices:
// Tool Versions:
// Description:
// drives a LED output from an input axis slave stream
// This selects byte number BYTE_START with length GPIO_WIDTH and drives that on the led_out pin
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module axis_gpio
  #(
    parameter BYTE_START = 31,
    parameter GPIO_WIDTH = 16,
    parameter AXI_WIDTH = 8

    )
   ( 
     input		     clk,
     input		     rst,

     input [AXI_WIDTH-1:0]   s_axis_data,
     input		     s_axis_valid,
     input		     s_axis_last,
     output		     s_axis_ready,
   
     output [GPIO_WIDTH-1:0] led_out
   
   
     );

   localparam                BYTE_END = BYTE_START + (GPIO_WIDTH/8) - 1;

   
   // Count the bytes on the AXI interface
   logic [31:0]              axi_counter;
   
   always_ff@(posedge clk)
     begin
        if (rst) begin
           axi_counter <= 0;
           
        end
        else begin
           // count while valid
           if (s_axis_valid) begin // no ready
              axi_counter <= axi_counter+1;
           end

           // reset on last
           if (s_axis_valid & s_axis_last) begin
              axi_counter <= 0;
              
           end 
        end
     end


   // Flags indicating start, end, and during butes of interest
   logic gpio_data_start;
   logic gpio_data_end;
   logic gpio_data_en;

   // drive flag high 1 before
   // And with s_axis_valid just in case s_axis_valid goes low during bytes of interest
   // this will stall the output until valid again
   assign gpio_data_start = ((axi_counter == BYTE_START-1) & s_axis_valid) ? 1 : 0;
   assign gpio_data_end = ((axi_counter == BYTE_END) & s_axis_valid) ? 1 : 0;

   logic [GPIO_WIDTH-1 :0] led_buffer;

   // Generate enable flag
   always_ff@(posedge clk)
     begin
        if (rst) begin
           gpio_data_en <= 0;
           
        end
        else begin
           if (gpio_data_start) begin
              gpio_data_en <= 1;
              
           end
           
           if (gpio_data_end) begin
              gpio_data_en <= 0;
              
           end
        end 
     end
   
   // Drive led_buffer with signals from axi stream
   always_ff@(posedge clk)
     begin
        if (rst) begin
           led_buffer <= 0;
           
        end
        else begin
           if (gpio_data_en & s_axis_valid) begin
              led_buffer[AXI_WIDTH-1:0] <= s_axis_data;
              led_buffer[GPIO_WIDTH-1:AXI_WIDTH] <= led_buffer[GPIO_WIDTH-AXI_WIDTH-1:0];
              
           end
        end 
     end
   

   assign led_out = led_buffer;
   assign s_axis_ready = 1;
   
   
endmodule
