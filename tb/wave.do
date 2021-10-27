onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider VIDEO_I
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
add wave -noupdate -divider MULTILINE_BUF
add wave -noupdate /tb_dct/DUT/multiline_buf_inst/clk_i
add wave -noupdate /tb_dct/DUT/multiline_buf_inst/rst_i
add wave -noupdate /tb_dct/DUT/multiline_buf_inst/buf_pnt
add wave -noupdate /tb_dct/DUT/multiline_buf_inst/pre_buf_tready
add wave -noupdate /tb_dct/DUT/multiline_buf_inst/pre_buf_tvalid
add wave -noupdate -divider LINE_SELECOTR
add wave -noupdate /tb_dct/DUT/line_selector/clk_i
add wave -noupdate /tb_dct/DUT/line_selector/rst_i
add wave -noupdate /tb_dct/DUT/line_selector/px_cnt
add wave -noupdate /tb_dct/DUT/line_selector/ln_cnt
add wave -noupdate /tb_dct/DUT/line_selector/packed_par_tdata
add wave -noupdate /tb_dct/DUT/line_selector/ser_video_tdata
add wave -noupdate /tb_dct/DUT/line_selector/ser_video_tvalid
add wave -noupdate /tb_dct/DUT/line_selector/ser_video_tready
add wave -noupdate /tb_dct/DUT/line_selector/ser_video_tlast
add wave -noupdate /tb_dct/DUT/line_selector/ser_video_tuser
add wave -noupdate -divider PARALLEL_SHIFTED_VIDEO
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/aclk
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/aresetn
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tvalid
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tready
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tdata
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tstrb
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tkeep
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tlast
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tid
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tdest
add wave -noupdate /tb_dct/DUT/parallel_shifted_video/tuser
add wave -noupdate -divider DCT_STAGE_1
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
add wave -noupdate -divider DCT_1D_STREAM
add wave -noupdate /tb_dct/DUT/dct_1d_stream/aclk
add wave -noupdate /tb_dct/DUT/dct_1d_stream/aresetn
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tvalid
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tready
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tdata
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tstrb
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tkeep
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tlast
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tid
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tdest
add wave -noupdate /tb_dct/DUT/dct_1d_stream/tuser
add wave -noupdate -divider TRANSPOSE_INST
add wave -noupdate /tb_dct/DUT/transpose_inst/clk_i
add wave -noupdate /tb_dct/DUT/transpose_inst/rst_i
add wave -noupdate /tb_dct/DUT/transpose_inst/wr_ptr
add wave -noupdate /tb_dct/DUT/transpose_inst/wr
add wave -noupdate /tb_dct/DUT/transpose_inst/rd_ptr
add wave -noupdate /tb_dct/DUT/transpose_inst/rd_ptr_d1
add wave -noupdate /tb_dct/DUT/transpose_inst/rd
add wave -noupdate /tb_dct/DUT/transpose_inst/rd_px_data
add wave -noupdate /tb_dct/DUT/transpose_inst/buf_empty
add wave -noupdate /tb_dct/DUT/transpose_inst/buf_empty_comb
add wave -noupdate /tb_dct/DUT/transpose_inst/buf_full
add wave -noupdate /tb_dct/DUT/transpose_inst/buf_full_comb
add wave -noupdate /tb_dct/DUT/transpose_inst/data_path_ready
add wave -noupdate /tb_dct/DUT/transpose_inst/output_data
add wave -noupdate /tb_dct/DUT/transpose_inst/tuser_lock
add wave -noupdate /tb_dct/DUT/transpose_inst/tlast_lock
add wave -noupdate /tb_dct/DUT/transpose_inst/state_wr
add wave -noupdate /tb_dct/DUT/transpose_inst/next_state_wr
add wave -noupdate /tb_dct/DUT/transpose_inst/state_rd
add wave -noupdate /tb_dct/DUT/transpose_inst/state_rd_d1
add wave -noupdate /tb_dct/DUT/transpose_inst/next_state_rd
add wave -noupdate -divider DCT_1D_T_STREAM
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/aclk
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/aresetn
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tvalid
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tready
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tdata
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tstrb
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tkeep
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tlast
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tid
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tdest
add wave -noupdate /tb_dct/DUT/dct_1d_t_stream/tuser
add wave -noupdate -divider DCT_STAGE_2
add wave -noupdate /tb_dct/DUT/dct_stage_2/clk_i
add wave -noupdate /tb_dct/DUT/dct_stage_2/rst_i
add wave -noupdate /tb_dct/DUT/dct_stage_2/px_unpack
add wave -noupdate /tb_dct/DUT/dct_stage_2/cur_dct
add wave -noupdate /tb_dct/DUT/dct_stage_2/dct_sel_run
add wave -noupdate /tb_dct/DUT/dct_stage_2/px_delta
add wave -noupdate /tb_dct/DUT/dct_stage_2/px_delta_sa
add wave -noupdate /tb_dct/DUT/dct_stage_2/mult_px
add wave -noupdate /tb_dct/DUT/dct_stage_2/mult_coef
add wave -noupdate /tb_dct/DUT/dct_stage_2/mult_result
add wave -noupdate /tb_dct/DUT/dct_stage_2/cut_tc
add wave -noupdate /tb_dct/DUT/dct_stage_2/add_stage
add wave -noupdate /tb_dct/DUT/dct_stage_2/dct
add wave -noupdate /tb_dct/DUT/dct_stage_2/mult_ready
add wave -noupdate /tb_dct/DUT/dct_stage_2/data_path_ready
add wave -noupdate /tb_dct/DUT/dct_stage_2/mult_valid_pipe
add wave -noupdate /tb_dct/DUT/dct_stage_2/mult_tlast_pipe
add wave -noupdate /tb_dct/DUT/dct_stage_2/mult_tuser_pipe
add wave -noupdate /tb_dct/DUT/dct_stage_2/was_tuser
add wave -noupdate /tb_dct/DUT/dct_stage_2/was_tlast
add wave -noupdate /tb_dct/DUT/dct_stage_2/q_ptr
add wave -noupdate /tb_dct/DUT/dct_stage_2/dct_sa
add wave -noupdate /tb_dct/DUT/dct_stage_2/dct_real
add wave -noupdate -divider DCT_O
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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {28502733 ps} 0}
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
WaveRestoreZoom {0 ps} {1290045750 ps}
