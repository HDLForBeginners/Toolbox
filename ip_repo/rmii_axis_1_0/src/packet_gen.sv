`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HdlForBeginners
// Engineer:
//
// Create Date: 13.11.2021 13:55:40
// Design Name:
// Module Name: packet_gen
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

module packet_gen
  #(
   
   parameter [31:0] FPGA_IP = 32'hC0A80164,
   parameter [31:0] HOST_IP = 32'hC0A80165,
   parameter [15:0] FPGA_PORT = 16'h4567,
   parameter [15:0] HOST_PORT = 16'h4567,
   parameter [47:0] FPGA_MAC = 48'he86a64e7e830,
   parameter [47:0] HOST_MAC = 48'he86a64e7e829,
   parameter [15:0] HEADER_CHECKSUM = 16'h65ba,
    
   parameter	    MII_WIDTH = 2,
   parameter	    WORD_BYTES = 1

    )
   (
    input			 CLK,
    input			 RST,

    input [WORD_BYTES*8-1:0]	 S_AXIS_TDATA,
    input			 S_AXIS_TVALID,
    input			 S_AXIS_TLAST,
    output			 S_AXIS_TREADY,
    input [11:0]		 S_AXIS_TUSER,


    output logic		 TX_EN,
    output logic [MII_WIDTH-1:0] TXD
    );


   // create a first
   logic			 s_axis_tfirst;


   always_ff @(posedge CLK)
     begin
	if(RST) begin
           s_axis_tfirst <= 1;

	end
	else begin
           if (S_AXIS_TVALID && S_AXIS_TREADY) begin
              if (S_AXIS_TLAST) begin
                 // After tlast pulse, drive first high
                 s_axis_tfirst <= 1;

              end
              else begin
                 // otherwise, drive it low on valid and ready
                 s_axis_tfirst <= 0;

              end
           end
	end
     end


   typedef struct      packed {
      // UDP Header
      logic [1:0][7:0] udp_checksum;
      logic [1:0][7:0] length;
      logic [1:0][7:0] port_destination;
      logic [1:0][7:0] port_source;
   } udp_header;
   
   typedef struct      packed {
      // IPv4 Header
      udp_header udp;
      logic [3:0][7:0] ip_destination;
      logic [3:0][7:0] ip_source;
      logic [1:0][7:0] header_checksum;
      logic [7:0] protocol;
      logic [7:0] time_to_live;
      logic [1:0][7:0] flags_fragment_offset;
      logic [1:0][7:0] identification;
      logic [1:0][7:0] total_length;
      logic [7:0] dcsp_ecn;
      logic [7:0] version_ihl;
   } ipv4_header;
   
   typedef struct      packed {
      // Ethernet Frame Header
      // no FCS, added later
      ipv4_header ipv4;
      logic [1:0][7:0] eth_type_length;
      logic [5:0][7:0] mac_source;
      logic [5:0][7:0] mac_destination;
   } ethernet_header;
   

   // header and state buffers
   ethernet_header header;
   logic [$bits(ethernet_header)-1 : 0] header_buffer;
   logic [WORD_BYTES*8-1:0]		data_buffer;
   logic [7*8-1:0]			preamble_buffer;
   logic [1*8-1:0]			sfd_buffer;
   logic [4*8-1:0]			fcs;
   logic [4*8-1:0]			fcs_buffer;

   // Number of bytes transferred in each stage
   localparam				HEADER_BYTES = $bits(ethernet_header)/8;
   logic [15:0]				DATA_BYTES;
   assign DATA_BYTES = S_AXIS_TUSER*WORD_BYTES;
   localparam				WAIT_BYTES = 12;
   localparam				SFD_BYTES = 1;
   localparam				PREAMBLE_BYTES = 7;
   localparam				FCS_BYTES = 4;

   // RMII interface is MII_WIDTH bits wide, so divide by MII_WIDTH to get the correct
   // number of iterations per each stage
   localparam				HEADER_LENGTH = HEADER_BYTES*8/MII_WIDTH;
   localparam				WAIT_LENGTH = WAIT_BYTES*8/MII_WIDTH;
   localparam				SFD_LENGTH = SFD_BYTES*8/MII_WIDTH;
   localparam				PREAMBLE_LENGTH = PREAMBLE_BYTES*8/MII_WIDTH;
   localparam				FCS_LENGTH = FCS_BYTES*8/MII_WIDTH;
   logic [31:0]				DATA_LENGTH;
   assign DATA_LENGTH = DATA_BYTES*8/MII_WIDTH;
   localparam				DATA_COUNTER_BITS = $clog2(WORD_BYTES*8/MII_WIDTH);



   // State machine
   typedef enum				{IDLE, PREAMBLE, SFD, HEADER, DATA, FCS, WAIT}  state_type;

   state_type current_state = IDLE;
   state_type next_state    = IDLE;

   // Data fifo
   logic				fifo_full;
   logic				fifo_empty;
   logic [11:0]				fifo_count;
   logic [WORD_BYTES*8-1:0]		fifo_out;
   logic				fifo_rd_en;
   logic				fifo_wr_en;
   logic				packet_start_valid;
   logic				packet_valid;
   logic				fifo_has_space;

   localparam				FIFO_DEPTH = 2048;

   assign fifo_has_space = (fifo_count < FIFO_DEPTH-(S_AXIS_TUSER*WORD_BYTES)) ? 1 : 0;

   // Packet start is only valid when
   // First beat of axi stream and
   // Axis Stream is valid and
   // Axis Stream is ready and
   // Space in FIFO
   // This indicates that this packet has space to go into the fifo
   // Otherwise, it is skipped
   assign packet_start_valid = S_AXIS_TVALID && S_AXIS_TREADY && s_axis_tfirst && fifo_has_space;

   // create packet_valid flag
   always_ff @(posedge CLK)
     begin
	if(RST) begin
           packet_valid <= 0;

	end
	else begin
           // If the start of this packet is valid
           if (packet_start_valid) begin
              // The entire packet is valid
              packet_valid <= 1;

           end

           // If this is the end of a valid packet
           if (packet_valid && S_AXIS_TVALID && S_AXIS_TREADY && S_AXIS_TLAST) begin
              // End of valid packet
              packet_valid <= 0;
           end
	end
     end

   // only write a valid packet
   assign fifo_wr_en = S_AXIS_TVALID & S_AXIS_TREADY & (packet_start_valid || packet_valid);

   // ready if fifo has space
   assign S_AXIS_TREADY = (fifo_has_space & s_axis_tfirst) | packet_valid;

   // Get header
   eth_header_gen
     #(
       .FPGA_MAC(FPGA_MAC),
       .HOST_MAC(HOST_MAC),
       .FPGA_IP(FPGA_IP),
       .HOST_IP(HOST_IP),
       .FPGA_PORT(FPGA_PORT),
       .HOST_PORT(HOST_PORT),
       .HEADER_CHECKSUM(HEADER_CHECKSUM)
       )
   eth_header_gen
     (
      .payload_bytes(S_AXIS_TUSER*WORD_BYTES),
      .output_header(header)

      );

   data_fifo data_fifo_i
     (
      .clk(CLK),
      .srst(RST),
      .din(S_AXIS_TDATA),
      .wr_en(fifo_wr_en),
      .rd_en(fifo_rd_en),
      .dout(fifo_out),
      .full(fifo_full),
      .empty(fifo_empty),
      .data_count(fifo_count)
      );


   // count the time spent in each state
   logic [31:0]                         state_counter;

   always @(posedge CLK)
     begin
	if(RST) begin
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
        case (current_state)
          IDLE   :
            begin
               // If there's enough data in fifo
               if (fifo_count >= S_AXIS_TUSER*WORD_BYTES) begin
                  next_state = PREAMBLE;

               end
               else begin
                  next_state = current_state;

               end
            end
          PREAMBLE:
            begin
               if (state_counter == PREAMBLE_LENGTH-1) begin
                  next_state = SFD;
               end
               else begin
                  next_state = current_state;

               end
            end
          SFD:
            begin
               if (state_counter == SFD_LENGTH-1) begin
                  next_state = HEADER;
               end
               else begin
                  next_state = current_state;

               end
            end
          HEADER  :
            begin
               if (state_counter == HEADER_LENGTH-1) begin
                  next_state = DATA;
               end
               else begin
                  next_state = current_state;

               end
            end
          DATA  :
            begin
               if (state_counter == DATA_LENGTH-1) begin
                  next_state = FCS;
               end
               else begin
                  next_state = current_state;

               end
            end
          FCS  :
            begin
               if (state_counter == FCS_LENGTH-1) begin
                  next_state = WAIT;
               end
               else begin
                  next_state = current_state;

               end
            end
          WAIT   :
            begin
               if (state_counter == WAIT_LENGTH-1) begin
                  next_state = IDLE;
               end
               else begin
                  next_state = current_state;

               end
            end
          default:
            next_state = current_state;
        endcase
     end

   //2) register into that state
   always @(posedge CLK)
     begin
	if(RST) begin
           current_state <= IDLE;
	end
	else begin
           current_state <= next_state;
	end

     end


   // state dependant variables
   logic [MII_WIDTH-1:0]                          tx_data;
   logic					  tx_valid;
   logic					  fcs_en;
   logic					  fcs_rst;

   //3) drive output according to state
   always @(*)
     begin
        case (current_state)
          IDLE   :
            begin
               tx_valid = 0;
               tx_data  = 0;
               fcs_en   = 0;
               fcs_rst   = 1;

            end
          PREAMBLE  :
            begin
               tx_valid = 1;
               tx_data  = preamble_buffer[MII_WIDTH-1:0];
               fcs_en   = 0;
               fcs_rst   = 0;

            end
          SFD  :
            begin
               tx_valid = 1;
               tx_data  = sfd_buffer[MII_WIDTH-1:0];
               fcs_en   = 0;
               fcs_rst   = 0;
            end
          HEADER  :
            begin
               tx_valid = 1;
               tx_data  = header_buffer[MII_WIDTH-1:0];
               fcs_en   = 1;
               fcs_rst   = 0;

            end
          DATA  :
            begin
               tx_valid = 1;
               tx_data  = data_buffer[MII_WIDTH-1:0];
               fcs_en   = 1;
               fcs_rst   = 0;

            end
          FCS:
            begin
               tx_valid = 1;
               tx_data  = fcs_buffer[MII_WIDTH-1:0];
               fcs_en   = 0;
               fcs_rst  = 0;

            end
          WAIT   :
            begin
               tx_valid = 0;
               tx_data  = 0;
               fcs_en   = 0;
               fcs_rst  = 0;

            end
          default:
            begin
               tx_valid = 0;
               tx_data  = 0;
               fcs_en   = 0;
               fcs_rst  = 0;

            end
        endcase
     end

   logic [DATA_COUNTER_BITS-1:0] data_ones;
   assign data_ones = '1;

   // populate and shift buffers according to state
   always_ff@(posedge CLK) begin
      if (RST == 1) begin
         header_buffer   <= 0;
         preamble_buffer <= 0;
         fifo_rd_en      <= 0;

      end
      else begin
         fifo_rd_en      <= 0;

         // buffer loading
         if (current_state == IDLE) begin
            header_buffer   <= header;
            preamble_buffer <= 56'h55555555555555;
            sfd_buffer      <= 8'hd5;
         end
         // and fcs when it's available
         if (next_state == FCS && current_state != FCS) begin
            fcs_buffer <= fcs;
         end
         // and fcs when it's available
         if (next_state == DATA && current_state != DATA) begin
            data_buffer <= fifo_out;
            fifo_rd_en  <= 1;

         end

         // shift buffers during those states
         if (current_state == HEADER) begin
            header_buffer <= header_buffer >> MII_WIDTH;
         end
         if (current_state == PREAMBLE) begin
            preamble_buffer <= preamble_buffer >> MII_WIDTH;
         end
         if (current_state == SFD) begin
            sfd_buffer <= sfd_buffer >> MII_WIDTH;
         end
         if (current_state == DATA && next_state == DATA ) begin
            if (state_counter[DATA_COUNTER_BITS-1:0] == data_ones) begin
               data_buffer <= fifo_out;
               fifo_rd_en  <= 1;

            end
            else begin
               data_buffer <= data_buffer >> MII_WIDTH;
            end
         end
         if (current_state == FCS) begin
            fcs_buffer <= fcs_buffer >> MII_WIDTH;
         end
      end
   end

   // crc generator
   crc_gen crc_gen_i
     (
      .clk(CLK),
      .rst(RST || fcs_rst),

      .data_in(tx_data),
      .crc_en(fcs_en),
      .crc_out(fcs)

      );

   // Register outputs
   //drive tx interfaces

   always @(posedge CLK)

     begin
	if(RST) begin
           TX_EN <= 0;

	end
	else begin
           TX_EN <= tx_valid;
           TXD   <= tx_data;

	end

     end


endmodule
