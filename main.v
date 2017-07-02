module main(input clk,
 input [7:0] SW, 
 input add_n, rst_n, 
 output [6:0] CNT_HEX1, CNT_HEX0, IN_HEX1, IN_HEX0, SUM_HEX3, SUM_HEX2, SUM_HEX1, SUM_HEX0);


wire [7:0] cnt;
wire [15:0] accum_out, add_out;
wire enable;

edge_detc ed0(.en(add_n),.clk(clk),.out(enable));
counter c0( .enable(enable), .clk(clk), .rst(rst_n) ,.out(cnt));
accum ac0(.en(enable), .clk (clk), .rst(rst_n), .in(add_out), .out(accum_out));
adder_16b add0( .a( SW[7:0]), .b(accum_out), .sum(add_out));

/* --------- counter ---------- */
converter_7s seg0(.a(cnt[3:0]) ,.display(CNT_HEX0) );
converter_7s seg1(.a(cnt[7:4]) ,.display(CNT_HEX1) );

/* --------- input representaion ---------- */
converter_7s seg2(.a(SW[3:0]) ,.display(IN_HEX0) );
converter_7s seg3(.a(SW[7:4]) ,.display(IN_HEX1) );

/* --------- switches ---------- */

converter_7s seg4(.a(accum_out[3:0]) ,.display(SUM_HEX0) );
converter_7s seg5(.a(accum_out[7:4]) ,.display(SUM_HEX1) );
converter_7s seg6(.a(accum_out[11:8]) ,.display(SUM_HEX2) );
converter_7s seg7(.a(accum_out[15:12]) ,.display(SUM_HEX3) );



endmodule
