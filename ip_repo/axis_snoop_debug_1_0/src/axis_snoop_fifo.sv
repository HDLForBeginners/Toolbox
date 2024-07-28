
`timescale 1 ns / 1 ps

module axis_snoop_fifo
  #(
    parameter integer PORT_WIDTH = 8
    )
   (
    input wire			   AXIS_ACLK,
    input wire			   AXIS_ARESETN,
   
    // These are all inputs (snoop axi interface)
    input wire			   S_AXIS_TREADY,
    input wire [PORT_WIDTH-1 : 0]  S_AXIS_TDATA,
    input wire			   S_AXIS_TLAST,
    input wire			   S_AXIS_TVALID,

    // the output interface is a normal axis master
    input wire			   M_AXIS_TREADY,
    output wire [PORT_WIDTH-1 : 0] M_AXIS_TDATA,
    output wire			   M_AXIS_TLAST,
    output wire			   M_AXIS_TVALID
   
    );

   // Since this is a snoop interface, there is no backpressure
   // The only overflow behaviour is throwing packets away.
   // To do this, we need to know how long the packet is before we
   // write it in to the fifo. We don't know this information, though,
   // so we assume there's a maximum packet length and use that instead.
   // since this interface is designed to work with ethernet packets
   // a safe assumption is the max ethernet packet size of 1500 bytes.

   // create a first
   logic			   s_axis_tfirst;

   // we want to only write full packets into the fifo
   // we need a first to know when to test to see if this packet can go into the fifo
   // And remember that decision for the entire duration of the packet
   // (so if space opens up mid-way then we still wait until the end of the packet).
   
   always_ff @(posedge AXIS_ACLK)
     begin
	if(~AXIS_ARESETN) begin
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
     end // always_ff @ (posedge CLK)
   
   logic			   prog_full;

   logic			   write_to_fifo;
   logic			   write_to_fifo_l;
   assign write_to_fifo = S_AXIS_TVALID & S_AXIS_TREADY & s_axis_tfirst & ~prog_full;
   
   
   always_ff@(posedge AXIS_ACLK)
     begin
	if (~AXIS_ARESETN) begin
	   write_to_fifo_l <= 0;
	   
	end
	else begin
	   // only flag packet for fifo write
	   if (write_to_fifo) begin
	      write_to_fifo_l <= 1;
	      
	   end

	   // clear latch at end of packet
	   if (S_AXIS_TVALID && S_AXIS_TREADY & S_AXIS_TLAST) begin
	      write_to_fifo_l <= 0;
	      
	   end
	end
     end // always_ff@ (posedge clk)
   
   axis_data_fifo_0 snoop_fifo 
     (
      .s_axis_aresetn(AXIS_ARESETN),          // input wire s_axis_aresetn
      .s_axis_aclk(AXIS_ACLK),                // input wire s_axis_aclk
      .s_axis_tvalid(S_AXIS_TVALID & S_AXIS_TREADY & (write_to_fifo | write_to_fifo_l)),           
      .s_axis_tready(),            // output wire s_axis_tready
      .s_axis_tdata(S_AXIS_TDATA),              // input wire [7 : 0] s_axis_tdata
      .s_axis_tlast(S_AXIS_TLAST),              // input wire s_axis_tlast

      // output interface
      .m_axis_tvalid(M_AXIS_TVALID),            // output wire m_axis_tvalid
      .m_axis_tready(M_AXIS_TREADY),            // input wire m_axis_tready
      .m_axis_tdata(M_AXIS_TDATA),              // output wire [7 : 0] m_axis_tdata
      .m_axis_tlast(M_AXIS_TLAST),              // output wire m_axis_tlast
      .axis_wr_data_count(axis_wr_data_count),  // output wire [31 : 0] axis_wr_data_count
      .prog_full(prog_full)                    // output wire prog_full
      );
   
   
endmodule
