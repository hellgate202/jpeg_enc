#!/bin/python3

import numpy as np
import sys
from scipy.fftpack import dct

np.set_printoptions(precision=3)
np.set_printoptions(suppress=True)
np.set_printoptions(threshold=sys.maxsize)

width  = int( sys.argv[1] )
height = int( sys.argv[2] )

px_amount      = width * height
pack_8_amounts = int( px_amount / 8 )

f = open( '../tb/img.hex', 'r'  )

pixels = f.read().splitlines()

for i in range( len( pixels ) ):
  pixels[i] = int( "0x" + pixels[i], 16 ) - 128

pixels_np = np.array( pixels )
pixels_np = np.reshape( pixels_np, ( pack_8_amounts, 8  ) )

dct_array = np.zeros( ( pack_8_amounts, 8 ) )

for i in range( len( pixels_np ) ):
  dct_array[i] = dct( pixels_np[i], type=2, norm="ortho" )

# By this time we have 1D-DCT over all image
# Let's convert it to parallel output like in FPGA

dct_array = np.reshape( dct_array, px_amount )

packed_dct_array = np.zeros( ( pack_8_amounts, 8 ) )

for i in range( int( len( dct_array ) / 8 ) ):
  for j in range( 8 ):
    packed_dct_array[i][j] = dct_array[( ( int( i / 8 ) * 8 ) % width) + ( j + int( i / width ) * 8 ) * width + int( i % 8 )]

packed_dct_array = np.reshape( packed_dct_array, px_amount );

np.savetxt( '../tb/ref.hex', packed_dct_array, delimiter='\n', fmt='%1.3f')
