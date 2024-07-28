`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 13.11.2021 13:55:40
// Design Name:eth_header_gen
// Module Name:
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
// Creates an ethernet header object based on supplied parameters
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module eth_header_gen
  #(
    
    parameter [31:0] FPGA_IP = 32'hC0A80164,
    parameter [31:0] HOST_IP = 32'hC0A80165,
    parameter [15:0] FPGA_PORT = 16'h4567,
    parameter [15:0] HOST_PORT = 16'h4567,
    parameter [47:0] FPGA_MAC = 48'he86a64e7e830,
    parameter [47:0] HOST_MAC = 48'he86a64e7e829,
    parameter [15:0] HEADER_CHECKSUM = 16'h65ba

    )
   (

    input [11:0]   payload_bytes,
    
    output [499:0] output_header

    );

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
   

   // Fixed Values
   localparam [15:0] ETHERTYPE = 16'h0800;
   localparam [7:0]  VERSION_IHL = 8'h45;
   localparam [7:0]  DCSP_ECN = 8'h00;
   localparam [15:0] IDENTIFICATION = 16'h0000;
   localparam [15:0] FLAGS_FRAGMENT_OFFSET = 16'h0000;
   localparam [7:0]  TIME_TO_LIVE = 8'h40;
   localparam [7:0]  PROTOCOL = 8'h11;
   localparam [15:0] UDP_CHECKSUM = 16'h0000;

   
   localparam [15:0] UDP_HEADER_BYTES = $bits(udp_header)/8;
   localparam [15:0] IPV4_HEADER_BYTES = $bits(ipv4_header)/8;
   

   
   // UDP length is the length of the udp header and payload
   // $ bits is the number of bits within the structure. /8 to get number of bytes
   logic [15:0]	     UDP_LENGTH;
   assign UDP_LENGTH = UDP_HEADER_BYTES + payload_bytes;
   
   // IPv4 Length is the length of the Ipv4 header + payload
   logic [15:0]	     IPV4_LENGTH;
   assign IPV4_LENGTH = IPV4_HEADER_BYTES + payload_bytes;
   
   ethernet_header header;
   assign header.mac_source = {<<8{FPGA_MAC}};
   assign header.mac_destination = {<<8{HOST_MAC}};
   assign header.eth_type_length = {<<8{ETHERTYPE}};
   
   // IPV4 Frame
   assign header.ipv4.version_ihl = {<<8{VERSION_IHL}};
   assign header.ipv4.dcsp_ecn = {<<8{DCSP_ECN}};
   assign header.ipv4.total_length = {<<8{IPV4_LENGTH}};
   assign header.ipv4.identification = {<<8{IDENTIFICATION}};
   assign header.ipv4.flags_fragment_offset = {<<8{FLAGS_FRAGMENT_OFFSET}};
   assign header.ipv4.time_to_live = {<<8{TIME_TO_LIVE}};
   assign header.ipv4.protocol = {<<8{PROTOCOL}};
   assign header.ipv4.header_checksum = {<<8{HEADER_CHECKSUM}};
   assign header.ipv4.ip_source = {<<8{FPGA_IP}};
   assign header.ipv4.ip_destination = {<<8{HOST_IP}};
   
   // UDP Frame
   assign header.ipv4.udp.port_source = {<<8{FPGA_PORT}};
   assign header.ipv4.udp.port_destination = {<<8{HOST_PORT}};
   assign header.ipv4.udp.length = {<<8{UDP_LENGTH}};
   assign header.ipv4.udp.udp_checksum = {<<8{UDP_CHECKSUM}};


   assign output_header = header;

endmodule
