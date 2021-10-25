/*
  TODO:
    Module will break if there will be non-multiple of 8 amount of lines
    Module will break if there will be one line of different size
    Temporal solution:
    Reset whole module with tuser
*/
module ser_to_par_video_converter #(
  parameter int LINES_TO_OUTPUT = 8,
  parameter int PX_WIDTH        = 8,
  parameter int FRAME_RES_X     = 1280
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master parallel_video_o
);

localparam int TDATA_WIDTH     = PX_WIDTH % 8 ?
                                 ( PX_WIDTH / 8 + 1 ) * 8 :
                                 PX_WIDTH;
localparam int TDATA_WIDTH_B   = TDATA_WIDTH / 8;
localparam int BUF_AMOUNT      = LINES_TO_OUTPUT * 2;
localparam int BUF_PNT_WIDTH   = $clog2( BUF_AMOUNT );
localparam int PAR_TDATA_WIDTH = ( PX_WIDTH * LINES_TO_OUTPUT ) % 8 ?
                                 ( ( PX_WIDTH * LINES_TO_OUTPUT ) / 8 + 1 ) * 8 :
                                 ( PX_WIDTH * LINES_TO_OUTPUT );

genvar g;

logic [BUF_PNT_WIDTH - 1 : 0]                     buf_pnt;
logic [BUF_AMOUNT - 1 : 0]                        pre_buf_tready;
logic [BUF_AMOUNT - 1 : 0]                        pre_buf_tvalid;
logic [BUF_AMOUNT - 1 : 0]                        buf_empty;
logic                                             change_half;
logic                                             cur_half;
logic                                             read_in_progress;
logic [LINES_TO_OUTPUT - 1 : 0][PX_WIDTH - 1 : 0] output_data;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    buf_pnt <= '0;
  else
    if( video_i.tvalid && video_i.tready && video_i.tlast )
      buf_pnt <= buf_pnt + 1'b1;

assign video_i.tready = pre_buf_tready[buf_pnt];

always_comb
  for( int i = 0; i < BUF_AMOUNT; i++ )
    if( i == buf_pnt )
      pre_buf_tvalid[i] = video_i.tvalid;
    else
      pre_buf_tvalid[i] = 1'b0;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           )
) pre_buf_if[BUF_AMOUNT - 1 : 0] (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           )
) post_buf_if[BUF_AMOUNT - 1 : 0] (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);
generate
  for( g = 0; g < BUF_AMOUNT; g++ )
    begin : pre_buf_if_assignment
      assign pre_buf_if[g].tdata  = video_i.tdata;
      assign pre_buf_if[g].tvalid = pre_buf_tvalid[g];
      assign pre_buf_if[g].tstrb  = video_i.tstrb;
      assign pre_buf_if[g].tkeep  = video_i.tkeep;
      assign pre_buf_if[g].tlast  = video_i.tlast;
      assign pre_buf_if[g].tid    = video_i.tid;
      assign pre_buf_if[g].tdest  = video_i.tdest;
      assign pre_buf_if[g].tuser  = video_i.tuser;
      assign pre_buf_tready[g]    = pre_buf_if[g].tready;
    end
endgenerate

generate
  for( g = 0; g < BUF_AMOUNT; g++ )
    begin : line_buffer
      axi4_stream_fifo #(
        .TDATA_WIDTH   ( TDATA_WIDTH    ),
        .TUSER_WIDTH   ( 1              ),
        .TDEST_WIDTH   ( 1              ),
        .TID_WIDTH     ( 1              ),
        .WORDS_AMOUNT  ( FRAME_RES_X    ),
        .SMART         ( 0              )
      ) line_buffer_inst (
        .clk_i         ( clk_i          ),
        .rst_i         ( rst_i          ),
        .full_o        (                ),
        .empty_o       ( buf_empty[g]   ),
        .drop_o        (                ),
        .used_words_o  (                ),
        .pkts_amount_o (                ),
        .pkt_size_o    (                ),
        .pkt_i         ( pre_buf_if[g]  ),
        .pkt_o         ( post_buf_if[g] )
      );
    end
endgenerate

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_half <= 1'b0;
  else
    if( change_half )
      cur_half <= !cur_half;

assign change_half = cur_half ? post_buf_if[BUF_AMOUNT - 1].tvalid && 
                                post_buf_if[BUF_AMOUNT - 1].tready &&
                                post_buf_if[BUF_AMOUNT - 1].tlast :
                                post_buf_if[LINES_TO_OUTPUT - 1].tvalid && 
                                post_buf_if[LINES_TO_OUTPUT - 1].tready &&
                                post_buf_if[LINES_TO_OUTPUT - 1].tlast;

logic [BUF_AMOUNT - 1 : 0][TDATA_WIDTH - 1 : 0]   post_buf_tdata;
logic [BUF_AMOUNT - 1 : 0]                        post_buf_tvalid;
logic [BUF_AMOUNT - 1 : 0]                        post_buf_tready;
logic [BUF_AMOUNT - 1 : 0][TDATA_WIDTH_B - 1 : 0] post_buf_tstrb;
logic [BUF_AMOUNT - 1 : 0][TDATA_WIDTH_B - 1 : 0] post_buf_tkeep;
logic [BUF_AMOUNT - 1 : 0]                        post_buf_tlast;
logic [BUF_AMOUNT - 1 : 0]                        post_buf_tid;
logic [BUF_AMOUNT - 1 : 0]                        post_buf_tdest;
logic [BUF_AMOUNT - 1 : 0]                        post_buf_tuser;

generate
  for( g = 0; g < BUF_AMOUNT; g++ )
    begin : interface_unpacking
      assign post_buf_tdata[g]     = post_buf_if[g].tdata;
      assign post_buf_tvalid[g]    = post_buf_if[g].tvalid;
      assign post_buf_if[g].tready = post_buf_tready[g];
      assign post_buf_tstrb[g]     = post_buf_if[g].tstrb;
      assign post_buf_tkeep[g]     = post_buf_if[g].tkeep;
      assign post_buf_tlast[g]     = post_buf_if[g].tlast;
      assign post_buf_tid[g]       = post_buf_if[g].tid;
      assign post_buf_tdest[g]     = post_buf_if[g].tdest;
      assign post_buf_tuser[g]     = post_buf_if[g].tuser;
    end
endgenerate

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    read_in_progress <= 1'b0;
  else
    if( cur_half )
      begin
        if( post_buf_if[BUF_AMOUNT - 1].tvalid && post_buf_if[BUF_AMOUNT - 1].tready &&
            post_buf_if[BUF_AMOUNT - 1].tlast )
          read_in_progress <= 1'b0;
        else
          if( !buf_empty[BUF_AMOUNT - 1] )
            read_in_progress <= 1'b1;
      end
    else
      begin
        if( post_buf_if[LINES_TO_OUTPUT - 1].tvalid && post_buf_if[LINES_TO_OUTPUT - 1].tready && 
            post_buf_if[LINES_TO_OUTPUT - 1].tlast )
          read_in_progress <= 1'b0;
        else
          if( !buf_empty[LINES_TO_OUTPUT - 1] )
            read_in_progress <= 1'b1;
      end

always_comb
  begin
    for( int i = 0; i < LINES_TO_OUTPUT; i++ )
      if( !cur_half )
        post_buf_tready[i] = parallel_video_o.tready && read_in_progress;
      else
        post_buf_tready[i] = 1'b0;
    for( int i = LINES_TO_OUTPUT; i < BUF_AMOUNT; i++ )
      if( cur_half )
        post_buf_tready[i] = parallel_video_o.tready && read_in_progress;
      else
        post_buf_tready[i] = 1'b0;
  end

always_comb
  for( int i = 0; i < LINES_TO_OUTPUT; i++ )
    if( cur_half )
      output_data[i] = post_buf_tdata[i + LINES_TO_OUTPUT];
    else
      output_data[i] = post_buf_tdata[i];

assign parallel_video_o.tdata  = PAR_TDATA_WIDTH'( output_data );
assign parallel_video_o.tvalid = cur_half ? read_in_progress && post_buf_tvalid[BUF_AMOUNT - 1] :
                                            read_in_progress && post_buf_tvalid[LINES_TO_OUTPUT - 1];
assign parallel_video_o.tlast  = cur_half ? post_buf_tlast[BUF_AMOUNT - 1] :
                                            post_buf_tlast[LINES_TO_OUTPUT - 1];
assign parallel_video_o.tuser  = cur_half ? post_buf_tuser[LINES_TO_OUTPUT] :
                                            post_buf_tuser[0];
assign parallel_video_o.tstrb  = '1;
assign parallel_video_o.tkeep  = '1;

endmodule
