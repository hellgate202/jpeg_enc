vlib work
vlog -sv -f ./files 
vopt +acc tb_dct_stage_1 -o tb_dct_stage_1_opt
vsim tb_dct_stage_1_opt
do wave.do
run -all
