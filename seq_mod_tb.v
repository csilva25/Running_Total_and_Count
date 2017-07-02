module seq_mod_tb();
	reg clk;
	reg [7:0] out;
	reg add_n;
	reg rst_n;
	reg error_count;
	integer i;
	
	counter dut(.enable(add_n),.clk(clk),.rst(rst_n),.out(out));
	task do_add;
	begin
		@ (negedge clk);
		add_n = 0;
		@ (negedge clk) add_n = 1;
	end
	endtask
	
	task reset;
	begin
		@ (negedge clk);
		rst_n = 0;
		@ (negedge clk) rst_n = 1;
	end
	endtask

		initial begin
		// Initialize variables
		clk = 0;
		add_n = 1;
		rst_n = 0; // Start in reset
		error_count = 0;


		$display("INFO: Starting simulation.");

		// Reset for 3 clock cycles
		repeat(3) @ (negedge clk);
			rst_n = 1;
		repeat(3) @ (negedge clk);

		// Hold the add button for multiple clock cycles
		@ (negedge clk);
			add_n = 0;
		repeat(5) @ (negedge clk);
			add_n = 1;

		// Check that reset works correctly
		@ (negedge clk);
			rst_n = 0;
		repeat(2) @ (negedge clk);
			rst_n = 1;
		@ (negedge clk);

		for (i = 0; i < 6; i = i + 1 )
			perform_test(i);
			//display
			$display("count %d",(i-1));
			//reset
			reset;
			//if not reset
		if (out != 0) 
		begin
			error_count = error_count + 1;
		//error message
			$display("error counter did not reset");
		end
	end
	
			
		task perform_test(input integer i);	
		begin
		if (i != out) 
		begin
			$display("Button is %d expected value is %b, actual value is %b",i,i,out,);
			error_count = error_count + 1;
		end
			else if (i > 255)
				reset;
			else 
				do_add;
		end
		endtask
		
		initial begin
		clk = 0;
		add_n = 1;
		rst_n = 0; // Start in reset
		error_count = 0;
		
		$display("INFO: Starting test.");
		reset;
		reset;
		
		for (i = 0; i < 260; i = i + 1)
			perform_test(i);
			reset;
			$display ("Testing counter reset function.");
			perform_reset_test;

		// Display test results
		if( error_count != 0 )
		begin
			$display("SUMMARY: %d test cases had errors in simulation.", error_count);
		end
			else 
			begin
				$display("SUMMARY: No errors detected in simulation.");
			end
		
		$display("SUMMARY: Simulation complete.");
		
		$stop;
	end

	
	always @ (clk)
	#5 clk <= ~clk;
endmodule

