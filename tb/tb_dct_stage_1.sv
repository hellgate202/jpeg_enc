`include "../lib/axi4_lib/src/class/AXI4StreamMaster.sv"
import dct_pkg::*;

module tb_dct_stage_1;

parameter CLK_T = 10_000;

bit clk;
bit rst;

bit [7 : 0] pkt_byte_q [$];

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
  .TDATA_WIDTH ( 16   ),
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
  .RANDOM_TVALID ( 0 ),
  .VERBOSE       ( 0 )
) pkt_sender;

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

dct_stage_1 DUT
(
  .clk_i   ( clk     ),
  .rst_i   ( rst     ),
  .video_i ( video_i ),
  .dct_o   ( dct_o   )
);

assign dct_o.tready = 1'b1;

initial
  begin
    pkt_byte_q.push_back( 52 );
    pkt_byte_q.push_back( 55 );
    pkt_byte_q.push_back( 61 );
    pkt_byte_q.push_back( 66 );
    pkt_byte_q.push_back( 70 );
    pkt_byte_q.push_back( 61 );
    pkt_byte_q.push_back( 64 );
    pkt_byte_q.push_back( 73 );
    repeat( 32 )
      pkt_byte_q.push_back( 0 );
    fork
      pkt_sender = new( video_i );
      clk_gen();
    join_none
    apply_rst();
    pkt_sender.send_pkt( pkt_byte_q );
    repeat( 100 )
      @( posedge clk );
    $stop();
  end

endmodule
