module edge_detc(input en, clk, output out);
reg last_en;
always @(posedge clk)begin
	last_en <= en;
end
	and (out, last_en,~en);
endmodule
