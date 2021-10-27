quietly set x_res 320
quietly set y_res 240
quietly set total_x 400
quietly set total_y 300

exec ../lib/axi4_lib/scripts/rgb_img2grayscale_hex.py ./test.jpg $x_res $y_res 8
exec ../scripts/check_dct.py $x_res $y_res

vlib work
vlog -sv -f ./files 
vsim tb_dct -G/tb_dct/FRAME_RES_X=$x_res \
            -G/tb_dct/FRAME_RES_Y=$y_res \
            -G/tb_dct/TOTAL_X=$total_x   \
            -G/tb_dct/TOTAL_Y=$total_y

do wave.do
run -all
