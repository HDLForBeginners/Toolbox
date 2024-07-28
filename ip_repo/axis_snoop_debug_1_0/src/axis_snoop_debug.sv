
`timescale 1 ns / 1 ps

module axis_snoop_debug_v1_0 #
  (
   parameter NUM_INTERFACES = 2,
   parameter PORT_WIDTH = 8
   )
   (

    input wire			  axis_aclk,
    input wire			  axis_aresetn,
   
    // Ports of Axi Slave Bus Interface S00_AXIS
    input wire			  s00_axis_tready,
    input wire [PORT_WIDTH-1 : 0] s00_axis_tdata,
    input wire			  s00_axis_tlast,
    input wire			  s00_axis_tvalid,
   
    // Ports of Axi Slave Bus Interface S01_AXIS
    input wire			  s01_axis_tready,
    input wire [PORT_WIDTH-1 : 0] s01_axis_tdata,
    input wire			  s01_axis_tlast,
    input wire			  s01_axis_tvalid,
   
    // Ports of Axi Slave Bus Interface S02_AXIS
    input wire			  s02_axis_tready,
    input wire [PORT_WIDTH-1 : 0] s02_axis_tdata,
    input wire			  s02_axis_tlast,
    input wire			  s02_axis_tvalid,
   
    // Ports of Axi Slave Bus Interface S03_AXIS
    input wire			  s03_axis_tready,
    input wire [PORT_WIDTH-1 : 0] s03_axis_tdata,
    input wire			  s03_axis_tlast,
    input wire			  s03_axis_tvalid,
   
    input			  m_axis_tready,
    output [PORT_WIDTH-1 : 0]	  m_axis_tdata,
    output			  m_axis_tlast,
    output			  m_axis_tvalid
   
    );

   logic [3:0]			  s_axis_tready;
   logic [3:0][PORT_WIDTH-1 : 0]  s_axis_tdata;
   logic [3:0]			  s_axis_tlast;
   logic [3:0]			  s_axis_tvalid;

   // concatenate signals
   assign s_axis_tready = {s03_axis_tready,s02_axis_tready,s01_axis_tready,s00_axis_tready};
   assign s_axis_tvalid = {s03_axis_tvalid,s02_axis_tvalid,s01_axis_tvalid,s00_axis_tvalid};
   assign s_axis_tlast = {s03_axis_tlast,s02_axis_tlast,s01_axis_tlast,s00_axis_tlast};
   assign s_axis_tdata[0] = s00_axis_tdata;
   assign s_axis_tdata[1] = s01_axis_tdata;
   assign s_axis_tdata[2] = s02_axis_tdata;
   assign s_axis_tdata[3] = s03_axis_tdata;
   
   
   logic [3:0]			  m_axis_tready_all;
   logic [3:0][PORT_WIDTH-1 : 0]  m_axis_tdata_all;
   logic [3:0]			  m_axis_tlast_all;
   logic [3:0]			  m_axis_tvalid_all;
   

   genvar			  i;
   generate
      for (i = 0; i < 4 ; i = i + 1) begin

	 if (i < NUM_INTERFACES) begin
	    axis_snoop_fifo
	      #(
		.PORT_WIDTH(PORT_WIDTH)
		)
	    axis_snoop_fifo_i
	      (
	       .AXIS_ACLK(axis_aclk),
	       .AXIS_ARESETN(axis_aresetn),
	       
	       .S_AXIS_TREADY(s_axis_tready[i]),
	       .S_AXIS_TDATA(s_axis_tdata[i]),
	       .S_AXIS_TLAST(s_axis_tlast[i]),
	       .S_AXIS_TVALID(s_axis_tvalid[i]),

	       .M_AXIS_TREADY(m_axis_tready_all[i]),
	       .M_AXIS_TDATA(m_axis_tdata_all[i]),
	       .M_AXIS_TLAST(m_axis_tlast_all[i]),
	       .M_AXIS_TVALID(m_axis_tvalid_all[i])
	       
	       );
	 end // if (i < NUM_INTERFACES)
	 else begin
	    assign m_axis_tdata_all[i] = 0;
	    assign m_axis_tvalid_all[i] = 0;
	    assign m_axis_tlast_all[i] = 0;
	    
	 end
      end // for (i = 0; i < NUM_INTERFACES ; i = i + 1)
   endgenerate
   
   // when busy, we can't change the channel we are on
   // because we are mid-packet

   // we care currently busy
   logic			  busy;

   // fifo we are currently reading from
   logic [1:0]			  channel_choice;
   logic [1:0]			  next_channel_choice;

   // one of the fifos contains something
   logic			  next_channel_valid;
   
   always_ff @(posedge axis_aclk) begin
      if (~axis_aresetn) begin
         next_channel_choice <= 0;
         next_channel_valid <= 0;

      end
      else begin
         next_channel_valid <= 0;

         // if 0 has data, choose 0
         if (m_axis_tvalid_all[0]) begin
            next_channel_choice <= 0;
            next_channel_valid <= 1;

         end
         // else if 1 has data, 
         else if (m_axis_tvalid_all[1]) begin
            next_channel_choice <= 1;
            next_channel_valid <= 1;
            
         end
         // else if 2
         else if (m_axis_tvalid_all[2]) begin
            next_channel_choice <= 2;
            next_channel_valid <= 1;
            
         end
         // else if 3
         else if (m_axis_tvalid_all[3]) begin
            next_channel_choice <= 3;
            next_channel_valid <= 1;
            
         end
      end
   end

   typedef enum			  {IDLE, WRITING, LAST}  state_type;

   state_type current_state = IDLE;
   state_type next_state    = IDLE;

   
   always @(*)
     begin
        case (current_state)
          IDLE   :
            begin
               // We have a next channel available
               if (next_channel_valid) begin
                  next_state = WRITING;

               end
               else begin
                  next_state = current_state;

               end
            end
          WRITING:
            begin
               // We're done writing when the last databeat is transmitted on the tx
               // switch back to idle
               if (m_axis_tvalid & m_axis_tready & m_axis_tlast) begin
                  next_state = LAST;
               end
               else begin
                  next_state = current_state;

               end
            end
          LAST:
            begin
               next_state = IDLE;
            end
          default:
            next_state = current_state;
        endcase
     end

   //2) register next into current
   always @(posedge axis_aclk)
     begin
	if(~axis_aresetn) begin
           current_state <= IDLE;
	end
	else begin
           current_state <= next_state;
	end

     end

   always @(posedge axis_aclk)
      begin
      if (~axis_aresetn) begin
         channel_choice <= 0;

      end
      else begin
         
         // When we are in IDLE and about to tranisition into WRITING
         // we update the channel choice and seq number
         if(next_state==WRITING && current_state == IDLE) begin
            channel_choice <= next_channel_choice;
         
         end
      end
   end

   assign m_axis_tdata = m_axis_tdata_all[channel_choice];
   assign m_axis_tvalid = m_axis_tvalid_all[channel_choice];
   assign m_axis_tlast = m_axis_tlast_all[channel_choice];

   always_comb begin 
      m_axis_tready_all = 0;

      // route master ready back to chosen slave
      if (current_state == WRITING) begin
         m_axis_tready_all[channel_choice] = m_axis_tready;

      end
      else begin
         m_axis_tready_all[channel_choice] = 0;
         
      end
   end

   
   
endmodule
