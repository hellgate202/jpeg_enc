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

localparam int MAT_ELEMS  = MAT_SIZE * MAT_SIZE;
localparam int ADDR_WIDTH = $clog2( MAT_ELEMS );

logic [ADDR_WIDTH - 1 : 0]      wr_ptr;
logic [1 : 0]                   wr;
logic [ADDR_WIDTH - 1 : 0]      rd_ptr;
logic [1 : 0]                   rd;
logic [1 : 0][PX_WIDTH - 1 : 0] rd_px_data;
logic                           cur_wr_ram;
logic                           cur_rd_ram;
logic [1 : 0]                   ram_empty;
logic [1 : 0]                   ram_full;
logic                           data_path_ready;
logic                           backpressure;
logic [1 : 0]                   write_in_progress;
logic [1 : 0]                   read_in_progress;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    wr_ptr <= ADDR_WIDTH'( 0 );
  else
    if(  video_i.tvalid && video_i.tready )
      if( wr_ptr >= ( MAT_SIZE * ( MAT_SIZE - 1 ) )
        wr_ptr <= wr_ptr + ADDR_WIDTH'( MAT_SIZE + 1 );
      else
        wr_ptr <= wr_ptr + ADDR_WIDTH'( MAT_SIZE );

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
        .wr_i       ( wr[0]                           ),
        .rd_clk_i   ( clk_i                           ),
        .rd_addr_i  ( rd_ptr                          ),
        .rd_data_o  ( rd_px_data[0]                   ),
        .rd_i       ( rd[0]                           )
      );
    end
endgenerate

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ram_empty <= 2'b11;
  else
    begin
      if( rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && rd[0] )
        ram_empty[0] <= 1'b1;
      else
        if( wr[0] )
          ram_empty[0] <= 1'b0;
      if( rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && rd[1] )
        ram_empty[1] <= 1'b1;
      else
        if( wr[1] )
        ram_empty[1] <= 1'b0;
    end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ram_full <= 2'b00;
  else
    begin
      if( wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && wr[0] )
        ram_full[0] <= 1'b1;
      else
        if( rd[0] )
          ram_full[0] <= 1'b0;
      if( wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && wr[1] )
        ram_full[1] <= 1'b1;
      else
        if( rd[1] )
          ram_full[1] <= 1'b0;
    end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_wr_ram <= 1'b0;
  else
    if( !cur_wr_ram && wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && 
        wr[0] )
      cur_wr_ram <= 1'b1;
    else
      if( cur_wr_ram && wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) &&
          wr[1] )
        cur_wr_ram <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cur_rd_ram <= 1'b0;
  else
    if( !cur_rd_ram && rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) &&
        rd[0] )
      cur_rd_ram <= 1'b1;
    else
      if( cur_rd_ram && rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) &&
          rd[1] )
        cur_rd_ram <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    write_in_progress <= 2'b01;
  else
    begin
      if( wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && wr[0] && !cur_wr_ram )
        write_in_progress[0] <= 1'b0;
      if( wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && wr[1] && cur_wr_ram )
        write_in_progress[1] <= 1'b0;
      if( wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && ( wr[1] || ram_full[1] && ram_empty[0] )
        write_in_progress[0] <= 1'b1; 
      if( wr_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && ( wr[0] || ram_full[0] && ram_empty[1] )
        write_in_progress[1] <= 1'b1; 
    end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    read_in_progress <= 2'b00
  else
    begin
      if( rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && rd[0] && !cur_rd_ram )
        read_in_progress[0] <= 1'b0;
      if( rd_ptr == ADDR_WIDTH'( MAT_ELEMS - 1 ) && rd[1] && cur_rd_ram )
        read_in_progress[1] <= 1'b0;
      if( ram_full[0] && !read_in_progress[1] )
        read_in_progress[0] <= 1'b1;
      if( ram_full[1] && !read_in_progress[0] )
        read_in_progress[1] <= 1'b1;
    end

assign video_i.tready = 

endmodule
