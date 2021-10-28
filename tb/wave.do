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
