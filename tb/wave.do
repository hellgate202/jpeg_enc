onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider video_i
add wave -noupdate -radix hexadecimal /tb_dct/video_i/aclk
add wave -noupdate -radix hexadecimal /tb_dct/video_i/aresetn
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tvalid
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tready
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tdata
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tstrb
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tkeep
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tlast
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tid
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tdest
add wave -noupdate -radix hexadecimal /tb_dct/video_i/tuser
add wave -noupdate -divider multiline_buf
add wave -noupdate -radix hexadecimal /tb_dct/pre_buf_inst/clk_i
add wave -noupdate -radix hexadecimal /tb_dct/pre_buf_inst/rst_i
add wave -noupdate -radix hexadecimal /tb_dct/pre_buf_inst/buf_pnt
add wave -noupdate -radix hexadecimal /tb_dct/pre_buf_inst/pre_buf_tready
add wave -noupdate -radix hexadecimal /tb_dct/pre_buf_inst/pre_buf_tvalid
add wave -noupdate -divider adapter
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/clk_i
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/rst_i
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/px_cnt
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/ln_cnt
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/packed_par_tdata
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/ser_video_tdata
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/ser_video_tvalid
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/ser_video_tready
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/ser_video_tlast
add wave -noupdate -radix hexadecimal /tb_dct/adapter_inst/ser_video_tuser
add wave -noupdate -divider prepeared_video
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/aclk
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/aresetn
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tvalid
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tready
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tdata
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tstrb
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tkeep
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tlast
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tid
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tdest
add wave -noupdate -radix hexadecimal /tb_dct/prepared_video/tuser
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/clk_i
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/rst_i
add wave -noupdate -radix hexadecimal -childformat {{{/tb_dct/dct_inst/px_unpack[7]} -radix hexadecimal} {{/tb_dct/dct_inst/px_unpack[6]} -radix hexadecimal} {{/tb_dct/dct_inst/px_unpack[5]} -radix hexadecimal} {{/tb_dct/dct_inst/px_unpack[4]} -radix hexadecimal} {{/tb_dct/dct_inst/px_unpack[3]} -radix hexadecimal} {{/tb_dct/dct_inst/px_unpack[2]} -radix hexadecimal} {{/tb_dct/dct_inst/px_unpack[1]} -radix hexadecimal} {{/tb_dct/dct_inst/px_unpack[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb_dct/dct_inst/px_unpack[7]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_unpack[6]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_unpack[5]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_unpack[4]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_unpack[3]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_unpack[2]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_unpack[1]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_unpack[0]} {-height 16 -radix hexadecimal}} /tb_dct/dct_inst/px_unpack
add wave -noupdate -radix hexadecimal -childformat {{{/tb_dct/dct_inst/px_delta[7]} -radix hexadecimal} {{/tb_dct/dct_inst/px_delta[6]} -radix hexadecimal} {{/tb_dct/dct_inst/px_delta[5]} -radix hexadecimal} {{/tb_dct/dct_inst/px_delta[4]} -radix hexadecimal} {{/tb_dct/dct_inst/px_delta[3]} -radix hexadecimal} {{/tb_dct/dct_inst/px_delta[2]} -radix hexadecimal} {{/tb_dct/dct_inst/px_delta[1]} -radix hexadecimal} {{/tb_dct/dct_inst/px_delta[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb_dct/dct_inst/px_delta[7]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_delta[6]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_delta[5]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_delta[4]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_delta[3]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_delta[2]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_delta[1]} {-height 16 -radix hexadecimal} {/tb_dct/dct_inst/px_delta[0]} {-height 16 -radix hexadecimal}} /tb_dct/dct_inst/px_delta
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/cur_dct
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/dct_sel_run
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/px_delta_sa
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/mult_px
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/mult_coef
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/mult_result
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/cut_tc
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/add_stage
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/dct
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/mult_ready
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/data_path_ready
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/mult_valid_pipe
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/mult_tlast_pipe
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/mult_tuser_pipe
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/was_tuser
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/was_tlast
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/dct_sa
add wave -noupdate -radix hexadecimal /tb_dct/dct_inst/dct_real
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/aclk
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/aresetn
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tvalid
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tready
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tdata
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tstrb
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tkeep
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tlast
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tid
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tdest
add wave -noupdate -radix hexadecimal /tb_dct/dct_stream/tuser
add wave -noupdate -divider px_to_cols
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/clk_i
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/rst_i
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/wr_ptr
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/wr
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/rd_ptr
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/rd_ptr_d1
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/rd
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/rd_px_data
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/buf_empty
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/buf_empty_comb
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/buf_full
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/buf_full_comb
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/data_path_ready
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/output_data
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/tuser_lock
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/tlast_lock
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/state_wr
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/next_state_wr
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/state_rd
add wave -noupdate -radix hexadecimal /tb_dct/px_to_cols_inst/next_state_rd
add wave -noupdate -divider dct_parallel_stream
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/aclk
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/aresetn
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tvalid
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tready
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tdata
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tstrb
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tkeep
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tlast
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tid
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tdest
add wave -noupdate -radix hexadecimal /tb_dct/col_dct_stream/tuser
add wave -noupdate -radix hexadecimal /tb_dct/dct_from_parallel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {487369860 ps} 0}
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
WaveRestoreZoom {0 ps} {1503668250 ps}
