import dct_pkg::*;

module tb_dct;

dct DUT
(
  .clk_i (),
  .rst_i ()
);

initial
  begin
    for( int i = 0; i < 8; i++ )
      for( int j = 0; j < 8; j++ )
        $display( "Q_MAT_HW[%0d][%0d] = %0d", i, j, Q_MAT_HW[i][j] );
    $stop();
  end

endmodule
