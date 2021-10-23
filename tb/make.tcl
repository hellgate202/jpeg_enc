vlib work
vlog -sv -f ./files 
vopt +acc tb_dct -o tb_dct_opt
vsim tb_dct_opt
do wave.do
run -all
