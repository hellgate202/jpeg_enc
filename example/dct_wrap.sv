module dct_wrap
(
  input           clk_i,
  input           rst_i,
  input [7 : 0]   video_i_tdata,
  input           video_i_tvalid,
  output          video_i_tready,
  input           video_i_tlast,
  input           video_i_tuser,
  output [31 : 0] dct_o_tdata,
  output          dct_o_tvalid,
  input           dct_o_tready,
  output          dct_o_tlast,
  output          dct_o_tuser
);

axi4_stream_if #(
  .TDATA_WIDTH ( 8    ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) video_i (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

assign video_i.tdata  = video_i_tdata;
assign video_i.tvalid = video_i_tvalid;
assign video_i_tready = video_i.tready;
assign video_i.tlast  = video_i_tlast;
assign video_i.tuser  = video_i_tuser;

axi4_stream_if #(
  .TDATA_WIDTH ( 32   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TUSER_WIDTH ( 1    )
) dct_o (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

assign dct_o.tdata  = dct_o_tdata;
assign dct_o.tvalid = dct_o_tvalid;
assign dct_o_tready = dct_o.tready;
assign dct_o.tlast  = dct_o_tlast;
assign dct_o.tuser  = dct_o_tuser;

dct_stage_1 DUT
(
  .clk_i   ( clk_i   ),
  .rst_i   ( rst_i   ),
  .video_i ( video_i ),
  .dct_o   ( dct_o   )
);

endmodule
