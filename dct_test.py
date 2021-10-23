#!/bin/python3

import numpy as np
import math
from scipy.fftpack import dct


np.set_printoptions(precision=3)
np.set_printoptions(suppress=True)

img = np.array([ [52, 55, 61, 66, 70, 61, 64, 73],\
                   [63, 59, 55, 90, 109, 85, 69, 72],\
                   [62, 59, 68, 113, 144, 104, 66, 73],\
                   [63, 58, 71, 122, 154, 106, 70, 69],\
                   [67, 61, 68, 104, 126, 88, 68, 70],\
                   [79, 65, 60, 70, 77, 68, 58, 75],\
                   [85, 71, 64, 59, 55, 61, 65, 83],\
                   [87, 79, 69, 68, 65, 76, 78, 94]])

img = img - 128

#img = np.array([52, 55, 61, 66, 70, 61, 64, 73])
c = np.zeros( 8 )

for i in range( 1, 8 ):
  c[i] = ( 0.5 * math.cos( i * math.pi / 16.0 ) )

def dct_1d( img ):

  z = np.zeros( 8 )

  z[0] = c[4] * ( img[0] + img[7] ) + c[4] * ( img[1] + img[6] ) + c[4] * ( img[2] + img[5] ) + c[4] * ( img[3] + img[4] )
  z[2] = c[2] * ( img[0] + img[7] ) + c[6] * ( img[1] + img[6] ) - c[6] * ( img[2] + img[5] ) - c[2] * ( img[3] + img[4] )
  z[4] = c[4] * ( img[0] + img[7] ) - c[4] * ( img[1] + img[6] ) - c[4] * ( img[2] + img[5] ) + c[4] * ( img[3] + img[4] )
  z[6] = c[6] * ( img[0] + img[7] ) - c[2] * ( img[1] + img[6] ) + c[2] * ( img[2] + img[5] ) - c[6] * ( img[3] + img[4] )
  z[1] = c[1] * ( img[0] - img[7] ) + c[3] * ( img[1] - img[6] ) + c[5] * ( img[2] - img[5] ) + c[7] * ( img[3] - img[4] )
  z[3] = c[3] * ( img[0] - img[7] ) - c[7] * ( img[1] - img[6] ) - c[1] * ( img[2] - img[5] ) - c[6] * ( img[3] - img[4] )
  z[5] = c[5] * ( img[0] - img[7] ) - c[1] * ( img[1] - img[6] ) + c[7] * ( img[2] - img[5] ) + c[3] * ( img[3] - img[4] )
  z[7] = c[7] * ( img[0] - img[7] ) - c[5] * ( img[1] - img[6] ) + c[3] * ( img[2] - img[5] ) - c[1] * ( img[3] - img[4] )

  return z

dct_1d_img = np.zeros( ( 8, 8 ) )
for i in range( 8 ):
  dct_1d_img[i] = dct_1d( img[i] )

dct_1d_img_t = np.transpose( dct_1d_img )

dct_2d_img = np.zeros( ( 8, 8 ) )
for i in range( 8 ):
  dct_2d_img[:,i] = dct_1d( dct_1d_img[:,i] )

#print( dct_1d_img )
#print( np.transpose( dct_2d_img ) )
print( c )

