`include "../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../lib/axi4_lib/src/class/AXI4StreamSlave.sv"

import dct_pkg::*;

module tb_dct;

parameter int    CLK_T                = 10_000;
parameter int    PX_WIDTH             = 8;
parameter int    FRAME_RES_X          = 1920;
parameter int    FRAME_RES_Y          = 1080;
parameter int    TOTAL_X              = 2200;
parameter int    TOTAL_Y              = 1125;
parameter string FILE_PATH            = "./img.hex";
parameter int    RANDOM_TVALID        = 0;
parameter int    RANDOM_TREADY        = 0;
parameter int    PXTDATA_WIDTH        = PX_WIDTH % 8 ?
                                        ( PX_WIDTH / 8 + 1 ) * 8 :
                                        PX_WIDTH;
parameter int    QUANTINIZATION       = 1;
parameter int    ROUND_1D_DCT         = 1;
parameter int    ROUND_2D_DCT         = 1;

parameter int    PX_TDATA_WIDTH       = PX_WIDTH % 8 ?
                                        ( PX_WIDTH / 8 + 1 ) * 8 :
                                        PX_WIDTH;
parameter int    DCT_1D_WIDTH         = ROUND_1D_DCT ? PX_WIDTH + 3 : PX_WIDTH + COEF_FRACT_WIDTH + 3;
parameter int    DCT_2D_WIDTH         = ROUND_1D_DCT && !ROUND_2D_DCT ? DCT_1D_WIDTH + COEF_FRACT_WIDTH + 3 :
                                        !ROUND_1D_DCT && ROUND_2D_DCT ? DCT_1D_WIDTH - COEF_FRACT_WIDTH + 3 :
                                                                        DCT_1D_WIDTH + 3;
parameter int    DCT_2D_TDATA_WIDTH   = DCT_2D_WIDTH % 8 ?
                                        ( DCT_2D_WIDTH / 8 + 1 ) * 8 :
                                        DCT_2D_WIDTH;
parameter int    DCT_2D_Q_WIDTH       = QUANTINIZATION ? $clog2( ( 2 ** DCT_2D_WIDTH - 1 ) / Q_MIN ) : DCT_2D_WIDTH;
parameter int    DCT_2D_Q_TDATA_WIDTH = DCT_2D_Q_WIDTH % 8 ?
                                        ( DCT_2D_Q_WIDTH / 8 + 1 ) * 8 :
                                        DCT_2D_Q_WIDTH;
parameter int    CHECK_ACCURACY       = 1;
parameter real   ACCURACY_THRESHOLD   = 2.0;

bit clk;
bit rst;

bit [7 : 0] pkt_byte_q [$];

function automatic real dct_to_real( input bit [DCT_2D_Q_WIDTH - 1 : 0] dct );

  bit [DCT_2D_Q_WIDTH - 1 : 0] dct_sa = dct[DCT_2D_Q_WIDTH - 1] ? { dct[DCT_2D_Q_WIDTH - 1], ~dct[DCT_2D_Q_WIDTH - 2 : 0] + 1'b1 } : dct;
  if( ROUND_2D_DCT )
    dct_to_real = dct_sa[DCT_2D_Q_WIDTH - 1] ? -( int'( dct_sa[DCT_2D_Q_WIDTH - 2 : 0] ) ) :
                                        int'( dct_sa[DCT_2D_Q_WIDTH - 2 : 0] ); 
  else
    dct_to_real = dct_sa[DCT_2D_Q_WIDTH - 1] ? -( int'( dct_sa[DCT_2D_Q_WIDTH - 2 : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ) ) :
                                        int'( dct_sa[DCT_2D_Q_WIDTH - 2 : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ); 

endfunction

mailbox rx_data_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( PX_TDATA_WIDTH ),
  .TID_WIDTH   ( 1              ),
  .TDEST_WIDTH ( 1              ),
  .TUSER_WIDTH ( 1              )
) video_i (
  .aclk        ( clk            ),
  .aresetn     ( !rst           )
);

axi4_stream_if #(
  .TDATA_WIDTH ( DCT_2D_Q_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                    ),
  .TDEST_WIDTH ( 1                    ),
  .TUSER_WIDTH ( 1                    )
) dct_o (
  .aclk        ( clk                  ),
  .aresetn     ( !rst                 )
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
  .TDATA_WIDTH   ( DCT_2D_Q_TDATA_WIDTH ),
  .TID_WIDTH     ( 1                    ),
  .TDEST_WIDTH   ( 1                    ),
  .TUSER_WIDTH   ( 1                    ),
  .RANDOM_TREADY ( RANDOM_TREADY        ),
  .VERBOSE       ( 0                    ),
  .WATCHDOG_EN   ( 0                    )
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
real ref_real_q [$];
real max_error;
real acc_error;
real mean_error;

task automatic recorder();

  bit [7 : 0]                        rx_bytes [$];
  bit [DCT_2D_Q_TDATA_WIDTH - 1 : 0] tdata;
  bit [DCT_2D_Q_WIDTH - 1 : 0]       dct;
  real                               abs;
  real                               ref_value;
  real                               rx_value;
  int                                pos;
  forever
    begin
      if( rx_data_mbx.num() > 0 )
        begin
          rx_data_mbx.get( rx_bytes );
          while( rx_bytes.size() > 0 )
            begin
              for( int i = 0; i < ( DCT_2D_Q_TDATA_WIDTH / 8 ); i++ )
                tdata[( i + 1 ) * 8 - 1 -: 8] = rx_bytes.pop_front();
              dct = tdata;
              real_q.push_back( dct_to_real( dct ) );
            end
          while( real_q.size() > 0 )
            begin
              ref_value = ref_real_q.pop_front();
              rx_value  = real_q.pop_front();
              if( ( ref_value - rx_value ) > 0 )
                abs = ref_value - rx_value;
              else
                abs = -( ref_value - rx_value );
              acc_error += abs;
              if( abs > max_error )
                max_error = abs;
              if( ( abs > ACCURACY_THRESHOLD ) && CHECK_ACCURACY )
                begin
                  $display( "Error!" );
                  $display( "Position #%0d: FPGA: %1.3f, Python %1.3f", pos, rx_value, ref_value );
                  repeat( 2 )
                    @( posedge clk );
                  $stop();
                end
              pos++;
            end
        end
      else
        @( posedge clk );
    end

endtask

task automatic read_file();

  int fd;
  string line;

  fd = $fopen( "./ref.hex", "r" );

  while( !$feof( fd ) )
    begin
      $fgets( line, fd );
      ref_real_q.push_back( line.atoreal() );
    end
  ref_real_q.pop_back();

endtask

dct_2d #(
  .PX_WIDTH       ( PX_WIDTH       ),
  .FRAME_RES_X    ( FRAME_RES_X    ),
  .QUANTINIZATION ( QUANTINIZATION ),
  .ROUND_1D_DCT   ( ROUND_1D_DCT   ),
  .ROUND_2D_DCT   ( ROUND_2D_DCT   )
) DUT (
  .clk_i          ( clk            ),
  .rst_i          ( rst            ),
  .video_i        ( video_i        ),
  .dct_o          ( dct_o          )
);

axi4_stream_if #(
  .TDATA_WIDTH ( DCT_2D_Q_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                    ),
  .TDEST_WIDTH ( 1                    ),
  .TUSER_WIDTH ( 1                    )
) zz (
  .aclk        ( clk                  ),
  .aresetn     ( !rst                 )
);

zig_zag #(
  .DCT_WIDTH ( DCT_2D_Q_WIDTH )
) zz_inst (
  .clk_i     ( clk            ),
  .rst_i     ( rst            ),
  .dct_i     ( dct_o          ),
  .zz_o      ( zz             )
);

initial
  begin
    video_source = new( video_i );
    video_sink   = new( .axi4_stream_if_v ( zz       ),
                        .rx_data_mbx      ( rx_data_mbx )  );
    fork
      read_file();
      clk_gen();
      recorder();
    join_none
    apply_rst();
    repeat( 10 )
      @( posedge clk );
    video_source.run();
    repeat( 2 )
      begin
        while( !( zz.tvalid && zz.tready && zz.tuser ) )
          @( posedge clk );
        @( posedge clk );
      end
    repeat( 10 )
      @( posedge clk );
    $display( "Everything is fine." );
    $stop();
  end

endmodule
