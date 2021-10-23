onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /dct_pkg::COEF_FRACT_WIDTH
add wave -noupdate -radix unsigned /dct_pkg::QUANTIZATION_MATRIX
add wave -noupdate -radix unsigned /dct_pkg::C1
add wave -noupdate -radix unsigned /dct_pkg::C2
add wave -noupdate -radix unsigned /dct_pkg::C3
add wave -noupdate -radix unsigned /dct_pkg::C4
add wave -noupdate -radix unsigned /dct_pkg::C5
add wave -noupdate -radix unsigned /dct_pkg::C6
add wave -noupdate -radix unsigned /dct_pkg::C7
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ns} {786 ns}
