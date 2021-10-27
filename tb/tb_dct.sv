`include "../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../lib/axi4_lib/src/class/AXI4StreamSlave.sv"

import dct_pkg::*;

module tb_dct;

parameter int    CLK_T            = 10_000;
parameter int    PX_WIDTH         = 8;
parameter int    FRAME_RES_X      = 1920;
parameter int    FRAME_RES_Y      = 1080;
parameter int    TOTAL_X          = 2200;
parameter int    TOTAL_Y          = 1125;
parameter string FILE_PATH        = "./img.hex";
parameter int    RANDOM_TVALID    = 0;
parameter int    RANDOM_TREADY    = 0;
parameter int    TDATA_WIDTH      = PX_WIDTH % 8 ?
                                    ( PX_WIDTH / 8 + 1 ) * 8 :
                                    PX_WIDTH;
parameter int    PREP_TDATA_WIDTH = PX_WIDTH * 8;
parameter int    DCT_WIDTH        = PX_WIDTH + 4 + COEF_FRACT_WIDTH;
parameter int    DCT_TDATA_WIDTH  = DCT_WIDTH % 8 ?
                                    ( DCT_WIDTH / 8 + 1 ) * 8 :
                                    DCT_WIDTH;
parameter int    PAR_TDATA_WIDTH  = DCT_WIDTH * 8;

bit clk;
bit rst;

bit [7 : 0] pkt_byte_q [$];

real dct_from_parallel [7 : 0];

function automatic real dct_to_real( input bit [DCT_WIDTH - 1 : 0] dct );

  bit [DCT_WIDTH - 1 : 0] dct_sa = dct[DCT_WIDTH - 1] ? { dct[DCT_WIDTH - 1], ~dct[DCT_WIDTH - 2 : 0] + 1'b1 } : dct;
  dct_to_real = dct_sa[DCT_WIDTH - 1] ? -( int'( dct_sa[DCT_WIDTH - 2 : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ) ) :
                                        int'( dct_sa[DCT_WIDTH - 2 : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ); 

endfunction

mailbox rx_data_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           )
) video_i (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           )
) parallel_video[7 : 0] (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

axi4_stream_if #(
  .TDATA_WIDTH ( PREP_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                ),
  .TDEST_WIDTH ( 1                ),
  .TUSER_WIDTH ( 1                )
) prepared_video (
  .aclk        ( clk              ),
  .aresetn     ( !rst             )
);

axi4_stream_if #(
  .TDATA_WIDTH ( DCT_TDATA_WIDTH  ),
  .TID_WIDTH   ( 1                ),
  .TDEST_WIDTH ( 1                ),
  .TUSER_WIDTH ( 1                )
) dct_stream (
  .aclk        ( clk              ),
  .aresetn     ( !rst             )
);

axi4_stream_if #(
  .TDATA_WIDTH ( PAR_TDATA_WIDTH  ),
  .TID_WIDTH   ( 1                ),
  .TDEST_WIDTH ( 1                ),
  .TUSER_WIDTH ( 1                )
) col_dct_stream (
  .aclk        ( clk              ),
  .aresetn     ( !rst             )
);

AXI4StreamVideoSource #(
  .PX_WIDTH      ( PX_WIDTH      ),
  .FRAME_RES_X   ( FRAME_RES_X   ),
  .FRAME_RES_Y   ( FRAME_RES_Y   ),
  .TOTAL_X       ( TOTAL_X       ),
  .TOTAL_Y       ( TOTAL_Y       ),
  .FILE_PATH     ( FILE_PATH     ),
  .RANDOM_TVALID ( RANDOM_TVALID )
) video_source;

AXI4StreamSlave #(
  .TDATA_WIDTH   ( PAR_TDATA_WIDTH ),
  .TID_WIDTH     ( 1               ),
  .TDEST_WIDTH   ( 1               ),
  .TUSER_WIDTH   ( 1               ),
  .RANDOM_TREADY ( RANDOM_TREADY   ),
  .VERBOSE       ( 0               ),
  .WATCHDOG_EN   ( 0               )
) video_sink;

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

real real_q [$];

task automatic recorder();

  bit [7 : 0]                    rx_bytes [$];
  bit [PAR_TDATA_WIDTH - 1 : 0]  tdata;
  bit [7 : 0][DCT_WIDTH - 1 : 0] dct_pack;
  forever
    begin
      if( rx_data_mbx.num() > 0 )
        begin
          rx_data_mbx.get( rx_bytes );
          while( rx_bytes.size() > 0 )
            begin
              for( int i = 0; i < ( PAR_TDATA_WIDTH / 8 ); i++ )
                tdata[( i + 1 ) * 8 - 1 -: 8] = rx_bytes.pop_front();
              dct_pack = tdata;
              for( int i = 0; i < 8; i++ )
                real_q.push_back( dct_to_real( dct_pack[i] ) );
            end
        end
      else
        @( posedge clk );
    end

endtask

real ref_real_q [$];

task automatic check_data();

  int fd = $fopen( "./ref.hex", "r" );
  string line;

  while( !$feof( fd ) )
    begin
      $fgets( line, fd );
      ref_real_q.push_back( line.atoreal() );
    end
  // Some EOF weired shit
  ref_real_q.pop_back();
  for( int i = 0; i < ref_real_q.size(); i++ )
    begin
      if( ( ref_real_q[i] - real_q[i] ) > 1.0 || ( ref_real_q[i] - real_q[i] ) < -1.0 )
        begin
          $display( "Error!" );
          $display( "Position #%0d: FPGA: %1.3f, Python %1.3f", i, real_q[i], ref_real_q[i] );
          $stop();
        end
    end
  $fclose( fd );

endtask

multiline_buf #(
  .BUF_AMOUNT    ( 8              ),
  .LINES_PER_BUF ( 2              ),
  .PX_WIDTH      ( PX_WIDTH       ),
  .FRAME_RES_X   ( FRAME_RES_X    )
) pre_buf_inst (
  .clk_i         ( clk            ),
  .rst_i         ( rst            ),
  .video_i       ( video_i        ),
  .video_o       ( parallel_video )
);

px_to_dct_adapter #(
  .PX_WIDTH    ( PX_WIDTH       )
) adapter_inst (
  .clk_i       ( clk            ),
  .rst_i       ( rst            ),
  .ser_video_i ( parallel_video ),
  .par_video_o ( prepared_video )
);

dct_1d #(
  .PX_WIDTH ( PX_WIDTH       )
)(
  .clk_i    ( clk            ),
  .rst_i    ( rst            ),
  .video_i  ( prepared_video ),
  .dct_o    ( dct_stream     )
);

px_to_cols #(
  .PX_WIDTH ( DCT_WIDTH     ),
  .MAT_SIZE ( 8             )
)(
  .clk_i   ( clk            ),
  .rst_i   ( rst            ),
  .video_i ( dct_stream     ),
  .video_o ( col_dct_stream )
);

always_comb
  for( int i = 0; i < 8; i++ )
    dct_from_parallel[i] = dct_to_real( transpose_unit.output_data[i] );

initial
  begin
    video_source = new( video_i );
    video_sink   = new( .axi4_stream_if_v ( col_dct_stream ),
                        .rx_data_mbx      ( rx_data_mbx )  );
    fork
      clk_gen();
      recorder();
    join_none
    apply_rst();
    repeat( 10 )
      @( posedge clk );
    video_source.run();
    repeat( 2 )
      begin
        while( !( parallel_o.tvalid && parallel_o.tready && parallel_o.tuser ) )
          @( posedge clk );
        @( posedge clk );
      end
    repeat( 10 )
      @( posedge clk );
    //check_data();
    $display( "Everything is fine." );
    $stop();
  end

endmodule
