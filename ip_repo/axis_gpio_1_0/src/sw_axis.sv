`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
//
// Create Date: 14.07.2021 13:47:50
// Design Name: sw_axis
// Module Name: sw_axis
// Project Name: sw_axis
// Target Devices:
// Tool Versions:
// Description:
// Takes an input gpio pin and drives a master AXI-Stream interface
// Pre-pending and appending supplied ASCII character strings
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module sw_axis
  #(
    // number of prefix/postfix characters
    parameter			      PREFIX_CHARS = 31,
    parameter			      POSTFIX_CHARS = 0,
    // those values
    parameter [(8*PREFIX_CHARS)-1:0]  PREFIX_STRING = "SWITCHES CHANGED! NEW VALUE: 0x",
    parameter [(8*POSTFIX_CHARS)-1:0] POSTFIX_STRING = "",
    // GPIO input width
    parameter			      GPIO_WIDTH = 16,
    // output axi bus width
    parameter			      AXI_OUT_WIDTH = 8,
    // Flag indicating if an additional two CRLF bytes must be added on the end
    // This creates a newline
    parameter			      INCLUDE_CRLF = 1,

    // convert the input string to ascii
    parameter			      ASCII_DATA = 1




    )
   ( 
     input			clk,
     input			rst,

     // input gpio
     input [GPIO_WIDTH-1:0]	gpio_in,
   
     // output axi master
     output [AXI_OUT_WIDTH-1:0]	m_axis_data,
     output			m_axis_valid,
     output			m_axis_last,
     output [11:0]		m_axis_tuser,
     input			m_axis_ready
   
     );

   // debounce gpio in
   // These signals are considered independant (ie this is not supposed to be a bus)
   // So they are processed individually
   logic [GPIO_WIDTH-1:0]	gpio_in_debounced;
   logic [GPIO_WIDTH-1:0]	gpio_in_debounced_z;


   debounce
     #(
       .DEBOUNCE_LENGTH(15),
       .NUM_PINS(GPIO_WIDTH)
       )
   debounce_i
     (
      .clk(clk),
      .rst(rst),
      .gpio_in(gpio_in),
      .gpio_out(gpio_in_debounced)
      );
   
   
   // Edge detect on gpio
   // This detects if *any* of the input pins (after debounce) changed
   logic			gpio_changed;
   
   always_ff@(posedge clk)
     begin
        if (rst) begin
           gpio_changed <= 0;
           gpio_in_debounced_z <= 0;
           
        end
        else begin
           gpio_in_debounced_z <= gpio_in_debounced;
           
           if (gpio_in_debounced != gpio_in_debounced_z) begin
              gpio_changed <= 1;
              
           end
           else begin
              gpio_changed <= 0;
              
           end
        end
     end


   // State machine
   // This produces the output axi stream 
   // This state machine writes into an AXI fifo which handles the backpressure for the AXI interface

   // states:
   // IDLE: Waiting for input data
   // PREFIX: Driving out the prefix
   // DATA: Driving out the data
   // POSTFIX: driving out the postfix
   // WAIT: Padding between output words

   typedef enum                     {IDLE, PREFIX, DATA, POSTFIX, WAIT}  state_type;

   // current_state: where I am now
   // next_state: where I'm going to be in the next cycle
   state_type current_state = IDLE;
   state_type next_state    = IDLE;
   
   
   // If we enable INCLUDE_CRLF, the POSTFIX_CHARS and POSTFIX_STRING are extended by 2 bytes
   localparam			    POSTFIX_CHARS_CR = POSTFIX_CHARS+2;
   localparam [(8*(POSTFIX_CHARS_CR))-1:0] POSTFIX_STRING_CR = {POSTFIX_STRING,16'h0A0D};
   
   localparam				   PREFIX_LENGTH = PREFIX_CHARS*8/AXI_OUT_WIDTH;
   localparam				   POSTFIX_LENGTH = INCLUDE_CRLF ? POSTFIX_CHARS_CR*8/AXI_OUT_WIDTH : POSTFIX_CHARS*8/AXI_OUT_WIDTH;
   localparam				   DATA_LENGTH = ASCII_DATA ? GPIO_WIDTH*2/AXI_OUT_WIDTH :  GPIO_WIDTH/AXI_OUT_WIDTH;

   localparam				   PACKET_PADDING = 5;
   

   logic [(8*PREFIX_LENGTH)-1:0]	   prefix_buffer;
   logic [(8*POSTFIX_LENGTH)-1:0]	   postfix_buffer;
   logic [(8*DATA_LENGTH)-1:0]		   data_buffer;
   
   logic				   fifo_full;

   // state dependant variables
   logic [AXI_OUT_WIDTH-1:0]		   axis_data;
   logic				   axis_valid;
   logic				   axis_ready;
   logic				   axis_last;
   logic [11:0]				   axis_user;
   // User contains total output length
   assign axis_user = PREFIX_LENGTH + DATA_LENGTH + POSTFIX_LENGTH;

   
		     
   // count the time spent in each state
   logic [31:0]				   state_counter;

   always @(posedge clk)
     begin
        if(rst) begin
           state_counter  <= '0;

        end
        else begin
           if (current_state != next_state) begin
              state_counter  <= '0;

           end
           else begin
              // otherwise increment counter and shift buffer
              state_counter <= state_counter  + 'd1;
           end
        end
     end
   
   // 3 process state machine
   // 1) decide which state to go into next
   always @(*)
     begin
        next_state = current_state;
        case (current_state)
          IDLE   :
            begin
               if (gpio_changed & ~fifo_full & axis_ready) begin
                  if (PREFIX_LENGTH > 0) begin
                     next_state = PREFIX;
                  end
                  else begin
                     // No prefix, skip to data
                     next_state = DATA;
                     
                  end
               end 
            end
          PREFIX  :
            begin
               if (state_counter == PREFIX_LENGTH-1) begin
                  next_state = DATA;

               end
            end
          DATA  :
            begin
               if (state_counter == DATA_LENGTH-1) begin
                  if (POSTFIX_LENGTH > 0) begin
                     next_state = POSTFIX;

                  end
                  else begin
                     next_state = WAIT;

                  end
               end
            end
          POSTFIX  :
            begin
               if (state_counter == POSTFIX_LENGTH-1) begin
                  // no padding, 
                  next_state = WAIT;

               end
            end
          WAIT  :
            begin
               if (state_counter >= PACKET_PADDING-1) begin
                  next_state = IDLE;
                  
               end
            end
          default:
            next_state = current_state;
        endcase
     end
   
   
   //2) register into that state
   always @(posedge clk)
     begin
        if(rst) begin
           current_state <= IDLE;
        end
        else begin
           current_state <= next_state;
        end

     end

   logic [GPIO_WIDTH*2-1:0] gpio_ascii;

   // Encode switches into ASCII
   // This is the 'manual' way
   /*
    logic [7:0] switches1;
    logic [7:0] switches2;
    logic [7:0] switches3;
    logic [7:0] switches4;
    assign switches1[7:0] = gpio_in_debounced_z[3:0] > 9 ? gpio_in_debounced_z[3:0]+55: gpio_in_debounced_z[3:0]+48;
    assign switches2[15:8] = gpio_in_debounced_z[7:4] > 9 ? gpio_in_debounced_z[7:4]+55: gpio_in_debounced_z[7:4]+48;
    assign switches3[23:16] = gpio_in_debounced_z[11:8] > 9 ? gpio_in_debounced_z[11:8]+55: gpio_in_debounced_z[11:8]+48;
    assign switches4[31:24] = gpio_in_debounced_z[15:12] > 9 ? gpio_in_debounced_z[15:12]+55: gpio_in_debounced_z[15:12]+48;
    */

   // Encode switches into ASCII
   genvar		    i;
   generate;
      for (i = 1;i<=GPIO_WIDTH/4;i=i+1) begin
         assign gpio_ascii[i*8-1 -: 8] = gpio_in_debounced_z[i*4-1 -: 4] > 9 ? gpio_in_debounced_z[i*4-1 -: 4]+55: gpio_in_debounced_z[i*4-1 -: 4]+48;
      end
   endgenerate

   // Load buffers
   always_ff@(posedge clk) begin
      if (rst == 1) begin
         prefix_buffer <= 0;
         data_buffer   <= 0;
         postfix_buffer   <= 0;
         
      end
      else begin
         
         // prefix loading
         if (next_state == PREFIX && current_state != PREFIX) begin
            prefix_buffer   <= {<<8{PREFIX_STRING}};
            
         end
         // and data loading
         if (next_state == DATA && current_state != DATA) begin
            if (ASCII_DATA) begin
               data_buffer <= {<<8{gpio_ascii}}; 
            end
            else begin
               data_buffer <= {<<8{gpio_in_debounced_z}}; 
            end   
            
         end
         // and postfix loading
         if (next_state == POSTFIX && current_state != POSTFIX) begin
            postfix_buffer   <= {<<8{POSTFIX_STRING_CR}};
            
         end

         // shift out buffers
         if (current_state == PREFIX) begin
            prefix_buffer <= prefix_buffer >> AXI_OUT_WIDTH;
         end
         if (current_state == DATA) begin
            data_buffer <= data_buffer >> AXI_OUT_WIDTH;
         end
         if (current_state == POSTFIX) begin
            postfix_buffer <= postfix_buffer >> AXI_OUT_WIDTH;
         end
         
      end
   end

   // drive last on the cycle before we go into idle state
   assign axis_last = (next_state == WAIT & current_state != WAIT) ? 1 : 0;

   //3) drive output according to state
   always @(*)
     begin
        case (current_state)
          IDLE   :
            begin
               axis_valid = 0;
               axis_data  = 0;
               
            end
          PREFIX  :
            begin
               axis_valid = 1;
               axis_data  = prefix_buffer[AXI_OUT_WIDTH-1:0];
               
            end
          DATA  :
            begin
               axis_valid = 1;
               axis_data  = data_buffer[AXI_OUT_WIDTH-1:0];
               
            end
          POSTFIX  :
            begin
               axis_valid = 1;
               axis_data  = postfix_buffer[AXI_OUT_WIDTH-1:0];
            end
          WAIT   :
            begin
               axis_valid = 0;
               axis_data  = 0;

            end
          default:
            begin
               axis_valid = 0;
               axis_data  = 0;

            end
        endcase
     end // always @ (*)
   
   
   axis_data_fifo_tuser axis_data_fifo_tuser 
     (
      .s_axis_aresetn(~rst),          // input wire s_axis_aresetn
      .s_axis_aclk(clk),                // input wire s_axis_aclk
      .s_axis_tvalid(axis_valid),            // input wire s_axis_tvalid
      .s_axis_tready(axis_ready),            // output wire s_axis_tready
      .s_axis_tdata(axis_data),              // input wire [7 : 0] s_axis_tdata
      .s_axis_tlast(axis_last),              // input wire s_axis_tlast
      .s_axis_tuser(axis_user),              // input wire [11 : 0] s_axis_tuser
      .m_axis_tvalid(m_axis_valid),            // output wire m_axis_tvalid
      .m_axis_tready(m_axis_ready),            // input wire m_axis_tready
      .m_axis_tdata(m_axis_data),              // output wire [7 : 0] m_axis_tdata
      .m_axis_tlast(m_axis_last),              // output wire m_axis_tlast
      .m_axis_tuser(),              // output wire [11 : 0] m_axis_tuser
      .axis_wr_data_count(),  // output wire [31 : 0] axis_wr_data_count
      .prog_full(fifo_full)                    // output wire prog_full
      );

   assign m_axis_tuser = axis_user;

   
endmodule
