import dct_pkg::*;

module dct_2d #(
  parameter int PX_WIDTH       = 8,
  parameter int FRAME_RES_X    = 1280,
  parameter int QUANTINIZATION = 1,
  parameter int ROUND_1D_DCT   = 0,
  parameter int ROUND_2D_DCT   = 0
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master dct_o
);

localparam int PX_TDATA_WIDTH       = PX_WIDTH % 8 ?
                                      ( PX_WIDTH / 8 + 1 ) * 8 :
                                      PX_WIDTH;
localparam int PAR_PX_TDATA_WIDTH   = PX_WIDTH * 8;
localparam int DCT_1D_WIDTH         = ROUND_1D_DCT ? PX_WIDTH + 3 : PX_WIDTH + COEF_FRACT_WIDTH + 3;
localparam int DCT_1D_TDATA_WIDTH   = DCT_1D_WIDTH % 8 :
                                      ( DCT_1D_WIDTH / 8 + 1 ) * 8 :
                                      DCT_1D_WIDTH;
localparam int DCT_1D_T_TDATA_WIDTH = DCT_1D_WIDTH * 8;

localparam int DCT_2D_WIDTH         = ROUND_1D_DCT && !ROUND_2D_DCT ? DCT_1D_WIDTH + COEF_FRACT_WIDTH + 3 :
                                      !ROUND_1D_DCT && ROUND_2D_DCT ? DCT_1D_WIDTH - COEF_FRACT_WIDTH + 3 :
                                                                      DCT_1D_WIDTH + 3;
localparam int DCT_2D_TDATA_WIDTH   = DCT_2D_WIDTH % 8 ?
                                      ( DCT_2D_WIDTH / 8 + 1 ) * 8 :
                                      DCT_2D_WIDTH;
localparam int DCT_2D_Q_WIDTH       = QUANTINIZATION ? DCT_2D_WIDTH : $clog2( ( 2 ** DCT_2D_WIDTH - 1 ) / Q_MIN );
localparam int DCT_2D_Q_TDATA_WIDTH = DCT_2D_Q_WIDTH % 8 ?
                                      ( DCT_2D_Q_WIDTH / 8 + 1 ) * 8 :
                                      DCT_2D_Q_WIDTH;

axi4_stream_if #(
  .TDATA_WIDTH ( PAR_PX_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                  ),
  .TDEST_WIDTH ( 1                  ),
  .TUSER_WIDTH ( 1                  )
) parallel_shifted_video (
  .aclk        ( clk_i              ),
  .aresetn     ( !rst_i             )
);

px_to_dct_adapter #(
  .PX_WIDTH    ( PX_WIDTH               ),
  .FRAME_RES_X ( FRAME_RES_X            )
) line_selector (
  .clk_i       ( clk_i                  ),
  .rst_i       ( rst_i                  ),
  .ser_video_i ( video_i                ),
  .par_video_o ( parallel_shifted_video )
);

axi4_stream_if #(
  .TDATA_WIDTH ( DCT_1D_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                  ),
  .TDEST_WIDTH ( 1                  ),
  .TUSER_WIDTH ( 1                  )
) dct_1d_stream (
  .aclk        ( clk_i              ),
  .aresetn     ( !rst_i             )
);

dct_1d #(
  .PX_WIDTH          ( PX_WIDTH               ),
  .FIXED_POINT_INPUT ( 0                      ),
  .QUANTINIZATION    ( 0                      ),
  .ROUND_OUTPUT      ( ROUND_1D_DCT           )
) dct_stage_1 (
  .clk_i             ( clk_i                  ),
  .rst_i             ( rst_i                  ),
  .video_i           ( parallel_shifted_video ),
  .dct_o             ( dct_1d_stream          )
);

axi4_stream_if #(
  .TDATA_WIDTH ( DCT_1D_T_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                    ),
  .TDEST_WIDTH ( 1                    ),
  .TUSER_WIDTH ( 1                    )
) dct_1d_t_stream (
  .aclk        ( clk_i                ),
  .aresetn     ( !rst_i               )
);

px_to_cols #(
  .PX_WIDTH ( DCT_1D_WIDTH    ),
  .MAT_SIZE ( 8               )
) transpose_inst (
  .clk_i    ( clk_i           ),
  .rst_i    ( rst_i           ),
  .video_i  ( dct_1d_stream   ),
  .video_o  ( dct_1d_t_stream )
);

axi4_stream_if #(
  .TDATA_WIDTH ( DCT_2D_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                  ),
  .TDEST_WIDTH ( 1                  ),
  .TUSER_WIDTH ( 1                  )
) dct_2d_stream (
  .aclk        ( clk_i              ),
  .aresetn     ( !rst_i             )
);

dct_1d #(
  .PX_WIDTH          ( DCT_1D_WIDTH    ),
  .FIXED_POINT_INPUT ( !ROUND_1D_DCT   ),
  .QUANTINIZATION    ( QUANTINIZATION  ),
  .ROUND_OUTPUT      ( ROUND_2D_DCT    )
) dct_stage_2 (
  .clk_i             ( clk_i           ),
  .rst_i             ( rst_i           ),
  .video_i           ( dct_1d_t_stream ),
  .dct_o             ( dct_2d_stream   )
);

assign dct_o.tdata          = ( DCT_2D_Q_TDATA_WIDTH )'( dct_2d_stream.tdata[DCT_2D_Q_WIDTH - 1 : 0] );
assign dct_o.tvalid         = dct_2d_stream.tvalid;
assign dct_o.tlast          = dct_2d_stream.tlast;
assign dct_o.tuser          = dct_2d_stream.tuser;
assign dct_o.tstrb          = dct_2d_stream.tstrb;
assign dct_o.tkeep          = dct_2d_stream.tkeep;
assign dct_o.tid            = dct_2d_stream.tid;
assign dct_o.tdest          = dct_2d_stream.tdest;
assign dct_2d_stream.tready = dct_o.tready;

endmodule
