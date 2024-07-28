
`timescale 1 ns / 1 ps

module packet_recv 
  #(
   parameter [31:0]  FPGA_IP = 32'hC0A80164,
   parameter [31:0]  HOST_IP = 32'hC0A80165,
   parameter [15:0]  FPGA_PORT = 16'h4567,
   parameter [15:0]  HOST_PORT = 16'h4567,
   parameter [47:0]  FPGA_MAC = 48'he86a64e7e830,
   parameter [47:0]  HOST_MAC = 48'he86a64e7e829,
   parameter CHECK_DESTINATION = 1
  
    )
   (

    input [1:0]	   RXD,
    input	   RXDV,
   
    input	   clk,
    input	   rst,
   
   
    output	   M_AXIS_TVALID,
    output [7 : 0] M_AXIS_TDATA,
    output	   M_AXIS_TLAST
  );

   // Triple-register received mii data
   
   localparam	   WORD_BYTES = 4;
   localparam integer MII_WIDTH = 2;
   
   
   logic [2:0][MII_WIDTH-1:0] rxd_z;
   logic [2:0]		      rxdv_z;
   
   logic [7:0]	    first_packet_count;

   localparam	    FIRST_PACKET_IGNORE = 0;
   
   always @(posedge clk)                                             
     begin                                                                     
	if (rst)                                                    
	  // Synchronous reset (active low)                                       
	  begin                 
             rxd_z <= 0;
	     rxdv_z <= 0;
	     first_packet_count <= 0;
	     
	     
	  end                                                                   
	else begin
	   rxd_z[0] <= RXD;
	   rxd_z[2:1] <= rxd_z[1:0];
	   
	   rxdv_z[0] <= RXDV;
	   rxdv_z[2:1] <= rxdv_z[1:0];
	   if (packet_done & first_packet_count < FIRST_PACKET_IGNORE) begin
	      first_packet_count <= first_packet_count + 1;
	      
	      
	   end
	end
     end // always @ (posedge clk)
   
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
   

   
   // write in received data until packet has ended
   // this occurs when rxdv goes low.

   logic					 packet_done;
   logic					 packet_start;
   assign packet_start = (rxdv_z[2] == 0 && rxdv_z[1] == 1) ? 1 : 0;
   assign packet_done = (rxdv_z[2] == 1 && rxdv_z[1] == 0) ? 1 : 0;

   
   localparam					 HEADER_BYTES = $bits(ethernet_header)/2;
   localparam					 PREAMBLE_SFD_BYTES = 8*8/2;
   localparam					 FCS_BYTES = 4*8/2;
   
   // header and state buffers
   logic [7:0]					 data_buffer;
   logic [63:0]					 preamble_sfd_buffer;
   logic [63:0]					 preamble_sfd_buffer_next;
   ethernet_header	header_buffer;
   
   // State machine
   typedef enum					 {IDLE, PREAMBLE_SFD, HEADER, DATA }  state_type;

   state_type current_state = IDLE;
   state_type next_state    = IDLE;

   // count the time spent in each state
   logic [31:0]					 state_counter;
   
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
	      state_counter <= state_counter  + 1'b1;
	   end
	end
     end // always @ (posedge clk)
   
   // 3 process state machine
   // 1) decide which state to go into next
   always @(*)
     begin
	next_state = current_state;
	case (current_state)
	  IDLE   :
	    begin
	       // A length is waiting in the fifo
	       if (packet_start) begin
		  next_state = PREAMBLE_SFD;

	       end
	    end
	  PREAMBLE_SFD :
	    begin
	       if (preamble_sfd_buffer_next == 64'hd555555555555555 ) begin
		  next_state = HEADER;
	       end
	    end
	  HEADER  :
	    begin
	       if (state_counter == HEADER_BYTES-1) begin
		  next_state = DATA;
	       end
	       // packet has ended, go back to IDLE
	       if (packet_done) begin
		  next_state = IDLE;

	       end
	    end
	  DATA  :
	    begin
	       // packet has ended, go back to IDLE
	       if (packet_done) begin
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

   logic data_valid;
   logic data_last;
   
   logic [47:0]	packet_destination;
   assign packet_destination = {<<8{header_buffer.mac_destination}};
   
   assign preamble_sfd_buffer_next[63:62] = rst ? 0 : rxd_z[2];
   assign preamble_sfd_buffer_next[61:0] = rst ? 64'b0 : preamble_sfd_buffer[63:2];
   
   // populate and shift buffers according to state
   always_ff@(posedge clk) begin
      if (rst == 1) begin
	 preamble_sfd_buffer <= 0;
	 header_buffer       <= 0;
	 data_buffer         <= 0;
	 data_valid <= 0;
	 data_last <= 0;
	 
	 
      end
      else begin
	 data_valid <= 0;
	 data_last <= 0;
	 
	 // shift buffers during those states
	 if (current_state == PREAMBLE_SFD) begin
	    preamble_sfd_buffer <= preamble_sfd_buffer_next ;
	    
	 end
	 if (current_state == HEADER) begin
	    header_buffer[(HEADER_BYTES*2)-1 -: 2] <= rxd_z[2];
	    header_buffer[(HEADER_BYTES*2)-3:0] <= header_buffer[(HEADER_BYTES*2)-1:2];
	    
	 end
	 if (current_state == DATA) begin
	    data_buffer[7:6] <= rxd_z[2];
	    data_buffer[5:0] <= data_buffer[7:2];
	    

	    if ((state_counter[1:0]==3) && (~CHECK_DESTINATION || (packet_destination == FPGA_MAC))) begin
	       data_valid <= 1;
	       
	    end
	    if (packet_done) begin
	       data_last <= 1;
	       
	    end
	 end
      end
   end

   assign M_AXIS_TVALID = data_valid;
   assign M_AXIS_TDATA = data_buffer;
   assign M_AXIS_TLAST = data_last;
   
endmodule
