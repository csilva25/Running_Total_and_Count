module counter(input enable,clk,rst , output reg   [7:0] out);

always @(posedge clk , negedge rst) begin
	if ( ~ rst ) begin
		out <= 1'b0;
	end
	else if (enable) begin
			out <= out + 1;
end
end
endmodule
