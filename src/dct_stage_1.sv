import dct_pkg::*;

module dct_stage_1 #(
  parameter int PX_WIDTH = 8 
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master dct_o
);

localparam int MULT_WIDTH        = PX_WIDTH + 2 + COEF_FRACT_WIDTH;
localparam int MULT_RESULT_WIDTH = ( MULT_WIDTH - 1 ) * 2 + 1;

function logic [PX_WIDTH + 1 : 0] tc_to_sa( logic [PX_WIDTH + 1 : 0] tc );

  if( tc[PX_WIDTH + 1] )
    begin
      tc_to_sa[PX_WIDTH + 1] = 1'b1;
      tc_to_sa[PX_WIDTH : 0] = ~tc[PX_WIDTH : 0] + 1'b1;
    end
  else
    tc_to_sa = tc;

endfunction

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
logic                              cur_lock;
logic [2 : 0]                      px_cnt;
logic [4 : 0][2 : 0]               px_cnt_d;
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

assign video_i.tready = 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_lock <= ( PX_WIDTH * 2 )'( 0 );
  else
    if( video_i.tvalid && video_i.tready )
      px_lock[cur_lock] <= { { 1'b0, video_i.tdata[PX_WIDTH - 1 : 0] } - 
                             ( PX_WIDTH + 1 )'( ( 2 ** PX_WIDTH ) / 2 ), px_lock[cur_lock][7 : 1] };

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_lock <= 1'b0;
  else
    if( px_cnt == 3'd7 && video_i.tvalid && video_i.tready )
      cur_lock <= !cur_lock;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_cnt <= 3'd0;
  else
    if( video_i.tvalid && video_i.tready )
      px_cnt <= px_cnt + 1'b1;

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
    end
  else
    begin
      px_0_p_px_7 <= { px_lock[!cur_lock][0][PX_WIDTH], px_lock[!cur_lock][0] } + 
                     { px_lock[!cur_lock][7][PX_WIDTH], px_lock[!cur_lock][7] };
      px_1_p_px_6 <= { px_lock[!cur_lock][1][PX_WIDTH], px_lock[!cur_lock][1] } + 
                     { px_lock[!cur_lock][6][PX_WIDTH], px_lock[!cur_lock][6] };
      px_2_p_px_5 <= { px_lock[!cur_lock][2][PX_WIDTH], px_lock[!cur_lock][2] } + 
                     { px_lock[!cur_lock][5][PX_WIDTH], px_lock[!cur_lock][5] };
      px_3_p_px_4 <= { px_lock[!cur_lock][3][PX_WIDTH], px_lock[!cur_lock][3] } + 
                     { px_lock[!cur_lock][4][PX_WIDTH], px_lock[!cur_lock][4] };
      px_0_m_px_7 <= { px_lock[!cur_lock][0][PX_WIDTH], px_lock[!cur_lock][0] } - 
                     { px_lock[!cur_lock][7][PX_WIDTH], px_lock[!cur_lock][7] };
      px_1_m_px_6 <= { px_lock[!cur_lock][1][PX_WIDTH], px_lock[!cur_lock][1] } - 
                     { px_lock[!cur_lock][6][PX_WIDTH], px_lock[!cur_lock][6] };
      px_2_m_px_5 <= { px_lock[!cur_lock][2][PX_WIDTH], px_lock[!cur_lock][2] } - 
                     { px_lock[!cur_lock][5][PX_WIDTH], px_lock[!cur_lock][5] };
      px_3_m_px_4 <= { px_lock[!cur_lock][3][PX_WIDTH], px_lock[!cur_lock][3] } - 
                     { px_lock[!cur_lock][4][PX_WIDTH], px_lock[!cur_lock][4] };
    end

assign px_0_p_px_7_sa = tc_to_sa( px_0_p_px_7 );
assign px_1_p_px_6_sa = tc_to_sa( px_1_p_px_6 );
assign px_2_p_px_5_sa = tc_to_sa( px_2_p_px_5 );
assign px_3_p_px_4_sa = tc_to_sa( px_3_p_px_4 );
assign px_0_m_px_7_sa = tc_to_sa( px_0_m_px_7 );
assign px_1_m_px_6_sa = tc_to_sa( px_1_m_px_6 );
assign px_2_m_px_5_sa = tc_to_sa( px_2_m_px_5 );
assign px_3_m_px_4_sa = tc_to_sa( px_3_m_px_4 );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_cnt_d <= 15'd0;
  else
    begin
      px_cnt_d[0] <= px_cnt;
      for( int i = 1; i < 5; i++ )
        px_cnt_d[i] <= px_cnt_d[i - 1];
    end
  
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_0_px   <= MULT_WIDTH'( 0 );
      mult_0_coef <= MULT_WIDTH'( 0 );
    end
  else
    case( px_cnt_d[0] )
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
    case( px_cnt_d[0] )
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
    case( px_cnt_d[0] )
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
    case( px_cnt_d[0] )
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

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_0_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
      mult_1_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
      mult_2_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
      mult_3_result <= ( ( MULT_WIDTH - 1 ) * 2 + 1 )'( 0 );
    end
  else
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

assign cut_0_result = { mult_0_result[MULT_RESULT_WIDTH - 1], mult_0_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };
assign cut_1_result = { mult_1_result[MULT_RESULT_WIDTH - 1], mult_1_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };
assign cut_2_result = { mult_2_result[MULT_RESULT_WIDTH - 1], mult_2_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };
assign cut_3_result = { mult_3_result[MULT_RESULT_WIDTH - 1], mult_3_result[MULT_RESULT_WIDTH - 2 - PX_WIDTH - 1 : COEF_FRACT_WIDTH] };

assign cut_0_tc = sa_to_tc( cut_0_result );
assign cut_1_tc = sa_to_tc( cut_1_result );
assign cut_2_tc = sa_to_tc( cut_2_result );
assign cut_3_tc = sa_to_tc( cut_3_result );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    add_stage <= ( ( MULT_WIDTH + 1 ) * 2 )'( 0 );
  else
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
    dct <= { add_stage[0][MULT_WIDTH], add_stage[0] } + 
           { add_stage[1][MULT_WIDTH], add_stage[1] };

//synthesis translate_off

logic [MULT_WIDTH + 1 : 0] dct_sa;
assign dct_sa = dct[MULT_WIDTH + 1] ? { dct[MULT_WIDTH + 1], ~dct[MULT_WIDTH : 0] + 1'b1 } : dct;


real dct_real;
assign dct_real = dct_sa[MULT_WIDTH + 1] ? -( int'( dct_sa[MULT_WIDTH : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ) ) :
                                            int'( dct_sa[MULT_WIDTH : COEF_FRACT_WIDTH] ) + int'( dct_sa[COEF_FRACT_WIDTH - 1 : 0] ) / real'( 2 ** COEF_FRACT_WIDTH ); 
//synthesis translate_on

endmodule
