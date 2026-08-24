
module pipelined_multiplier (
    input wire clk,
    input wire reset,
    input wire [7:0] operand_a,
    input wire [7:0] operand_b,
    input wire valid_in,
    output reg [15:0] result,
    output reg valid_out
);

    // Stage 1
    reg [7:0] stage1_a, stage1_b;
    reg stage1_valid;

    // Stage 2
    reg [7:0] stage2_a, stage2_b;
    reg [15:0] stage2_partial;
    reg stage2_valid;

    // Stage 3
    reg [15:0] stage3_sum;
    reg stage3_valid;

    // Stage 4
    reg [15:0] stage4_result;
    reg stage4_valid;


    // Stage 1
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stage1_a <= 0;
            stage1_b <= 0;
            stage1_valid <= 0;
        end else begin
            stage1_a <= operand_a;
            stage1_b <= operand_b;
            stage1_valid <= valid_in;
        end
    end


    // Stage 2 (lower 4 bits of A)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stage2_partial <= 0;
            stage2_a <= 0;
            stage2_b <= 0;
            stage2_valid <= 0;
        end else begin
            stage2_partial <= 
                (stage1_a[0] ? ({8'b0,stage1_b}      ) : 0) +
                (stage1_a[1] ? ({7'b0,stage1_b,1'b0}) : 0) +
                (stage1_a[2] ? ({6'b0,stage1_b,2'b0}) : 0) +
                (stage1_a[3] ? ({5'b0,stage1_b,3'b0}) : 0);

            stage2_a <= stage1_a;
            stage2_b <= stage1_b;
            stage2_valid <= stage1_valid;
        end
    end


    // Stage 3 (upper 4 bits of A)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stage3_sum <= 0;
            stage3_valid <= 0;
        end else begin
            stage3_sum <= stage2_partial +
                (stage2_a[4] ? ({4'b0,stage2_b,4'b0}) : 0) +
                (stage2_a[5] ? ({3'b0,stage2_b,5'b0}) : 0) +
                (stage2_a[6] ? ({2'b0,stage2_b,6'b0}) : 0) +
                (stage2_a[7] ? ({1'b0,stage2_b,7'b0}) : 0);

            stage3_valid <= stage2_valid;
        end
    end


    // Stage 4
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            stage4_result <= 0;
            stage4_valid <= 0;
        end else begin
            stage4_result <= stage3_sum;
            stage4_valid <= stage3_valid;
        end
    end


    // Output
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 0;
            valid_out <= 0;
        end else begin
            result <= stage4_result;
            valid_out <= stage4_valid;
        end
    end

endmodule