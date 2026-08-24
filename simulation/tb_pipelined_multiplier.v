
module pipelined_multiplier_tb;
    reg clk;
    reg reset;
    reg [7:0] operand_a;
    reg [7:0] operand_b;
    reg valid_in;
    wire [15:0] result;
    wire valid_out;
    
    // Instantiate DUT
    pipelined_multiplier uut (
        .clk(clk),
        .reset(reset),
        .operand_a(operand_a),
        .operand_b(operand_b),
        .valid_in(valid_in),
        .result(result),
        .valid_out(valid_out)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        valid_in = 0;
        operand_a = 0;
        operand_b = 0;
        
        // Release reset
        #10 reset = 0;
        
        // Feed test data (throughput demonstration)
        #10 valid_in = 1; operand_a = 12; operand_b = 5;  // 12 * 5 = 60
        #10 valid_in = 1; operand_a = 8;  operand_b = 7;  // 8 * 7 = 56
        #10 valid_in = 1; operand_a = 15; operand_b = 3;  // 15 * 3 = 45
        #10 valid_in = 1; operand_a = 6;  operand_b = 9;  // 6 * 9 = 54
        #10 valid_in = 0;
        
        // Observe pipeline filling and results appearing
        #80;
        
        $finish;
    end
    
    // Monitor results
    initial begin
        $monitor("Time=%0t | valid_out=%b | result=%0d", 
                 $time, valid_out, result);
    end
    
    // Dump waveforms
    initial begin
        $dumpfile("pipeline_tb.vcd");
        $dumpvars(0, pipelined_multiplier_tb);
    end

endmodule