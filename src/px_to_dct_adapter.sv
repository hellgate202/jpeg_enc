/*
  Reads 8 pixels from each line than go the next line
  Outputs these pixels in parallel
  Also shifts value range by half
*/

module px_to_dct_adapter #(
  parameter int PX_WIDTH = 8
)(
  input clk_i,
  input rst_i,
  axi4_stream_if.slave  ser_video_i [7 : 0],
  axi4_stream_if.master par_video_o
);

localparam int SER_TDATA_WIDTH   = PX_WIDTH % 8 ?
                                   ( PX_WIDTH / 8 + 1 ) * 8 :
                                   PX_WIDTH;
localparam int SER_TDATA_WIDTH_B = SER_TDATA_WIDTH / 8;
localparam int PAR_TDATA_WIDTH   = PX_WIDTH * 8;
localparam int VALUE_SHIFT       = 2 ** PX_WIDTH / 2;

logic [2 : 0]                          px_cnt;
logic [2 : 0]                          ln_cnt;
logic [7 : 0][PX_WIDTH - 1 : 0]        packed_par_tdata;
logic [7 : 0][SER_TDATA_WIDTH - 1 : 0] ser_video_tdata;
logic [7 : 0]                          ser_video_tvalid;
logic [7 : 0]                          ser_video_tready;
logic [7 : 0]                          ser_video_tlast;
logic [7 : 0]                          ser_video_tuser;

genvar g;

generate
  for( g = 0; g < 8; g++ )
    begin : if_unpack
      assign ser_video_tdata[g]    = ser_video_i[g].tdata;
      assign ser_video_tvalid[g]   = ser_video_i[g].tvalid;
      assign ser_video_i[g].tready = ser_video_tready[g];
      assign ser_video_tlast[g]    = ser_video_i[g].tlast;
      assign ser_video_tuser[g]    = ser_video_i[g].tuser;
    end
endgenerate

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_cnt <= 3'd0;
  else
    if( ser_video_tvalid[ln_cnt] && ser_video_tready[ln_cnt] )
      px_cnt <= px_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ln_cnt <= 3'd0;
  else
    if( ser_video_tvalid[ln_cnt] && ser_video_tready[ln_cnt] && px_cnt == 3'd7 )
      ln_cnt <= ln_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    packed_par_tdata <= PAR_TDATA_WIDTH'( 0 );
  else
    if( ser_video_tready[ln_cnt] )
      packed_par_tdata[px_cnt] <= ser_video_tdata[ln_cnt][PX_WIDTH - 1 : 0] - PX_WIDTH'( VALUE_SHIFT );

assign par_video_o.tdata = packed_par_tdata;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    par_video_o.tvalid <= 1'b0;
  else
    if( px_cnt == 3'd7 && ser_video_tvalid[ln_cnt] && ser_video_tready[ln_cnt] )
      par_video_o.tvalid <= 1'b1;
    else
      if( par_video_o.tready )
        par_video_o.tvalid <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    par_video_o.tlast <= 1'b0;
  else
    if( ser_video_tvalid[7] && ser_video_tready[7] && ser_video_tlast[7] )
      par_video_o.tlast <= 1'b1;
    else
      if( par_video_o.tvalid && par_video_o.tready )
        par_video_o.tlast <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    par_video_o.tuser <= 1'b0;
  else
    if( ser_video_tvalid[ln_cnt] && ser_video_tready[ln_cnt] && ser_video_tuser[ln_cnt] )
      par_video_o.tuser <= 1'b1;
    else
      if( par_video_o.tvalid && par_video_o.tready )
        par_video_o.tuser <= 1'b0;

always_comb
  for( int i = 0 ; i < 8; i++ )
    if( 3'( i ) == ln_cnt )
      ser_video_tready[i] = par_video_o.tready || !par_video_o.tvalid;
    else
      ser_video_tready[i] = 1'b0;

endmodule
