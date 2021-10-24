`include "../lib/axi4_lib/src/class/AXI4StreamMaster.sv"
`include "../lib/axi4_lib/src/class/AXI4StreamSlave.sv"

import dct_pkg::*;

module tb_dct_stage_1;

parameter CLK_T = 10_000;

bit clk;
bit rst;

bit [7 : 0] pkt_byte_q [$];

mailbox rx_data_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( 8    ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) video_i (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 32   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) dct_o (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

AXI4StreamMaster #(
  .TDATA_WIDTH   ( 8 ),
  .TID_WIDTH     ( 1 ),
  .TDEST_WIDTH   ( 1 ),
  .TUSER_WIDTH   ( 1 ),
  .RANDOM_TVALID ( 1 ),
  .VERBOSE       ( 0 )
) pkt_sender;

AXI4StreamSlave #(
  .TDATA_WIDTH   ( 32 ),
  .TID_WIDTH     ( 1 ),
  .TDEST_WIDTH   ( 1 ),
  .TUSER_WIDTH   ( 1 ),
  .RANDOM_TREADY ( 1 ),
  .VERBOSE       ( 0 )
) pkt_receiver;

task automatic clk_gen();

forever
  begin
    #( CLK_T / 2 );
    clk = !clk;
  end

endtask

task automatic apply_rst();

  @( posedge clk );
  rst <= 1'b1;
  @( posedge clk );
  rst <= 1'b0;
  @( posedge clk );

endtask

task automatic send_data();

  @( posedge clk );
  @( posedge clk );

  pkt_byte_q.push_back( 52 );
  pkt_byte_q.push_back( 55 );
  pkt_byte_q.push_back( 61 );
  pkt_byte_q.push_back( 66 );
  pkt_byte_q.push_back( 70 );
  pkt_byte_q.push_back( 61 );
  pkt_byte_q.push_back( 64 );
  pkt_byte_q.push_back( 73 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

  pkt_byte_q.push_back( 63 );
  pkt_byte_q.push_back( 59 );
  pkt_byte_q.push_back( 55 );
  pkt_byte_q.push_back( 90 );
  pkt_byte_q.push_back( 109 );
  pkt_byte_q.push_back( 85 );
  pkt_byte_q.push_back( 69 );
  pkt_byte_q.push_back( 72 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

  pkt_byte_q.push_back( 62 );
  pkt_byte_q.push_back( 59 );
  pkt_byte_q.push_back( 68 );
  pkt_byte_q.push_back( 113 );
  pkt_byte_q.push_back( 144 );
  pkt_byte_q.push_back( 104 );
  pkt_byte_q.push_back( 66 );
  pkt_byte_q.push_back( 73 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

  pkt_byte_q.push_back( 63 );
  pkt_byte_q.push_back( 58 );
  pkt_byte_q.push_back( 71 );
  pkt_byte_q.push_back( 122 );
  pkt_byte_q.push_back( 154 );
  pkt_byte_q.push_back( 106 );
  pkt_byte_q.push_back( 70 );
  pkt_byte_q.push_back( 69 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

  pkt_byte_q.push_back( 67 );
  pkt_byte_q.push_back( 61 );
  pkt_byte_q.push_back( 68 );
  pkt_byte_q.push_back( 104 );
  pkt_byte_q.push_back( 126 );
  pkt_byte_q.push_back( 88 );
  pkt_byte_q.push_back( 68 );
  pkt_byte_q.push_back( 70 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

  pkt_byte_q.push_back( 79 );
  pkt_byte_q.push_back( 65 );
  pkt_byte_q.push_back( 60 );
  pkt_byte_q.push_back( 70 );
  pkt_byte_q.push_back( 77 );
  pkt_byte_q.push_back( 68 );
  pkt_byte_q.push_back( 58 );
  pkt_byte_q.push_back( 75 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

  pkt_byte_q.push_back( 85 );
  pkt_byte_q.push_back( 71 );
  pkt_byte_q.push_back( 64 );
  pkt_byte_q.push_back( 59 );
  pkt_byte_q.push_back( 55 );
  pkt_byte_q.push_back( 61 );
  pkt_byte_q.push_back( 65 );
  pkt_byte_q.push_back( 83 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

  pkt_byte_q.push_back( 87 );
  pkt_byte_q.push_back( 79 );
  pkt_byte_q.push_back( 69 );
  pkt_byte_q.push_back( 68 );
  pkt_byte_q.push_back( 65 );
  pkt_byte_q.push_back( 76 );
  pkt_byte_q.push_back( 78 );
  pkt_byte_q.push_back( 94 );
  pkt_sender.tx_data( pkt_byte_q );
  wait( pkt_sender.pkt_end.triggered );
  @( posedge clk );

endtask

dct_stage_1 DUT
(
  .clk_i   ( clk     ),
  .rst_i   ( rst     ),
  .video_i ( video_i ),
  .dct_o   ( dct_o   )
);

initial
  begin
    fork
      pkt_sender = new( video_i );
      pkt_receiver = new( dct_o, rx_data_mbx );
      clk_gen();
      send_data();
    join_none
    apply_rst();
    repeat( 8 )
      @( pkt_receiver.pkt_end );
    repeat( 10 )
      @( posedge clk );
    $stop();
  end

endmodule
