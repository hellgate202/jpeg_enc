/*

  This module performs 1D-DCT to incoming pixel stream
  with 1x8 window

  For now incoming lines must be a multiple of 8

  How is DCT optimized here:

  |F[0]|   | c4  c4  c4  c4 |   | f[0] + f[7] |
  |F[2]| = | c2  c6 -c6  c2 | * | f[1] + f[6] |
  |F[4]|   | c4 -c4 -c4  c4 |   | f[2] + f[5] |
  |F[6]|   | c6 -c2  c2 -c6 |   | f[3] + f[4] |

  |F[1]|   | c1  c3  c5  c7 |   | f[0] - f[7] |
  |F[3]| = | c3 -c7 -c1 -c5 | * | f[1] - f[6] |
  |F[5]|   | c5 -c1  c7  c3 |   | f[2] - f[5] |
  |F[7]|   | c7 -c5  c3 -c1 |   | f[3] - f[4] |

  Where: 

  F is DCT vector
  ck is 0.5 * cos( k * pi / 16 )
  f is pixel values vector

*/

import dct_pkg::*;

module dct_1d #(
  parameter int PX_WIDTH = 8 
)(
  input                 clk_i,
  input                 rst_i,
  // Integer unsigned pixel value
  axi4_stream_if.slave  video_i,
  // Fixed point signed DCT value
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
function logic [PX_WIDTH + 1 : 0] tc_to_sa( input logic [PX_WIDTH + 1 : 0] tc );

  if( tc[PX_WIDTH + 1] )
    begin
      tc_to_sa[PX_WIDTH + 1] = 1'b1;
      tc_to_sa[PX_WIDTH : 0] = ~tc[PX_WIDTH : 0] + 1'b1;
    end
  else
    tc_to_sa = tc;

endfunction

// Sign + absolute value to two's compement
function logic [MULT_WIDTH - 1 : 0] sa_to_tc( input logic [MULT_WIDTH - 1 : 0] sa );

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

logic [7 : 0][PX_WIDTH : 0]              px_unpack;
logic [2 : 0]                            cur_dct;
logic                                    dct_sel_run;
logic [7 : 0][PX_WIDTH + 1 : 0]          px_delta;
logic [7 : 0][PX_WIDTH + 1 : 0]          px_delta_sa;
logic [3 : 0][MULT_WIDTH - 1 : 0]        mult_px;
logic [3 : 0][MULT_WIDTH - 1 : 0]        mult_coef;
logic [3 : 0][MULT_RESULT_WIDTH - 1 : 0] mult_result;
logic [3 : 0][MULT_WIDTH - 1 : 0]        cut_tc;
logic [1 : 0][MULT_WIDTH : 0]            add_stage;
logic [MULT_WIDTH + 1 : 0]               dct;
logic                                    mult_ready;
logic                                    data_path_ready;
logic [3 : 0]                            mult_valid_pipe;
logic [3 : 0]                            mult_tlast_pipe;
logic [3 : 0]                            mult_tuser_pipe;
logic                                    was_tuser;
logic                                    was_tlast;

assign video_i.tready = mult_ready;

assign px_unpack = video_i.tdata;

// Addition and subtraction of pixel values from buffer that is not active
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_delta    <= ( ( PX_WIDTH + 2 ) * 8 )'( 0 );
  else
    if( mult_ready )
      // Values are in two's complement so we do sign extension because
      // overflows are likely to be occured
      for( int i = 0; i < 4; i++ )
        begin
          px_delta[i * 2]     <= { px_unpack[i][PX_WIDTH], px_unpack[i] } +
                                 { px_unpack[7 - i][PX_WIDTH], px_unpack[7 - i] };
          px_delta[i * 2 + 1] <= { px_unpack[i][PX_WIDTH], px_unpack[i] } -
                                 { px_unpack[7 - i][PX_WIDTH], px_unpack[7 - i] };
        end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      was_tuser <= 1'b0;
      was_tlast <= 1'b0;
    end
  else
    if( mult_ready )
      begin
        was_tuser <= video_i.tuser;
        was_tlast <= video_i.tlast;
      end
    else
      if( data_path_ready )
        begin
          if( cur_dct == 3'd0 )
            was_tuser <= 1'b0;
          if( cur_dct == 3'd7 )
            was_tlast <= 1'b0;
        end

assign data_path_ready = !dct_o.tvalid || dct_o.tready;
assign mult_ready      = !dct_sel_run || ( cur_dct == 3'd7 && data_path_ready );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_valid_pipe <= 5'd0;
  else
    if( data_path_ready )
      mult_valid_pipe <= { mult_valid_pipe[2 : 0], dct_sel_run };

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_tuser_pipe <= 5'd0;
  else
    if( data_path_ready )
      mult_tuser_pipe <= { mult_tuser_pipe[2 : 0], cur_dct == 3'd0 && was_tuser };

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_tlast_pipe <= 5'd0;
  else
    if( data_path_ready )
      mult_tlast_pipe <= { mult_tlast_pipe[2 : 0], cur_dct == 3'd7 && was_tlast };

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
    if( mult_ready && video_i.tvalid )
      dct_sel_run <= 1'b1;
    else
      if( cur_dct == 3'd7 && data_path_ready ) 
        dct_sel_run <= 1'b0;

// Transforming to signed absolute value before multiplication
always_comb
  for( int i = 0; i < 8; i++ )
    px_delta_sa[i] = tc_to_sa( px_delta[i] );

// Weired magic happening there
// Look for description of algorithm in the header
// we are preparing what's is needed to be multiplied
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mult_px   <= ( MULT_WIDTH * 4 )'( 0 );
      mult_coef <= ( MULT_WIDTH * 4 )'( 0 );
    end
  else
    if( data_path_ready )
      for( int i = 0; i < 8; i ++ )
        if( cur_dct == 3'( i ) )
          for( int j = 0; j < 4; j++ )
            begin
              mult_px[j]   <= { px_delta_sa[j * 2 + i % 2], COEF_FRACT_WIDTH'( 0 ) };
              mult_coef[j] <= { COEFS[i][j][COEF_FRACT_WIDTH], ( PX_WIDTH + 1 )'( 0 ), COEFS[i][j][COEF_FRACT_WIDTH - 1 : 0] };
            end

// Performing multiplications and restoring sign
// Only 4 multipliers are needed
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_result <= ( MULT_RESULT_WIDTH * 4 )'( 0 );
  else
    if( data_path_ready )
      for( int i = 0; i < 4; i++ )
        begin
          mult_result[i] <= mult_px[i][MULT_WIDTH - 2 : 0] * mult_coef[i][MULT_WIDTH - 2 : 0];
          mult_result[i][MULT_RESULT_WIDTH - 1] <= mult_px[i][MULT_WIDTH - 1] ^ mult_coef[i][MULT_WIDTH - 1];
        end


// All next calculations will be in two's complement
always_comb
  for( int i = 0; i < 4; i++ )
    cut_tc[i] = sa_to_tc( { mult_result[i][MULT_RESULT_WIDTH - 1], 
                            mult_result[i][MULT_RESULT_WIDTH - PX_WIDTH - 3 : COEF_FRACT_WIDTH] } );

// To get DCT value we need to sum all products
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    add_stage <= ( ( MULT_WIDTH + 1 ) * 2 )'( 0 );
  else
    if( data_path_ready )
      begin
        add_stage[0] <= { cut_tc[0][MULT_WIDTH - 1], cut_tc[0] } + 
                        { cut_tc[1][MULT_WIDTH - 1], cut_tc[1] };
        add_stage[1] <= { cut_tc[2][MULT_WIDTH - 1], cut_tc[2] } + 
                        { cut_tc[3][MULT_WIDTH - 1], cut_tc[3] };
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
