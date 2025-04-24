module systolic_array_4x4 (
    input clk,
    input rst_n,
    input [31:0] a_in,      // Flattened 4x8-bit input A (4 PEs x 8 bits)
    input [31:0] b_in,      // Flattened 4x8-bit input B (4 PEs x 8 bits)
    output [16:0] sum_out,  // 17-bit output sum from bottom-right PE
    output cout             // 1-bit carry out from bottom-right PE
);

    wire [7:0] a_inter [3:0][4:0]; // 4x5 array of 8-bit a signals (extra column for boundary)
    wire [7:0] b_inter [4:0][3:0]; // 5x4 array of 8-bit b signals (extra row for boundary)
    wire [16:0] sum_inter [4:0][4:0]; // 5x5 array of 17-bit sum signals (extra for initialization)
    wire cout_inter [3:0][3:0];     // 4x4 array of 1-bit carry signals

    // Unpack flattened inputs into arrays
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : unpack_inputs
            assign a_inter[i][0] = a_in[(i+1)*8-1 -: 8];
            assign b_inter[0][i] = b_in[(i+1)*8-1 -: 8];
        end
    endgenerate

    // Initialize sum_inter for first row and column to 0
    generate
        for (i = 0; i < 5; i = i + 1) begin : init_sum_row
            assign sum_inter[i][0] = 17'b0;
        end
        for (i = 0; i < 5; i = i + 1) begin : init_sum_col
            assign sum_inter[0][i] = 17'b0;
        end
    endgenerate

    // Generate 4x4 PE array
    genvar j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : row_gen
            for (j = 0; j < 4; j = j + 1) begin : col_gen
                systolic_pe pe (
                    .clk(clk),
                    .rst_n(rst_n),
                    .a_in(a_inter[i][j]),
                    .b_in(b_inter[i][j]),
                    .sum_in(sum_inter[i][j]), // Sum comes from top-left (diagonal flow)
                    .a_out(a_inter[i][j+1]),
                    .b_out(b_inter[i+1][j]),
                    .sum_out(sum_inter[i+1][j+1]), // Sum goes to bottom-right
                    .cout(cout_inter[i][j])
                );
            end
        end
    endgenerate

    // Assign outputs from the bottom-right PE (3,3)
    assign sum_out = sum_inter[4][4];
    assign cout = cout_inter[3][3];

endmodule

module top (
    input clk,
    input rst_n,
    input [31:0] a_in,
    input [31:0] b_in,
    output [16:0] sum_out,
    output cout
);

    systolic_array_4x4 sa (
        .clk(clk),
        .rst_n(rst_n),
        .a_in(a_in),
        .b_in(b_in),
        .sum_out(sum_out),
        .cout(cout)
    );

endmodule
