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
add wave -noupdate /tb_dct/zz_inst/clk_i
add wave -noupdate /tb_dct/zz_inst/rst_i
add wave -noupdate -radix decimal /tb_dct/zz_inst/input_buf
add wave -noupdate -radix decimal /tb_dct/zz_inst/zz_buf
add wave -noupdate -radix decimal /tb_dct/zz_inst/output_buf
add wave -noupdate /tb_dct/zz_inst/input_buf_cnt
add wave -noupdate /tb_dct/zz_inst/px_cnt
add wave -noupdate /tb_dct/zz_inst/output_cnt
add wave -noupdate /tb_dct/zz_inst/load_input_buf
add wave -noupdate /tb_dct/zz_inst/load_output_buf
add wave -noupdate /tb_dct/zz_inst/output_buf_empty
add wave -noupdate /tb_dct/zz_inst/output_buf_empty_comb
add wave -noupdate /tb_dct/zz_inst/input_buf_full
add wave -noupdate /tb_dct/zz_inst/input_buf_full_comb
add wave -noupdate /tb_dct/zz_inst/tlast_lock
add wave -noupdate /tb_dct/zz_inst/tlast_buf
add wave -noupdate /tb_dct/zz_inst/tuser_lock
add wave -noupdate /tb_dct/zz_inst/tuser_buf
add wave -noupdate /tb_dct/zz/aclk
add wave -noupdate /tb_dct/zz/aresetn
add wave -noupdate /tb_dct/zz/tvalid
add wave -noupdate /tb_dct/zz/tready
add wave -noupdate /tb_dct/zz/tdata
add wave -noupdate /tb_dct/zz/tstrb
add wave -noupdate /tb_dct/zz/tkeep
add wave -noupdate /tb_dct/zz/tlast
add wave -noupdate /tb_dct/zz/tid
add wave -noupdate /tb_dct/zz/tdest
add wave -noupdate /tb_dct/zz/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29165000 ps} 0}
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
WaveRestoreZoom {29126075 ps} {29225563 ps}
