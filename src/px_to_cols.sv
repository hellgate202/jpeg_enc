module mat_transpose #(
  parameter int PX_WIDTH = 8,
  // Only square matrices
  parameter int MAT_SIZE = 8
)(
  input                 clk_i,
  input                 rst_i
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int MAT_ELEMS    = MAT_SIZE * MAT_SIZE;
localparam int ADDR_WIDTH   = $clog2( MAT_ELEMS );
localparam int RD_CNT_WIDTH = $clog2( MAT_SIZE );
localparam int TDATA_WIDTH  = ( MAT_SIZE * PX_WIDTH ) % 8 ?
                              ( MAT_SIZE * PX_WIDTH / 8 + 1 ) * 8 :
                              ( MAT_SIZE * PX_WIDTH );

logic [ADDR_WIDTH - 1 : 0]                 wr_ptr;
logic [1 : 0]                              wr;
logic [ADDR_WIDTH - 1 : 0]                 rd_ptr;
logic [1 : 0]                              rd;
logic [1 : 0][PX_WIDTH - 1 : 0]            rd_px_data;
logic [1 : 0]                              buf_empty, buf_empty_comb;
logic [1 : 0]                              buf_full, buf_full_comb;
logic                                      data_path_ready;
logic [MAT_SIZE - 1 : 0][PX_WIDTH - 1 : 0] output_data;
logic [1 : 0]                              tuser_lock;
logic [1 : 0]                              tlast_lock;

enum logic [1 : 0] { WRITE_BUF_0_S,
                     WAIT_BUF_1_EMPTY_S,
                     WRITE_BUF_1_S,
                     WAIT_BUF_0_EMPTY_S } state_wr, next_state_wr;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    state_wr <= WRITE_BUF_0_S;
  else
    state_wr <= next_state_wr;

always_comb
  begin
    next_state_wr = state_wr;
    case( state_wr )
      begin
        WRITE_BUF_0_S:
          begin
            if( wr_ptr == ( MAT_ELEMS - 1 ) && video_i.tvalid )
              if( buf_empty[1] || buf_empty_comb[1] )
                next_state_wr = WRITE_BUF_1_S;
              else
                next_state_wr = WAIT_BUF_1_EMPTY_S;
          end
        WAIT_BUF_1_EMPTY_S:
          begin
            if( buf_empty[1] || buf_empty_comb[1] )
              next_state_wr = WRITE_BUF_1_S;
          end
        WRITE_BUF_1_S:
          begin
            if( wr_ptr == ( MAT_ELEMS - 1 ) && video_i.tvalid )
              if( buf_empty[0] || buf_empty_comb[0] )
                next_state_wr = WRITE_BUF_0_S;
              else
                next_state_wr = WAIT_BUF_0_EMPTY_S;
          end
        WAIT_BUF_0_EMPTY_S:
          begin
            if( buf_empty[0] || buf_empty_comb[0] )
              next_state_wr = WRITE_BUF_0_S;
          end
      end
    endcase
  end

enum logic [1 : 0] { WAIT_BUF_0_FULL_S,
                     READ_BUF_0_S,
                     WAIT_BUF_1_FULL_S,
                     READ_BUF_1_S
                   } state_rd, next_state_rd;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    state_rd <= WAIT_BUF_0_FULL_S;
  else
    state_rd <= next_state_rd;

always_comb
  begin
    next_state_rd = state_rd;
    case( state_rd )
      begin
        WAIT_BUF_0_FULL_S:
          begin
            if( buf_full[0] || buf_full_comb[0] )
              next_state_rd = READ_BUF_0_S;
          end
        READ_BUF_0_S:
          begin
            if( rd_ptr == ( MAT_ELEMS - 1 ) )
              if( buf_full[1] || buf_full_comb[1] )
                next_state_rd = READ_BUF_1_S;
              else
                next_state_rd = WAIT_BUF_1_FULL_S;
          end
        WAIT_BUF_1_FULL_S:
          begin
            if( buf_full[1] || buf_full_comb[1] )
              next_state_rd = READ_BUF_1_S;
          end
        READ_BUF_1_S:
          begin
            if( rd_ptr == ( MAT_ELEMS - 1 ) )
              if( buf_full[0] || buf_full_comb[0])
                next_state_rd = READ_BUF_0_S;
              else
                next_state_rd = WAIT_BUF_0_FULL_S;
          end
      end
    endcase
  end

assign video_i.tready = state_wr == WRITE_BUF_0_S || state_wr == WRITE_BUF_1_S;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    wr_ptr <= ADDR_WIDTH'( 0 );
  else
    if( video_i.tvalid && video_i.tready )
      if( wr_ptr >= ( MAT_SIZE * ( MAT_SIZE - 1 ) )
        wr_ptr <= wr_ptr + ADDR_WIDTH'( MAT_SIZE + 1 );
      else
        wr_ptr <= wr_ptr + ADDR_WIDTH'( MAT_SIZE );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    rd_ptr <= ADDR_WIDTH'( 0 );
  else
    if( ( state_rd == READ_BUF_0_S || state_rd == READ_BUF_1_S ) && data_path_ready )
      rd_ptr <= rd_ptr + 1'b1;


always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    buf_empty <= 2'b11;
  else
    buf_empty <= buf_empty_comb;

always_comb
  begin
    buf_empty_comb = buf_empty;
    if( rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) )
      begin
        if( state_rd == READ_BUF_0_S )
          buf_empty_comb[0] = 1'b1;
        else
          if( state_rd == READ_BUF_1_S )
            buf_empty_comb[1] = 1'b1;
      end
    else
      begin
        if( wr[0] )
          buf_empty_comb[0] = 1'b1;
        if( wr[1] )
          buf_empty_comb[1] = 1'b1;
      end
  end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tlast_lock <= 2'd0;
  else
    begin
      if( state_wr == WRITE_BUF_0_S && video_i.tvalid && video_i.tlast )
        tlast_lock[0] <= 1'b1;
      else
        if( state_rd == READ_BUF_0_S && rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) )
          tlast_lock[0] <= 1'b0;
      if( state_wr == WRITE_BUF_1_S && video_i.tvalid && video_i.tlast )
        tlast_lock[1] <= 1'b1;
      else
        if( state_rd == READ_BUF_1_S && rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) )
          tlast_lock[1] <= 1'b0;
    end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tuser_lock <= 2'd0;
  else
    begin
      if( state_wr == WRITE_BUF_0_S && video_i.tvalid && video_i.tuser )
        tuser_lock[0] <= 1'b1;
      else
        if( state_rd == READ_BUF_0_S && rd_ptr == ADDR_WIDTH'( 0 ) )
          tuser_lock[0] <= 1'b0;
      if( state_wr == WRITE_BUF_1_S && video_i.tvalid && video_i.tuser )
        tuser_lock[1] <= 1'b1;
      else
        if( state_rd == READ_BUF_1_S && rd_ptr == ADDR_WIDTH'( 0 ) )
          tuser_lock[1] <= 1'b0;
    end

assign data_path_ready = !video_o.tvalid || video_o.tready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tvalid <= 1'b0;
  else
    if( |rd_ptr[RD_CNT_WIDTH - 1 : 0] )
      video_o.tvalid <= 1'b1;
    else
      if( data_path_ready )
        video_o.tvalid <= 1'b0;

genvar g;

generate
  for( g = 0; g < 2; g++ )
    begin : matrix_ram
      dual_port_ram #(
        .DATA_WIDTH ( PX_WIDTH                        ),
        .ADDR_WIDTH ( ADDR_WIDTH                      )
      ) ram_inst (
        .wr_clk_i   ( clk_i                           ),
        .wr_addr_i  ( wr_ptr                          ),
        .wr_data_i  ( video_i.tdata[PX_WIDTH - 1 : 0] ),
        .wr_i       ( wr[g]                           ),
        .rd_clk_i   ( clk_i                           ),
        .rd_addr_i  ( rd_ptr                          ),
        .rd_data_o  ( rd_px_data[g]                   ),
        .rd_i       ( rd[g]                           )
      );
    end
endgenerate

assign wr[0] = video_i.tvalid && state_wr = WRITE_BUF_0_S;
assign wr[1] = video_i.tvalid && state_wr = WRITE_BUF_1_S;

assign rd[0] = data_path_ready && state_rd == READ_BUF_0_S;
assign rd[1] = data_path_ready && state_rd == READ_BUF_1_S;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    output_data <= ( MAT_SIZE * PX_WIDTH )'( 0 );
  else
    if( data_path_ready )
      if( state == READ_BUF_0_S )
        output_data[rd_ptr[RD_CNT_WIDTH - 1 : 0]] <= rd_px_data[0];
      else
        if( state == WRITE_BUF_0_S )
          output_data[rd_ptr[RD_CNT_WIDTH - 1 : 0]] <= rd_px_data[1];
    
assign video_o.tdata = TDATA_WIDTH'( output_data );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tlast <= 1'b0;
  else
    if( ( state_rd == READ_BUF_0_S && tlast_lock[0] && rd_ptr == ADDR_WIDTH'( MAT_ELEMS ) ) ||
        ( state_rd == READ_BUF_1_S && tlast_lock[1] && rd_ptr == ADDR_WIDTH'( MAT_ELEMS ) ) )
      video_o.tlast <= 1'b1;
    else
      if( data_path_ready )
        video_o.tlast <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tuser <= 1'b0;
  else
    if( ( state_rd == READ_BUF_0_S && tuser_lock[0] && rd_ptr == ADDR_WIDTH'( 0 ) ) ||
        ( state_rd == READ_BUF_1_S && tuser_lock[1] && rd_ptr == ADDR_WIDTH'( 0 ) ) )
      video_o.tuser <= 1'b1;
    else
      if( data_path_ready )
        video_o.tuser <= 1'b0;

assign video_o.tkeep = '1;
assign video_o.tstrb = '1;

endmodule
