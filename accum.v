module accum(input en, clk, rst, input [15:0] in, output reg [15:0] out);
always@ (posedge clk , negedge rst) begin
	if (~rst) begin
		out <= 16'b00;
	end 
	else if(en)begin
		out <= in;
	end
end
endmodule
