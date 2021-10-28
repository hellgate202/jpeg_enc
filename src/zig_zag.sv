module zig_zag #(
  parameter int DCT_WIDTH = 12
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  dct_i,
  axi4_stream_if.master zz_o
);

logic [7 : 0][DCT_WIDTH - 1 : 0]         input_buf;
logic [1 : 0][63 : 0][DCT_WIDTH - 1 : 0] zz_buf;
logic                                    cur_zz_buf;
logic [2 : 0]                            input_buf_cnt;
logic [2 : 0]                            px_cnt;
logic [5 : 0]                            output_cnt;
logic [1 : 0]                            buff_empty;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      input_buf <= ( 8 * DCT_WIDTH )'( 0 );
      px_cnt    <= 3'd0;
    end
  else
    if( dct_i.tvalid && dct_i.tready )
      begin
        input_buf <= { dct_i.tdata[DCT_WIDTH - 1 : 0], input_buf[7 : 1] };
        px_cnt    <= px_cnt + 1'b1;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    input_buf_cnt <= 3'd0;
  else
    if( dct_i.tvalid && dct_i.tready && px_cnt == 3'd7 )
      input_buf_cnt <= input_buf_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    zz_buf <= 128'd0;
  else
    if( dct_i.tvalid && dct_i.tready && px_cnt == 3'd7 )
      case( input_buf_cnt )
        3'd0:
          begin
            zz_buf[cur_zz_buf][0]  <= input_buf[0];
            zz_buf[cur_zz_buf][2]  <= input_buf[1];
            zz_buf[cur_zz_buf][3]  <= input_buf[2];
            zz_buf[cur_zz_buf][9]  <= input_buf[3];
            zz_buf[cur_zz_buf][10] <= input_buf[4];
            zz_buf[cur_zz_buf][20] <= input_buf[5];
            zz_buf[cur_zz_buf][21] <= input_buf[6];
            zz_buf[cur_zz_buf][35] <= input_buf[7];
          end
        3'd1:
          begin
            zz_buf[cur_zz_buf][1]  <= input_buf[0];
            zz_buf[cur_zz_buf][4]  <= input_buf[1];
            zz_buf[cur_zz_buf][8]  <= input_buf[2];
            zz_buf[cur_zz_buf][11] <= input_buf[3];
            zz_buf[cur_zz_buf][19] <= input_buf[4];
            zz_buf[cur_zz_buf][22] <= input_buf[5];
            zz_buf[cur_zz_buf][34] <= input_buf[6];
            zz_buf[cur_zz_buf][36] <= input_buf[7];
          end
        3'd2:
          begin
            zz_buf[cur_zz_buf][5]  <= input_buf[0];
            zz_buf[cur_zz_buf][7]  <= input_buf[1];
            zz_buf[cur_zz_buf][12] <= input_buf[2];
            zz_buf[cur_zz_buf][18] <= input_buf[3];
            zz_buf[cur_zz_buf][23] <= input_buf[4];
            zz_buf[cur_zz_buf][33] <= input_buf[5];
            zz_buf[cur_zz_buf][37] <= input_buf[6];
            zz_buf[cur_zz_buf][48] <= input_buf[7];
          end
        3'd3:
          begin
            zz_buf[cur_zz_buf][6]  <= input_buf[0];
            zz_buf[cur_zz_buf][13] <= input_buf[1];
            zz_buf[cur_zz_buf][17] <= input_buf[2];
            zz_buf[cur_zz_buf][24] <= input_buf[3];
            zz_buf[cur_zz_buf][32] <= input_buf[4];
            zz_buf[cur_zz_buf][38] <= input_buf[5];
            zz_buf[cur_zz_buf][47] <= input_buf[6];
            zz_buf[cur_zz_buf][49] <= input_buf[7];
          end
        3'd4:
          begin
            zz_buf[cur_zz_buf][14] <= input_buf[0];
            zz_buf[cur_zz_buf][16] <= input_buf[1];
            zz_buf[cur_zz_buf][25] <= input_buf[2];
            zz_buf[cur_zz_buf][31] <= input_buf[3];
            zz_buf[cur_zz_buf][39] <= input_buf[4];
            zz_buf[cur_zz_buf][46] <= input_buf[5];
            zz_buf[cur_zz_buf][50] <= input_buf[6];
            zz_buf[cur_zz_buf][57] <= input_buf[7];
          end
        3'd5:
          begin
            zz_buf[cur_zz_buf][15] <= input_buf[0];
            zz_buf[cur_zz_buf][26] <= input_buf[1];
            zz_buf[cur_zz_buf][30] <= input_buf[2];
            zz_buf[cur_zz_buf][40] <= input_buf[3];
            zz_buf[cur_zz_buf][45] <= input_buf[4];
            zz_buf[cur_zz_buf][51] <= input_buf[5];
            zz_buf[cur_zz_buf][56] <= input_buf[6];
            zz_buf[cur_zz_buf][58] <= input_buf[7];
          end
        3'd6:
          begin
            zz_buf[cur_zz_buf][27] <= input_buf[0];
            zz_buf[cur_zz_buf][29] <= input_buf[1];
            zz_buf[cur_zz_buf][41] <= input_buf[2];
            zz_buf[cur_zz_buf][44] <= input_buf[3];
            zz_buf[cur_zz_buf][52] <= input_buf[4];
            zz_buf[cur_zz_buf][55] <= input_buf[5];
            zz_buf[cur_zz_buf][59] <= input_buf[6];
            zz_buf[cur_zz_buf][62] <= input_buf[7];
          end
        3'd7:
          begin
            zz_buf[cur_zz_buf][28] <= input_buf[0];
            zz_buf[cur_zz_buf][42] <= input_buf[1];
            zz_buf[cur_zz_buf][43] <= input_buf[2];
            zz_buf[cur_zz_buf][53] <= input_buf[3];
            zz_buf[cur_zz_buf][54] <= input_buf[4];
            zz_buf[cur_zz_buf][60] <= input_buf[5];
            zz_buf[cur_zz_buf][61] <= input_buf[6];
            zz_buf[cur_zz_buf][63] <= input_buf[7];
          end
      endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    buff_empty <= 2'b11;
  else
    begin
      if( dct_i.tvalid && dct_i.tready && px_cnt == 3'd7 )
        buff_empty[cur_zz_buf]  <= 1'b0;
      if( output_cnt == 6'd63 && zz_o.tready )
        buff_empty[!cur_zz_buf] <= 1'b1;
    end

endmodule
