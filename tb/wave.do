onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider video_i
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
add wave -noupdate -divider {1D DCT}
add wave -noupdate /tb_dct/dct_stage_1_inst/clk_i
add wave -noupdate /tb_dct/dct_stage_1_inst/rst_i
add wave -noupdate /tb_dct/dct_stage_1_inst/px_lock
add wave -noupdate /tb_dct/dct_stage_1_inst/px_cnt
add wave -noupdate /tb_dct/dct_stage_1_inst/cur_dct
add wave -noupdate /tb_dct/dct_stage_1_inst/dct_sel_run
add wave -noupdate /tb_dct/dct_stage_1_inst/px_delta
add wave -noupdate /tb_dct/dct_stage_1_inst/px_delta_sa
add wave -noupdate /tb_dct/dct_stage_1_inst/mult_px
add wave -noupdate /tb_dct/dct_stage_1_inst/mult_coef
add wave -noupdate /tb_dct/dct_stage_1_inst/mult_result
add wave -noupdate /tb_dct/dct_stage_1_inst/cut_tc
add wave -noupdate /tb_dct/dct_stage_1_inst/add_stage
add wave -noupdate /tb_dct/dct_stage_1_inst/dct
add wave -noupdate /tb_dct/dct_stage_1_inst/free_lock
add wave -noupdate /tb_dct/dct_stage_1_inst/lock_full
add wave -noupdate /tb_dct/dct_stage_1_inst/mult_ready
add wave -noupdate /tb_dct/dct_stage_1_inst/data_path_ready
add wave -noupdate /tb_dct/dct_stage_1_inst/mult_valid_pipe
add wave -noupdate /tb_dct/dct_stage_1_inst/mult_tlast_pipe
add wave -noupdate /tb_dct/dct_stage_1_inst/mult_tuser_pipe
add wave -noupdate /tb_dct/dct_stage_1_inst/tuser_lock
add wave -noupdate /tb_dct/dct_stage_1_inst/tlast_lock
add wave -noupdate /tb_dct/dct_stage_1_inst/was_tuser
add wave -noupdate /tb_dct/dct_stage_1_inst/was_tlast
add wave -noupdate /tb_dct/dct_stage_1_inst/dct_sa
add wave -noupdate /tb_dct/dct_stage_1_inst/dct_real
add wave -noupdate -divider dct_o
add wave -noupdate /tb_dct/dct_o/aclk
add wave -noupdate /tb_dct/dct_o/aresetn
add wave -noupdate /tb_dct/dct_o/tvalid
add wave -noupdate /tb_dct/dct_o/tready
add wave -noupdate /tb_dct/dct_o/tdata
add wave -noupdate /tb_dct/dct_o/tstrb
add wave -noupdate /tb_dct/dct_o/tkeep
add wave -noupdate /tb_dct/dct_o/tlast
add wave -noupdate /tb_dct/dct_o/tuser
add wave -noupdate -divider transpose
add wave -noupdate /tb_dct/transpose_unit/clk_i
add wave -noupdate /tb_dct/transpose_unit/rst_i
add wave -noupdate /tb_dct/transpose_unit/buf_pnt
add wave -noupdate /tb_dct/transpose_unit/pre_buf_tready
add wave -noupdate /tb_dct/transpose_unit/pre_buf_tvalid
add wave -noupdate /tb_dct/transpose_unit/buf_empty
add wave -noupdate /tb_dct/transpose_unit/change_half
add wave -noupdate /tb_dct/transpose_unit/cur_half
add wave -noupdate /tb_dct/transpose_unit/read_in_progress
add wave -noupdate /tb_dct/transpose_unit/output_data
add wave -noupdate /tb_dct/transpose_unit/post_buf_tdata
add wave -noupdate /tb_dct/transpose_unit/post_buf_tvalid
add wave -noupdate /tb_dct/transpose_unit/post_buf_tready
add wave -noupdate /tb_dct/transpose_unit/post_buf_tstrb
add wave -noupdate /tb_dct/transpose_unit/post_buf_tkeep
add wave -noupdate /tb_dct/transpose_unit/post_buf_tlast
add wave -noupdate /tb_dct/transpose_unit/post_buf_tuser
add wave -noupdate -divider parallel_o
add wave -noupdate /tb_dct/parallel_o/aclk
add wave -noupdate /tb_dct/parallel_o/aresetn
add wave -noupdate /tb_dct/parallel_o/tvalid
add wave -noupdate /tb_dct/parallel_o/tready
add wave -noupdate /tb_dct/parallel_o/tdata
add wave -noupdate -expand /tb_dct/dct_from_parallel
add wave -noupdate /tb_dct/parallel_o/tstrb
add wave -noupdate /tb_dct/parallel_o/tkeep
add wave -noupdate /tb_dct/parallel_o/tlast
add wave -noupdate /tb_dct/parallel_o/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {28285000 ps} 0}
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
WaveRestoreZoom {0 ps} {1289825250 ps}
