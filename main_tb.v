module main_tb();
	localparam NUM_RANDOM_TESTS = 50;
	localparam MAX_HEX_DIGITS_TEST = 4; // The maximum number of hex digits per call to perform_test
	localparam MAX_STR_LEN_TEST = 100;  // The maximum string length passed to perform_test

	reg clk;
	reg [7:0] SW;
	reg add_n;
	reg rst_n;
	wire [6:0] count [1:0];
	wire [6:0] value [1:0];
	wire [6:0] sum [3:0];
	reg [6:0] seven_seg_table [0:15];
	reg [7:0] expected_count;
	reg [15:0] expected_sum;
	integer error_count;

	main dut(.clk(clk), .SW(SW), .add_n(add_n), .rst_n(rst_n),
		.CNT_HEX1(count[1]), .CNT_HEX0(count[0]),
		.IN_HEX1(value[1]), .IN_HEX0(value[0]),
		.SUM_HEX3(sum[3]), .SUM_HEX2(sum[2]), .SUM_HEX1(sum[1]), .SUM_HEX0(sum[0]));

	// Hold button active for one rising clock edge
	task do_add;
	begin
		@ (negedge clk);
		add_n = 0;
		@ (negedge clk) add_n = 1;
	end
	endtask

	// Change the switch values during the next possible clock low time
	task set_switches(input [7:0] val);
	begin
		wait(clk == 0);
		SW = val;
	end
	endtask

	// Convert a value to its 7-segment representation
	function [6:0] to_7seg(input [3:0] val);
	begin
		to_7seg = seven_seg_table[val];
	end
	endfunction

	// Check the output of the 7-segment displays in actual_7seg against the expected_val,
	// which needs to be converted to 7-segment display signals first. Only check hex_digits
	// number of hexadecimal digits, starting at lowest bits. Include the val_type string
	// to any error messages displayed.
	task perform_test (
		
		input [MAX_HEX_DIGITS_TEST*4:0] expected_val,
		input [7*MAX_HEX_DIGITS_TEST-1:0] actual_7seg,
		input integer hex_digits,
		input [MAX_STR_LEN_TEST*8-1:0] val_type);
		
		reg error;
		integer i;
	begin
		error = 0;
		// Ignore system in reset
		if( rst_n == 1'b1 ) begin
			for( i = 0; (i < hex_digits) && (i < MAX_HEX_DIGITS_TEST) && (!error); i = i + 1 ) begin
				// v[x +: y] is a part select operator, starting at bit x and going to bit x+y.
				// x may be a variable, but y must be a constant. [x -: y] also available.
				if( to_7seg(expected_val[4*i +: 4]) !== actual_7seg[7*i +: 7] ) begin
					error = 1;
				end
			end
		
			if( error ) begin
				$write("ERROR at %t: %0s display incorrect, expecting", $time, val_type);
				for( i = hex_digits - 1; i >= 0; i = i - 1 ) begin
					$write(" %b", to_7seg(expected_val[4*i +: 4]));
				end
				$write(" and received");
				for( i = hex_digits - 1; i >= 0; i = i - 1 ) begin
					$write(" %b", actual_7seg[7*i +: 7]);
				end
				$display(""); // Newline
				error_count = error_count + 1;
			end
		end
	end
	endtask

	initial begin
		// Initialize variables
		clk = 0;
		SW = 0;
		add_n = 1;
		rst_n = 0; // Start in reset
		expected_count = 0;
		expected_sum = 0;
		error_count = 0;

		// Load the 7-segment data
		$readmemh("lab3_data.dat", seven_seg_table);

		$display("INFO: Starting simulation.");

		// Reset for 3 clock cycles
		repeat(3) @ (negedge clk);
		rst_n = 1;
		repeat(3) @ (negedge clk);

		// Test a couple of simple adds
		set_switches(8'd1);
		do_add();
		do_add();
		do_add();
		
		// Change input between clock cycles
		@ (negedge clk);
		set_switches(8'hFF);
		#3 set_switches(8'h55);
		@ (negedge clk);
		#3 set_switches(8'hAA);

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

		// Add zero a couple times
		set_switches(0);
		do_add();
		do_add();
		
		// Overflow the sum and count.
		// 9 bits of sum change, including the most significant bit of switches.
		// Count overflows after 256 adds.
		set_switches(8'h80);
		repeat(512) do_add();

		// Some random tests as well
		repeat(NUM_RANDOM_TESTS) begin
			set_switches($random);
			do_add();
		end

		// Display test results
		if( error_count != 0 ) begin
			$display("SUMMARY: %d test cases had errors in simulation.", error_count);
		end
		else begin
			$display("SUMMARY: No errors detected in simulation.");
		end
		
		$display("SUMMARY: Simulation complete.");
		
		$stop;
	end

	// Generate the clock
	always @ (clk)
		#5 clk <= ~clk;

	// Verify the 7-segment displays for the input
	always @ (SW) begin
		#1; // Delay ensures model has updated
		perform_test(SW, {value[1],value[0]}, 2, "Operand");
	end

	// Verify the 7-segment displays for the count and sum
	always @ (negedge add_n, negedge rst_n) begin
		if( ~rst_n ) begin
			expected_count <= 0;
			expected_sum <= 0;
		end
		else begin
			expected_count <= expected_count + 1;
			expected_sum <= expected_sum + SW;
		end
	end
	always @ (negedge clk) begin
		perform_test(expected_count, {count[1],count[0]}, 2, "Count");
		perform_test(expected_sum, {sum[3],sum[2],sum[1],sum[0]}, 4, "Sum");
	end
	
endmodule
