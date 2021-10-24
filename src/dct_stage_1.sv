/*

  This module performs 1D-DCT to incoming pixel stream
  with 1x8 window

  For now incoming lines must be a multiple of 8

*/

import dct_pkg::*;

module dct_stage_1 #(
  parameter int PX_WIDTH = 8 
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master dct_o
);

// Size of variable before multiplication
localparam int MULT_WIDTH        = PX_WIDTH + 2 + COEF_FRACT_WIDTH;
// Multiplication result_width (-1 because we ommit sign in multiplication)
localparam int MULT_RESULT_WIDTH = ( MULT_WIDTH - 1 ) * 2 + 1;

localparam int DCT_TDATA_WIDTH = ( MULT_WIDTH + 2 ) % 8 ?
                                 ( ( MULT_WIDTH + 2 ) / 8 + 1 ) * 8 :
                                 ( MULT_WIDTH + 2 );

// Two's complement to sign + absolute value
function logic [PX_WIDTH + 1 : 0] tc_to_sa( logic [PX_WIDTH + 1 : 0] tc );

  if( tc[PX_WIDTH + 1] )
    begin
      tc_to_sa[PX_WIDTH + 1] = 1'b1;
      tc_to_sa[PX_WIDTH : 0] = ~tc[PX_WIDTH : 0] + 1'b1;
    end
  else
    tc_to_sa = tc;

endfunction

// Sign + absolute value to two's compement
function logic [MULT_WIDTH - 1 : 0] sa_to_tc( logic [MULT_WIDTH - 1 : 0] sa );

  if( sa[MULT_WIDTH - 1] && sa[MULT_WIDTH - 2 : 0] )
    begin
      sa_to_tc[MULT_WIDTH - 1]     = 1'b1;
      sa_to_tc[MULT_WIDTH - 2 : 0] = ~sa[MULT_WIDTH - 2 : 0] + 1'b1;
    end
  else
    begin
      sa_to_tc[MULT_WIDTH - 1]     = 1'b0;
      sa_to_tc[MULT_WIDTH - 2 : 0] = sa[MULT_WIDTH - 2 : 0];
    end
endfunction

logic [1 : 0][7 : 0][PX_WIDTH : 0] px_lock;
logic                              cur_wr_lock;
logic                              cur_rd_lock;
logic [2 : 0]                      px_cnt;
logic [2 : 0]                      cur_dct;
logic                              dct_sel_run;
logic [PX_WIDTH + 1 : 0]           px_0_p_px_7;
logic [PX_WIDTH + 1 : 0]           px_1_p_px_6;
logic [PX_WIDTH + 1 : 0]           px_2_p_px_5;
logic [PX_WIDTH + 1 : 0]           px_3_p_px_4;
logic [PX_WIDTH + 1 : 0]           px_0_m_px_7;
logic [PX_WIDTH + 1 : 0]           px_1_m_px_6;
logic [PX_WIDTH + 1 : 0]           px_2_m_px_5;
logic [PX_WIDTH + 1 : 0]           px_3_m_px_4;
logic [PX_WIDTH + 1 : 0]           px_0_p_px_7_sa;
logic [PX_WIDTH + 1 : 0]           px_1_p_px_6_sa;
logic [PX_WIDTH + 1 : 0]           px_2_p_px_5_sa;
logic [PX_WIDTH + 1 : 0]           px_3_p_px_4_sa;
logic [PX_WIDTH + 1 : 0]           px_0_m_px_7_sa;
logic [PX_WIDTH + 1 : 0]           px_1_m_px_6_sa;
logic [PX_WIDTH + 1 : 0]           px_2_m_px_5_sa;
logic [PX_WIDTH + 1 : 0]           px_3_m_px_4_sa;
logic [MULT_WIDTH - 1 : 0]         mult_0_px;
logic [MULT_WIDTH - 1 : 0]         mult_0_coef;
logic [MULT_RESULT_WIDTH - 1 : 0]  mult_0_result;
logic [MULT_WIDTH - 1 : 0]         cut_0_result;
logic [MULT_WIDTH - 1 : 0]         mult_1_px;
logic [MULT_WIDTH - 1 : 0]         mult_1_coef;
logic [MULT_RESULT_WIDTH - 1 : 0]  mult_1_result;
logic [MULT_WIDTH - 1 : 0]         cut_1_result;
logic [MULT_WIDTH - 1 : 0]         mult_2_px;
logic [MULT_WIDTH - 1 : 0]         mult_2_coef;
logic [MULT_RESULT_WIDTH - 1 : 0]  mult_2_result;
logic [MULT_WIDTH - 1 : 0]         cut_2_result;
logic [MULT_WIDTH - 1 : 0]         mult_3_px;
logic [MULT_WIDTH - 1 : 0]         mult_3_coef;
logic [MULT_RESULT_WIDTH - 1 : 0]  mult_3_result;
logic [MULT_WIDTH - 1 : 0]         cut_3_result;
logic [MULT_WIDTH - 1 : 0]         cut_0_tc;
logic [MULT_WIDTH - 1 : 0]         cut_1_tc;
logic [MULT_WIDTH - 1 : 0]         cut_2_tc;
logic [MULT_WIDTH - 1 : 0]         cut_3_tc;
logic [1 : 0][MULT_WIDTH : 0]      add_stage;
logic [MULT_WIDTH + 1 : 0]         dct;
logic                              free_lock;
logic [1 : 0]                      lock_full;
logic                              mult_ready;
logic                              data_path_ready;
logic [3 : 0]                      mult_valid_pipe;
logic [3 : 0]                      mult_tlast_pipe;
logic [3 : 0]                      mult_tuser_pipe;
logic [1 : 0]                      tuser_lock;
logic [1 : 0]                      tlast_lock;
logic                              was_tuser;
logic                              was_tlast;

assign video_i.tready = !lock_full[cur_wr_lock];

// Current pixel value - 128 is locked here by 1x8 pack
// Then switch to another lock
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_lock <= ( PX_WIDTH * 2 )'( 0 );
  else
    if( video_i.tvalid && video_i.tready )
      px_lock[cur_wr_lock] <= { { 1'b0, video_i.tdata[PX_WIDTH - 1 : 0] } - 
                              ( PX_WIDTH + 1 )'( ( 2 ** PX_WIDTH ) / 2 ), px_lock[cur_wr_lock][7 : 1] };

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      tuser_lock <= 2'd0;
      tlast_lock <= 2'd0;
    end
  else
    if( video_i.tvalid && video_i.tready )
      begin
        if( video_i.tlast )
          tlast_lock[cur_wr_lock] <= 1'b1;
        if( video_i.tuser )
          tuser_lock[cur_wr_lock] <= 1'b1;
        if( free_lock )
          begin
            tlast_lock[cur_rd_lock] <= 1'b0;
            tuser_lock[cur_rd_lock] <= 1'b0;
          end
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_wr_lock <= 1'b0;
  else
    if( px_cnt == 3'd7 && video_i.tvalid && video_i.tready )
      cur_wr_lock <= !cur_wr_lock;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_rd_lock <= 1'b0;
  else
    if( lock_full[cur_rd_lock] && mult_ready )
      cur_rd_lock <= !cur_rd_lock;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_cnt <= 3'd0;
  else
    if( video_i.tvalid && video_i.tready )
      px_cnt <= px_cnt + 1'b1;

assign free_lock = lock_full[cur_rd_lock] && mult_ready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    lock_full <= 2'd0;
  else
    begin
      if( free_lock )
        lock_full[cur_rd_lock] <= 1'b0;
      if( px_cnt == 3'd7 && video_i.tvalid && video_i.tready )
        lock_full[cur_wr_lock] <= 1'b1;
    end

// Addition and subtraction of pixel values from buffer that is not active
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      px_0_p_px_7 <= ( PX_WIDTH + 1 )'( 0 );
      px_1_p_px_6 <= ( PX_WIDTH + 1 )'( 0 );
      px_2_p_px_5 <= ( PX_WIDTH + 1 )'( 0 );
      px_3_p_px_4 <= ( PX_WIDTH + 1 )'( 0 );
      px_0_m_px_7 <= ( PX_WIDTH + 1 )'( 0 );
      px_1_m_px_6 <= ( PX_WIDTH + 1 )'( 0 );
      px_2_m_px_5 <= ( PX_WIDTH + 1 )'( 0 );
      px_3_m_px_4 <= ( PX_WIDTH + 1 )'( 0 );
      was_tuser   <= 1'b0;
      was_tlast   <= 1'b0;
    end
  else
    if( free_lock )
      begin
        // Values are in two's complement so we do sign extension because
        // overflows are likely to be occured
        px_0_p_px_7 <= { px_lock[cur_rd_lock][0][PX_WIDTH], px_lock[cur_rd_lock][0] } + 
                       { px_lock[cur_rd_lock][7][PX_WIDTH], px_lock[cur_rd_lock][7] };
        px_1_p_px_6 <= { px_lock[cur_rd_lock][1][PX_WIDTH], px_lock[cur_rd_lock][1] } + 
                       { px_lock[cur_rd_lock][6][PX_WIDTH], px_lock[cur_rd_lock][6] };
        px_2_p_px_5 <= { px_lock[cur_rd_lock][2][PX_WIDTH], px_lock[cur_rd_lock][2] } + 
                       { px_lock[cur_rd_lock][5][PX_WIDTH], px_lock[cur_rd_lock][5] };
        px_3_p_px_4 <= { px_lock[cur_rd_lock][3][PX_WIDTH], px_lock[cur_rd_lock][3] } + 
                       { px_lock[cur_rd_lock][4][PX_WIDTH], px_lock[cur_rd_lock][4] };
        px_0_m_px_7 <= { px_lock[cur_rd_lock][0][PX_WIDTH], px_lock[cur_rd_lock][0] } - 
                       { px_lock[cur_rd_lock][7][PX_WIDTH], px_lock[cur_rd_lock][7] };
        px_1_m_px_6 <= { px_lock[cur_rd_lock][1][PX_WIDTH], px_lock[cur_rd_lock][1] } - 
                       { px_lock[cur_rd_lock][6][PX_WIDTH], px_lock[cur_rd_lock][6] };
        px_2_m_px_5 <= { px_lock[cur_rd_lock][2][PX_WIDTH], px_lock[cur_rd_lock][2] } - 
                       { px_lock[cur_rd_lock][5][PX_WIDTH], px_lock[cur_rd_lock][5] };
        px_3_m_px_4 <= { px_lock[cur_rd_lock][3][PX_WIDTH], px_lock[cur_rd_lock][3] } - 
                       { px_lock[cur_rd_lock][4][PX_WIDTH], px_lock[cur_rd_lock][4] };
        was_tuser   <= tuser_lock[cur_rd_lock];
        was_tlast   <= tlast_lock[cur_rd_lock];
      end

assign data_path_ready = !dct_o.tvalid || dct_o.tready;
assign mult_ready      = !dct_sel_run || ( cur_dct == 3'd7 && data_path_ready );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_valid_pipe <= 5'd0;
  else
    if( data_path_ready )
      mult_valid_pipe <= { mult_valid_pipe[4 : 0], dct_sel_run };

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_tuser_pipe <= 5'd0;
  else
    if( data_path_ready )
      mult_tuser_pipe <= { mult_tuser_pipe[4 : 0], cur_dct == 3'd0 && was_tuser };

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_tlast_pipe <= 5'd0;
  else
    if( data_path_ready )
      mult_tlast_pipe <= { mult_tlast_pipe[4 : 0], cur_dct == 3'd7 && was_tlast };

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_dct <= 3'd0;
  else
    if( dct_sel_run && data_path_ready )
      cur_dct <= cur_dct + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    dct_sel_run <= 1'b0;
  else
    if( free_lock )
      dct_sel_run <= 1'b1;
    else
      if( cur_dct == 3'd7 && data_path_ready ) 
        dct_sel_run <= 1'b0;

// Transforming to signed absolute value before multiplication
assign px_0_p_px_7_sa = tc_to_sa( px_0_p_px_7 );
assign px_1_p_px_6_sa = tc_to_sa( px_1_p_px_6 );
assign px_2_p_px_5_sa = tc_to_sa( px_2_p_px_5 );
assign px_3_p_px_4_sa = tc_to_sa( px_3_p_px_4 );
assign px_0_m_px_7_sa = tc_to_sa( px_0_m_px_7 );
assign px_1_m_px_6_sa = tc_to_sa( px_1_m_px_6 );
assign px_2_m_px_5_sa = tc_to_sa( px_2_m_px_5 );
assign px_3_m_px_4_sa = tc_to_sa( px_3_m_px_4 );

// TODO: get COEFS values from ROM instead of parameters
// because parameters will generate LUTs
// We select here which diff/sum value and which coefficient we will be using
// There are 4 blocks of these down below
// Each block is for respective coefficient position inside the matrix
// case value goes through DCT coefficient related to current calculations
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_0_px   <= MULT_WIDTH'( 0 );
      mult_0_coef <= MULT_WIDTH'( 0 );
    end
  else
    if( data_path_ready )
      case( cur_dct )
        3'd0:
          begin
            mult_0_px   <= { px_0_p_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[0][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[0][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd1:
          begin
            mult_0_px   <= { px_0_m_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[1][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[1][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd2:
          begin
            mult_0_px   <= { px_0_p_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[2][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[2][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd3:
          begin
            mult_0_px   <= { px_0_m_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[3][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[3][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd4:
          begin
            mult_0_px   <= { px_0_p_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[4][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[4][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd5:
          begin
            mult_0_px   <= { px_0_m_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[5][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[5][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd6:
          begin
            mult_0_px   <= { px_0_p_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[6][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[6][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd7:
          begin
            mult_0_px   <= { px_0_m_px_7_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_0_coef <= { COEFS[7][0][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[7][0][COEF_FRACT_WIDTH - 1 : 0] };
          end
      endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_1_px   <= MULT_WIDTH'( 0 );
      mult_1_coef <= MULT_WIDTH'( 0 );
    end
  else
    if( data_path_ready )
      case( cur_dct )
        3'd0:
          begin
            mult_1_px   <= { px_1_p_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[0][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[0][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd1:
          begin
            mult_1_px   <= { px_1_m_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[1][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[1][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd2:
          begin
            mult_1_px   <= { px_1_p_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[2][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[2][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd3:
          begin
            mult_1_px   <= { px_1_m_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[3][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[3][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd4:
          begin
            mult_1_px   <= { px_1_p_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[4][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[4][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd5:
          begin
            mult_1_px   <= { px_1_m_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[5][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[5][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd6:
          begin
            mult_1_px   <= { px_1_p_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[6][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[6][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd7:
          begin
            mult_1_px   <= { px_1_m_px_6_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_1_coef <= { COEFS[7][1][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[7][1][COEF_FRACT_WIDTH - 1 : 0] };
          end
      endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_2_px   <= MULT_WIDTH'( 0 );
      mult_2_coef <= MULT_WIDTH'( 0 );
    end
  else
    if( data_path_ready )
      case( cur_dct )
        3'd0:
          begin
            mult_2_px   <= { px_2_p_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[0][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[0][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd1:
          begin
            mult_2_px   <= { px_2_m_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[1][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[1][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd2:
          begin
            mult_2_px   <= { px_2_p_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[2][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[2][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd3:
          begin
            mult_2_px   <= { px_2_m_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[3][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[3][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd4:
          begin
            mult_2_px   <= { px_2_p_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[4][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[4][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd5:
          begin
            mult_2_px   <= { px_2_m_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[5][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[5][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd6:
          begin
            mult_2_px   <= { px_2_p_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[6][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[6][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd7:
          begin
            mult_2_px   <= { px_2_m_px_5_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_2_coef <= { COEFS[7][2][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[7][2][COEF_FRACT_WIDTH - 1 : 0] };
          end
      endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_3_px   <= MULT_WIDTH'( 0 );
      mult_3_coef <= MULT_WIDTH'( 0 );
    end
  else
    if( data_path_ready )
      case( cur_dct )
        3'd0:
          begin
            mult_3_px   <= { px_3_p_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[0][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[0][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd1:
          begin
            mult_3_px   <= { px_3_m_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[1][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[1][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd2:
          begin
            mult_3_px   <= { px_3_p_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[2][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[2][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd3:
          begin
            mult_3_px   <= { px_3_m_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[3][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[3][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd4:
          begin
            mult_3_px   <= { px_3_p_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[4][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[4][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd5:
          begin
            mult_3_px   <= { px_3_m_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[5][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[5][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd6:
          begin
            mult_3_px   <= { px_3_p_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[6][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[6][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
        3'd7:
          begin
            mult_3_px   <= { px_3_m_px_4_sa, COEF_FRACT_WIDTH'( 0 ) };
            mult_3_coef <= { COEFS[7][3][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[7][3][COEF_FRACT_WIDTH - 1 : 0] };
          end
      endcase

// Performing multiplications and restoring sign
// Only 4 multipliers are needed
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_0_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
      mult_1_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
      mult_2_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
      mult_3_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
    end
  else
    if( data_path_ready )
      begin
        mult_0_result                        <= mult_0_px[MULT_WIDTH - 2 : 0] * mult_0_coef[MULT_WIDTH - 2 : 0];
        mult_0_result[MULT_RESULT_WIDTH - 1] <= mult_0_px[MULT_WIDTH - 1] ^ mult_0_coef[MULT_WIDTH - 1];
        mult_1_result                        <= mult_1_px[MULT_WIDTH - 2 : 0] * mult_1_coef[MULT_WIDTH - 2 : 0];
        mult_1_result[MULT_RESULT_WIDTH - 1] <= mult_1_px[MULT_WIDTH - 1] ^ mult_1_coef[MULT_WIDTH - 1];
        mult_2_result                        <= mult_2_px[MULT_WIDTH - 2 : 0] * mult_2_coef[MULT_WIDTH - 2 : 0];
        mult_2_result[MULT_RESULT_WIDTH - 1] <= mult_2_px[MULT_WIDTH - 1] ^ mult_2_coef[MULT_WIDTH - 1];
        mult_3_result                        <= mult_3_px[MULT_WIDTH - 2 : 0] * mult_3_coef[MULT_WIDTH - 2 : 0];
        mult_3_result[MULT_RESULT_WIDTH - 1] <= mult_3_px[MULT_WIDTH - 1] ^ mult_3_coef[MULT_WIDTH - 1];
      end

// Multiplication result is too big, so we cut it in the middle
assign cut_0_result = { mult_0_result[MULT_RESULT_WIDTH - 1], mult_0_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };
assign cut_1_result = { mult_1_result[MULT_RESULT_WIDTH - 1], mult_1_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };
assign cut_2_result = { mult_2_result[MULT_RESULT_WIDTH - 1], mult_2_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };
assign cut_3_result = { mult_3_result[MULT_RESULT_WIDTH - 1], mult_3_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };

// All next calculations will be in two's complement
assign cut_0_tc = sa_to_tc( cut_0_result );
assign cut_1_tc = sa_to_tc( cut_1_result );
assign cut_2_tc = sa_to_tc( cut_2_result );
assign cut_3_tc = sa_to_tc( cut_3_result );

// To get DCT value we need to sum all products
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    add_stage <= ( ( MULT_WIDTH + 1 ) * 2 )'( 0 );
  else
    if( data_path_ready )
      begin
        add_stage[0] <= { cut_0_tc[MULT_WIDTH - 1], cut_0_tc } + 
                        { cut_1_tc[MULT_WIDTH - 1], cut_1_tc };
        add_stage[1] <= { cut_2_tc[MULT_WIDTH - 1], cut_2_tc } + 
                        { cut_3_tc[MULT_WIDTH - 1], cut_3_tc };
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    dct <= ( MULT_WIDTH + 2 )'( 0 );
  else
    if( data_path_ready )
      dct <= { add_stage[0][MULT_WIDTH], add_stage[0] } + 
             { add_stage[1][MULT_WIDTH], add_stage[1] };

//synthesis translate_off

// To see DCT result as fixed point inside simulation
logic [MULT_WIDTH + 1 : 0] dct_sa;
assign dct_sa = dct[MULT_WIDTH + 1] ? { dct[MULT_WIDTH + 1], ~dct[MULT_WIDTH : 0] + 1'b1 } : dct;


real dct_real;
assign dct_real = dct_sa[MULT_WIDTH + 1] ? -( int'( dct_sa[MULT_WIDTH : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ) ) :
                                            int'( dct_sa[MULT_WIDTH : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ); 
//synthesis translate_on

assign dct_o.tdata  = DCT_TDATA_WIDTH'( dct );
assign dct_o.tvalid = mult_valid_pipe[3];
assign dct_o.tlast  = mult_tlast_pipe[3];
assign dct_o.tuser  = mult_tuser_pipe[3];
assign dct_o.tkeep  = '1;
assign dct_o.tstrb  = '1;

endmodule
