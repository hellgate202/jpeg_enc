module dct_wrap #(
  parameter int PX_WIDTH           = 8,
  parameter int FRAME_RES_X        = 1920,
  parameter int QUANTINIZATION     = 1,
  parameter int ROUND_1D_DCT       = 1,
  parameter int ROUND_2D_DCT       = 1,
  parameter int PX_TDATA_WIDTH     = PX_WIDTH % 8 ?
                                     ( PX_WIDTH / 8 + 1 ) * 8 :
                                     PX_WIDTH,
  parameter int DCT_1D_WIDTH       = ROUND_1D_DCT ? PX_WIDTH + 3 : PX_WIDTH + COEF_FRACT_WIDTH + 3,
  parameter int DCT_2D_WIDTH       = ROUND_1D_DCT && !ROUND_2D_DCT ? DCT_1D_WIDTH + COEF_FRACT_WIDTH + 3 :
                                     !ROUND_1D_DCT && ROUND_2D_DCT ? DCT_1D_WIDTH - COEF_FRACT_WIDTH + 3 :
                                                                     DCT_1D_WIDTH + 3,
  parameter int DCT_2D_TDATA_WIDTH = DCT_2D_WIDTH % 8 ?
                                      ( DCT_2D_WIDTH / 8 + 1 ) * 8 :
                                      DCT_2D_WIDTH
)(
  input                               clk_i,
  input                               rst_i,
  input  [PX_TDATA_WIDTH - 1 : 0]     video_i_tdata,
  input                               video_i_tvalid,
  output                              video_i_tready,
  input                               video_i_tlast,
  input                               video_i_tuser,
  output [DCT_2D_TDATA_WIDTH - 1 : 0] dct_o_tdata,
  output                              dct_o_tvalid,
  input                               dct_o_tready,
  output                              dct_o_tlast,
  output                              dct_o_tuser
);

axi4_stream_if #(
  .TDATA_WIDTH ( PX_TDATA_WIDTH ),
  .TID_WIDTH   ( 1              ),
  .TDEST_WIDTH ( 1              ),
  .TUSER_WIDTH ( 1              )
) video_i (
  .aclk        ( clk            ),
  .aresetn     ( !rst           )
);

assign video_i.tdata  = video_i_tdata;
assign video_i.tvalid = video_i_tvalid;
assign video_i_tready = video_i.tready;
assign video_i.tlast  = video_i_tlast;
assign video_i.tuser  = video_i_tuser;

axi4_stream_if #(
  .TDATA_WIDTH ( DCT_2D_TDATA_WIDTH ),
  .TID_WIDTH   ( 1                  ),
  .TDEST_WIDTH ( 1                  ),
  .TUSER_WIDTH ( 1                  )
) dct_o (
  .aclk        ( clk                ),
  .aresetn     ( !rst               )
);

assign dct_o_tdata  = dct_o.tdata;
assign dct_o_tvalid = dct_o.tvalid;
assign dct_o.tready = dct_o_tready;
assign dct_o_tlast  = dct_o.tlast;
assign dct_o_tuser  = dct_o.tuser;

dct_2d #(
  .PX_WIDTH       ( PX_WIDTH       ),
  .FRAME_RES_X    ( FRAME_RES_X    ),
  .QUANTINIZATION ( QUANTINIZATION ),
  .ROUND_1D_DCT   ( ROUND_1D_DCT   ),
  .ROUND_2D_DCT   ( ROUND_2D_DCT   )
) dct_2d_inst (
  .clk_i          ( clk_i          ),
  .rst_i          ( rst_i          ),
  .video_i        ( video_i        ),
  .dct_o          ( dct_o          )
);

endmodule
