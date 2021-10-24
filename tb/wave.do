onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider video_i
add wave -noupdate /tb_dct_stage_1/video_i/aclk
add wave -noupdate /tb_dct_stage_1/video_i/aresetn
add wave -noupdate /tb_dct_stage_1/video_i/tvalid
add wave -noupdate /tb_dct_stage_1/video_i/tready
add wave -noupdate -radix decimal /tb_dct_stage_1/video_i/tdata
add wave -noupdate /tb_dct_stage_1/video_i/tstrb
add wave -noupdate /tb_dct_stage_1/video_i/tkeep
add wave -noupdate /tb_dct_stage_1/video_i/tlast
add wave -noupdate /tb_dct_stage_1/video_i/tid
add wave -noupdate /tb_dct_stage_1/video_i/tdest
add wave -noupdate /tb_dct_stage_1/video_i/tuser
add wave -noupdate -divider DUT
add wave -noupdate /tb_dct_stage_1/DUT/clk_i
add wave -noupdate /tb_dct_stage_1/DUT/rst_i
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_lock
add wave -noupdate /tb_dct_stage_1/DUT/cur_lock
add wave -noupdate -radix unsigned /tb_dct_stage_1/DUT/px_cnt
add wave -noupdate -radix unsigned /tb_dct_stage_1/DUT/px_cnt_d
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_0_p_px_7
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_1_p_px_6
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_2_p_px_5
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_3_p_px_4
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_0_m_px_7
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_1_m_px_6
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_2_m_px_5
add wave -noupdate -radix decimal /tb_dct_stage_1/DUT/px_3_m_px_4
add wave -noupdate /tb_dct_stage_1/DUT/px_0_p_px_7_sa
add wave -noupdate /tb_dct_stage_1/DUT/px_1_p_px_6_sa
add wave -noupdate /tb_dct_stage_1/DUT/px_2_p_px_5_sa
add wave -noupdate /tb_dct_stage_1/DUT/px_3_p_px_4_sa
add wave -noupdate /tb_dct_stage_1/DUT/px_0_m_px_7_sa
add wave -noupdate /tb_dct_stage_1/DUT/px_1_m_px_6_sa
add wave -noupdate /tb_dct_stage_1/DUT/px_2_m_px_5_sa
add wave -noupdate /tb_dct_stage_1/DUT/px_3_m_px_4_sa
add wave -noupdate /tb_dct_stage_1/DUT/mult_0_px
add wave -noupdate /tb_dct_stage_1/DUT/mult_0_coef
add wave -noupdate /tb_dct_stage_1/DUT/mult_0_result
add wave -noupdate /tb_dct_stage_1/DUT/cut_0_result
add wave -noupdate /tb_dct_stage_1/DUT/mult_1_px
add wave -noupdate /tb_dct_stage_1/DUT/mult_1_coef
add wave -noupdate /tb_dct_stage_1/DUT/mult_1_result
add wave -noupdate /tb_dct_stage_1/DUT/cut_1_result
add wave -noupdate /tb_dct_stage_1/DUT/mult_2_px
add wave -noupdate /tb_dct_stage_1/DUT/mult_2_coef
add wave -noupdate /tb_dct_stage_1/DUT/mult_2_result
add wave -noupdate /tb_dct_stage_1/DUT/cut_2_result
add wave -noupdate /tb_dct_stage_1/DUT/mult_3_px
add wave -noupdate /tb_dct_stage_1/DUT/mult_3_coef
add wave -noupdate /tb_dct_stage_1/DUT/mult_3_result
add wave -noupdate /tb_dct_stage_1/DUT/cut_3_result
add wave -noupdate /tb_dct_stage_1/DUT/cut_0_tc
add wave -noupdate /tb_dct_stage_1/DUT/cut_1_tc
add wave -noupdate /tb_dct_stage_1/DUT/cut_2_tc
add wave -noupdate /tb_dct_stage_1/DUT/cut_3_tc
add wave -noupdate /tb_dct_stage_1/DUT/add_stage
add wave -noupdate /tb_dct_stage_1/DUT/dct
add wave -noupdate /tb_dct_stage_1/DUT/dct_sa
add wave -noupdate /tb_dct_stage_1/DUT/dct_real
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {129541 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 554
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
WaveRestoreZoom {0 ps} {1076250 ps}
