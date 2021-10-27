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
                                

axi4_stream_if #(
  .TDATA_WIDTH ( PX_TDATA_WIDTH ),
  .TID_WIDTH   ( 1              ),
  .TDEST_WIDTH ( 1              ),
  .TUSER_WIDTH ( 1              )
) multi_line_video[7 : 0] (
  .aclk        ( clk_i          ),
  .aresetn     ( !rst_i         )
);

multiline_buf #(
  .BUF_AMOUNT    ( 8                ),
  .LINES_PER_BUF ( 2                ),
  .PX_WIDTH      ( PX_WIDTH         ),
  .FRAME_RES_X   ( FRAME_RES_X      )
) multiline_buf_inst (
  .clk_i         ( clk_i            ),
  .rst_i         ( rst_i            ),
  .video_i       ( video_i          ),
  .video_o       ( multi_line_video )
);

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
  .PX_WIDTH    ( PX_WIDTH               )
) line_selector (
  .clk_i       ( clk_i                  ),
  .rst_i       ( rst_i                  ),
  .ser_video_i ( multi_line_video       ),
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

dct_1d #(
  .PX_WIDTH          ( DCT_1D_WIDTH    ),
  .FIXED_POINT_INPUT ( !ROUND_1D_DCT   ),
  .QUANTINIZATION    ( QUANTINIZATION  ),
  .ROUND_OUTPUT      ( ROUND_2D_DCT    )
) dct_stage_2 (
  .clk_i             ( clk_i           ),
  .rst_i             ( rst_i           ),
  .video_i           ( dct_1d_t_stream ),
  .dct_o             ( dct_o           )
);

endmodule
