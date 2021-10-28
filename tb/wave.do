onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_dct/video_i/aclk
add wave -noupdate /tb_dct/video_i/aresetn
add wave -noupdate /tb_dct/video_i/tvalid
add wave -noupdate /tb_dct/video_i/tready
add wave -noupdate /tb_dct/video_i/tdata
add wave -noupdate /tb_dct/video_i/tstrb
add wave -noupdate /tb_dct/video_i/tkeep
add wave -noupdate /tb_dct/video_i/tlast
add wave -noupdate /tb_dct/video_i/tid
add wave -noupdate /tb_dct/video_i/tdest
add wave -noupdate /tb_dct/video_i/tuser
add wave -noupdate /tb_dct/dct_o/aclk
add wave -noupdate /tb_dct/dct_o/aresetn
add wave -noupdate /tb_dct/dct_o/tvalid
add wave -noupdate /tb_dct/dct_o/tready
add wave -noupdate /tb_dct/dct_o/tdata
add wave -noupdate /tb_dct/dct_o/tstrb
add wave -noupdate /tb_dct/dct_o/tkeep
add wave -noupdate /tb_dct/dct_o/tlast
add wave -noupdate /tb_dct/dct_o/tid
add wave -noupdate /tb_dct/dct_o/tdest
add wave -noupdate /tb_dct/dct_o/tuser
add wave -noupdate /tb_dct/DUT/dct_stage_1/clk_i
add wave -noupdate /tb_dct/DUT/dct_stage_1/rst_i
add wave -noupdate /tb_dct/DUT/dct_stage_1/px_unpack
add wave -noupdate /tb_dct/DUT/dct_stage_1/cur_dct
add wave -noupdate /tb_dct/DUT/dct_stage_1/dct_sel_run
add wave -noupdate /tb_dct/DUT/dct_stage_1/px_delta
add wave -noupdate /tb_dct/DUT/dct_stage_1/px_delta_sa
add wave -noupdate /tb_dct/DUT/dct_stage_1/mult_px
add wave -noupdate /tb_dct/DUT/dct_stage_1/mult_coef
add wave -noupdate /tb_dct/DUT/dct_stage_1/mult_result
add wave -noupdate /tb_dct/DUT/dct_stage_1/cut_tc
add wave -noupdate /tb_dct/DUT/dct_stage_1/add_stage
add wave -noupdate /tb_dct/DUT/dct_stage_1/dct
add wave -noupdate /tb_dct/DUT/dct_stage_1/mult_ready
add wave -noupdate /tb_dct/DUT/dct_stage_1/data_path_ready
add wave -noupdate /tb_dct/DUT/dct_stage_1/mult_valid_pipe
add wave -noupdate /tb_dct/DUT/dct_stage_1/mult_tlast_pipe
add wave -noupdate /tb_dct/DUT/dct_stage_1/mult_tuser_pipe
add wave -noupdate /tb_dct/DUT/dct_stage_1/was_tuser
add wave -noupdate /tb_dct/DUT/dct_stage_1/was_tlast
add wave -noupdate /tb_dct/DUT/dct_stage_1/q_ptr
add wave -noupdate /tb_dct/DUT/dct_stage_1/dct_sa
add wave -noupdate /tb_dct/DUT/dct_stage_1/dct_real
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {738592920 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 477
configure wave -valuecolwidth 454
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2122569750 ps}
