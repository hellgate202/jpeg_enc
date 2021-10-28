package dct_pkg;

parameter int COEF_FRACT_WIDTH = 10;

parameter bit [7 : 0][7 : 0][7 : 0] Q_MAT = '{ '{ 16, 11, 10, 16, 24, 40, 51, 61 },
                                               '{ 12, 12, 14, 19, 26, 58, 60, 55 },
                                               '{ 14, 13, 16, 24, 40, 57, 69, 56 },
                                               '{ 14, 17, 22, 29, 51, 87, 80, 62 },
                                               '{ 18, 22, 37, 56, 68, 109, 103, 77 },
                                               '{ 24, 35, 55, 64, 81, 104, 113, 92 },
                                               '{ 49, 64, 78, 87, 103, 121, 120, 101 },
                                               '{ 72, 92, 95, 98, 112, 100, 103, 99 } };

// Do not edit below!

parameter int COEF_WIDTH = COEF_FRACT_WIDTH + 1; //for sign

function bit [7 : 0][7 : 0][7 : 0] reverse_quant_mat ( input bit [7 : 0][7 : 0][7 : 0] q_mat );

  for( int i = 0; i < 8; i++ )
    for( int j = 0; j < 8; j++ )
      reverse_quant_mat[i][j] = q_mat[7 - i][7 - j];

endfunction

parameter bit [7 : 0][7 : 0][7 : 0] Q_MAT_HW = reverse_quant_mat( Q_MAT );

function bit [7 : 0][3 : 0][COEF_WIDTH - 1 : 0] gen_coefs();

  gen_coefs[0][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[0][1] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[0][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[0][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[1][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  ) ) };
  gen_coefs[1][1] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 ) ) };
  gen_coefs[1][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 ) ) };
  gen_coefs[1][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 ) ) };
  gen_coefs[2][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 ) ) };
  gen_coefs[2][1] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 ) ) };
  gen_coefs[2][2] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 ) ) };
  gen_coefs[2][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 ) ) };
  gen_coefs[3][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 ) ) };
  gen_coefs[3][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 ) ) };
  gen_coefs[3][2] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  ) ) };
  gen_coefs[3][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 ) ) };
  gen_coefs[4][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[4][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[4][2] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[4][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 ) ) };
  gen_coefs[5][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 ) ) };
  gen_coefs[5][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  ) ) };
  gen_coefs[5][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 ) ) };
  gen_coefs[5][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 ) ) };
  gen_coefs[6][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 ) ) };
  gen_coefs[6][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 ) ) };
  gen_coefs[6][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 ) ) };
  gen_coefs[6][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 ) ) };
  gen_coefs[7][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 ) ) };
  gen_coefs[7][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 ) ) };
  gen_coefs[7][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 ) ) };
  gen_coefs[7][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  ) ) };

endfunction

parameter bit [7 : 0][3 : 0][COEF_WIDTH - 1 : 0] COEFS = gen_coefs();

function bit [7 : 0][7 : 0][3 : 0][COEF_WIDTH - 1 : 0] gen_q_coefs();

  for( int i = 0; i < 8; i++ )
    begin
      gen_q_coefs[i][0][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[0][i] ) ) };
      gen_q_coefs[i][0][1] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[0][i] ) ) };
      gen_q_coefs[i][0][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[0][i] ) ) };
      gen_q_coefs[i][0][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[0][i] ) ) };
      gen_q_coefs[i][1][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  / Q_MAT_HW[1][i] ) ) };
      gen_q_coefs[i][1][1] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 / Q_MAT_HW[1][i] ) ) };
      gen_q_coefs[i][1][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 / Q_MAT_HW[1][i] ) ) };
      gen_q_coefs[i][1][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 / Q_MAT_HW[1][i] ) ) };
      gen_q_coefs[i][2][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 / Q_MAT_HW[2][i] ) ) };
      gen_q_coefs[i][2][1] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 / Q_MAT_HW[2][i] ) ) };
      gen_q_coefs[i][2][2] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 / Q_MAT_HW[2][i] ) ) };
      gen_q_coefs[i][2][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 / Q_MAT_HW[2][i] ) ) };
      gen_q_coefs[i][3][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 / Q_MAT_HW[3][i] ) ) };
      gen_q_coefs[i][3][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 / Q_MAT_HW[3][i] ) ) };
      gen_q_coefs[i][3][2] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  / Q_MAT_HW[3][i] ) ) };
      gen_q_coefs[i][3][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 / Q_MAT_HW[3][i] ) ) };
      gen_q_coefs[i][4][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[4][i] ) ) };
      gen_q_coefs[i][4][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[4][i] ) ) };
      gen_q_coefs[i][4][2] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[4][i] ) ) };
      gen_q_coefs[i][4][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.354 / Q_MAT_HW[4][i] ) ) };
      gen_q_coefs[i][5][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 / Q_MAT_HW[5][i] ) ) };
      gen_q_coefs[i][5][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  / Q_MAT_HW[5][i] ) ) };
      gen_q_coefs[i][5][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 / Q_MAT_HW[5][i] ) ) };
      gen_q_coefs[i][5][3] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 / Q_MAT_HW[5][i] ) ) };
      gen_q_coefs[i][6][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 / Q_MAT_HW[6][i] ) ) };
      gen_q_coefs[i][6][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 / Q_MAT_HW[6][i] ) ) };
      gen_q_coefs[i][6][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.462 / Q_MAT_HW[6][i] ) ) };
      gen_q_coefs[i][6][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.191 / Q_MAT_HW[6][i] ) ) };
      gen_q_coefs[i][7][0] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.098 / Q_MAT_HW[7][i] ) ) };
      gen_q_coefs[i][7][1] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.278 / Q_MAT_HW[7][i] ) ) };
      gen_q_coefs[i][7][2] = { 1'b0, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.416 / Q_MAT_HW[7][i] ) ) };
      gen_q_coefs[i][7][3] = { 1'b1, COEF_FRACT_WIDTH'( int'( 2 ** COEF_FRACT_WIDTH * 0.49  / Q_MAT_HW[7][i] ) ) };
    end

endfunction

parameter bit [7 : 0][7 : 0][3 : 0][COEF_WIDTH - 1 : 0] Q_COEFS = gen_q_coefs();

endpackage
