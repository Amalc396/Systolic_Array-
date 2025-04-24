module systolic_pe (
    input clk,                    // Clock signal
    input rst_n,                  // Active-low reset
    input [7:0] a_in,             // 8-bit input A (multiplicand)
    input [7:0] b_in,             // 8-bit input B (multiplier)
    input [15:0] sum_in,          // 16-bit input sum (from previous PE or external)
    output [7:0] a_out,           // 8-bit output A (passed to next PE)
    output [7:0] b_out,           // 8-bit output B (passed to next PE)
    output [16:0] sum_out,        // 17-bit output sum (result of CSA)
    output cout                   // Carry out from CSA
);

   
    wire [15:0] mult_result;      

    
    wallaceTreeMultiplier8Bit wtm (
        .clk(clk),
        .rst_n(rst_n),
        .a(a_in),
        .b(b_in),
        .result(mult_result)
    );

    
    carry_save_adder_16bit csa (
        .clk(clk),
        .rst_n(rst_n),
        .A(mult_result),          
        .B(sum_in),               
        .C(16'b0),                
        .a_pass(a_in),            
        .b_pass(b_in),            
        .SUM(sum_out),
        .COUT(cout),
        .a_out(a_out),
        .b_out(b_out)
    );

endmodule

module wallaceTreeMultiplier8Bit (
    input clk,
    input rst_n,
    input [7:0] a,
    input [7:0] b,
    output [15:0] result
);
    
    reg [7:0] a_reg;
    reg [7:0] b_reg;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 8'b0;
            b_reg <= 8'b0;
        end
        else begin
            a_reg <= a;
            b_reg <= b;
        end
    end

    
    reg [7:0] wallaceTree[7:0];
    integer i, j;

    always @(a_reg, b_reg) begin
        for(i = 0; i < 8; i = i + 1)
            for(j = 0; j < 8; j = j + 1)
                wallaceTree[i][j] = a_reg[i] & b_reg[j];
    end

    assign result[0] = wallaceTree[0][0];

    wire result1_c;
    HA result1_HA_1(result1_c, result[1], wallaceTree[0][1], wallaceTree[1][0]);

    wire result2_c_temp_1, result2_c, result2_temp_1;
    FA result2_FA_1(result2_c_temp_1, result2_temp_1, wallaceTree[0][2], wallaceTree[1][1], result1_c);
    HA result2_HA_1(result2_c, result[2], wallaceTree[2][0], result2_temp_1);

    wire result3_c_temp_1, result3_c_temp_2, result3_c, result3_temp_1, result3_temp_2;
    FA result3_FA_1(result3_c_temp_1, result3_temp_1, wallaceTree[0][3], wallaceTree[1][2], result2_c);
    FA result3_FA_2(result3_c_temp_2, result3_temp_2, wallaceTree[2][1], result3_temp_1, result2_c_temp_1);
    HA result3_HA_1(result3_c, result[3], wallaceTree[3][0], result3_temp_2);

    wire result4_c_temp_1, result4_c_temp_2, result4_c_temp_3, result4_c, result4_temp_1, result4_temp_2, result4_temp_3;
    FA result4_FA_1(result4_c_temp_1, result4_temp_1, wallaceTree[0][4], wallaceTree[1][3], result3_c);
    FA result4_FA_2(result4_c_temp_2, result4_temp_2, wallaceTree[2][2], result4_temp_1, result3_c_temp_1);
    FA result4_FA_3(result4_c_temp_3, result4_temp_3, wallaceTree[3][1], result4_temp_2, result3_c_temp_2);
    HA result4_HA_1(result4_c, result[4], wallaceTree[4][0], result4_temp_3);

    wire result5_c_temp_1, result5_c_temp_2, result5_c_temp_3, result5_c_temp_4, result5_c, result5_temp_1, result5_temp_2, result5_temp_3, result5_temp_4;
    FA result5_FA_1(result5_c_temp_1, result5_temp_1, wallaceTree[0][5], wallaceTree[1][4], result4_c);
    FA result5_FA_2(result5_c_temp_2, result5_temp_2, wallaceTree[2][3], result5_temp_1, result4_c_temp_1);
    FA result5_FA_3(result5_c_temp_3, result5_temp_3, wallaceTree[3][2], result5_temp_2, result4_c_temp_2);
    FA result5_FA_4(result5_c_temp_4, result5_temp_4, wallaceTree[4][1], result5_temp_3, result4_c_temp_3);
    HA result5_HA_1(result5_c, result[5], wallaceTree[5][0], result5_temp_4);

    wire result6_c_temp_1, result6_c_temp_2, result6_c_temp_3, result6_c_temp_4, result6_c_temp_5, result6_c, result6_temp_1, result6_temp_2, result6_temp_3, result6_temp_4, result6_temp_5;
    FA result6_FA_1(result6_c_temp_1, result6_temp_1, wallaceTree[0][6], wallaceTree[1][5], result5_c);
    FA result6_FA_2(result6_c_temp_2, result6_temp_2, wallaceTree[2][4], result6_temp_1, result5_c_temp_1);
    FA result6_FA_3(result6_c_temp_3, result6_temp_3, wallaceTree[3][3], result6_temp_2, result5_c_temp_2);
    FA result6_FA_4(result6_c_temp_4, result6_temp_4, wallaceTree[4][2], result6_temp_3, result5_c_temp_3);
    FA result6_FA_5(result6_c_temp_5, result6_temp_5, wallaceTree[5][1], result6_temp_4, result5_c_temp_4);
    HA result6_HA_1(result6_c, result[6], wallaceTree[6][0], result6_temp_5);

    wire result7_c_temp_1, result7_c_temp_2, result7_c_temp_3, result7_c_temp_4, result7_c_temp_5, result7_c_temp_6, result7_c, result7_temp_1, result7_temp_2, result7_temp_3, result7_temp_4, result7_temp_5, result7_temp_6;
    FA result7_FA_1(result7_c_temp_1, result7_temp_1, wallaceTree[0][7], wallaceTree[1][6], result6_c);
    FA result7_FA_2(result7_c_temp_2, result7_temp_2, wallaceTree[2][5], result7_temp_1, result6_c_temp_1);
    FA result7_FA_3(result7_c_temp_3, result7_temp_3, wallaceTree[3][4], result7_temp_2, result6_c_temp_2);
    FA result7_FA_4(result7_c_temp_4, result7_temp_4, wallaceTree[4][3], result7_temp_3, result6_c_temp_3);
    FA result7_FA_5(result7_c_temp_5, result7_temp_5, wallaceTree[5][2], result7_temp_4, result6_c_temp_4);
    FA result7_FA_6(result7_c_temp_6, result7_temp_6, wallaceTree[6][1], result7_temp_5, result6_c_temp_5);
    HA result7_HA_1(result7_c, result[7], wallaceTree[7][0], result7_temp_6);

    wire result8_c_temp_1, result8_c_temp_2, result8_c_temp_3, result8_c_temp_4, result8_c_temp_5, result8_c_temp_6, result8_c, result8_temp_1, result8_temp_2, result8_temp_3, result8_temp_4, result8_temp_5, result8_temp_6;
    FA result8_FA_1(result8_c_temp_1, result8_temp_1, wallaceTree[1][7], wallaceTree[2][6], result7_c);
    FA result8_FA_2(result8_c_temp_2, result8_temp_2, wallaceTree[3][5], result8_temp_1, result7_c_temp_1);
    FA result8_FA_3(result8_c_temp_3, result8_temp_3, wallaceTree[4][4], result8_temp_2, result7_c_temp_2);
    FA result8_FA_4(result8_c_temp_4, result8_temp_4, wallaceTree[5][3], result8_temp_3, result7_c_temp_3);
    FA result8_FA_5(result8_c_temp_5, result8_temp_5, wallaceTree[6][2], result8_temp_4, result7_c_temp_4);
    FA result8_FA_6(result8_c_temp_6, result8_temp_6, wallaceTree[7][1], result8_temp_5, result7_c_temp_5);
    HA result8_HA_1(result8_c, result[8], result8_temp_6, result7_c_temp_6);

    wire result9_c_temp_1, result9_c_temp_2, result9_c_temp_3, result9_c_temp_4, result9_c_temp_5, result9_c, result9_temp_1, result9_temp_2, result9_temp_3, result9_temp_4, result9_temp_5;
    FA result9_FA_1(result9_c_temp_1, result9_temp_1, wallaceTree[2][7], wallaceTree[3][6], result8_c);
    FA result9_FA_2(result9_c_temp_2, result9_temp_2, wallaceTree[4][5], result9_temp_1, result8_c_temp_1);
    FA result9_FA_3(result9_c_temp_3, result9_temp_3, wallaceTree[5][4], result9_temp_2, result8_c_temp_2);
    FA result9_FA_4(result9_c_temp_4, result9_temp_4, wallaceTree[6][3], result9_temp_3, result8_c_temp_3);
    FA result9_FA_5(result9_c_temp_5, result9_temp_5, wallaceTree[7][2], result9_temp_4, result8_c_temp_4);
    FA result9_FA_6(result9_c, result[9], result9_temp_5, result8_c_temp_5, result8_c_temp_6);

    wire result10_c_temp_1, result10_c_temp_2, result10_c_temp_3, result10_c_temp_4, result10_c, result10_temp_1, result10_temp_2, result10_temp_3, result10_temp_4;
    FA result10_FA_1(result10_c_temp_1, result10_temp_1, wallaceTree[3][7], wallaceTree[4][6], result9_c);
    FA result10_FA_2(result10_c_temp_2, result10_temp_2, wallaceTree[5][5], result10_temp_1, result9_c_temp_1);
    FA result10_FA_3(result10_c_temp_3, result10_temp_3, wallaceTree[6][4], result10_temp_2, result9_c_temp_2);
    FA result10_FA_4(result10_c_temp_4, result10_temp_4, wallaceTree[7][3], result10_temp_3, result9_c_temp_3);
    FA result10_FA_5(result10_c, result[10], result10_temp_4, result9_c_temp_4, result9_c_temp_5);

    wire result11_c_temp_1, result11_c_temp_2, result11_c_temp_3, result11_c, result11_temp_1, result11_temp_2, result11_temp_3;
    FA result11_FA_1(result11_c_temp_1, result11_temp_1, wallaceTree[4][7], wallaceTree[5][6], result10_c);
    FA result11_FA_2(result11_c_temp_2, result11_temp_2, wallaceTree[6][5], result11_temp_1, result10_c_temp_1);
    FA result11_FA_3(result11_c_temp_3, result11_temp_3, wallaceTree[7][4], result11_temp_2, result10_c_temp_2);
    FA result11_FA_4(result11_c, result[11], result11_temp_3, result10_c_temp_3, result10_c_temp_4);

    wire result12_c_temp_1, result12_c_temp_2, result12_c, result12_temp_1, result12_temp_2;
    FA result12_FA_1(result12_c_temp_1, result12_temp_1, wallaceTree[5][7], wallaceTree[6][6], result11_c);
    FA result12_FA_2(result12_c_temp_2, result12_temp_2, wallaceTree[7][5], result12_temp_1, result11_c_temp_1);
    FA result12_FA_3(result12_c, result[12], result12_temp_2, result11_c_temp_2, result11_c_temp_3);

    wire result13_c, result13_temp_1;
    FA result13_FA_1(result13_c_temp_1, result13_temp_1, wallaceTree[6][7], wallaceTree[7][6], result12_c);
    FA result13_FA_2(result13_c, result[13], result13_temp_1, result12_c_temp_2, result12_c_temp_1);

    wire result14_c;
    FA result14_FA_1(result14_c, result[14], wallaceTree[7][7], result13_c, result13_c_temp_1);

    assign result[15] = result14_c;
endmodule

module carry_save_adder_16bit (
    input clk,
    input rst_n,
    input [15:0] A,
    input [15:0] B,
    input [15:0] C,
    input [7:0] a_pass,           // Pass-through input for a_in
    input [7:0] b_pass,           // Pass-through input for b_in
    output [16:0] SUM,
    output COUT,
    output [7:0] a_out,           // Pass-through output for a_in
    output [7:0] b_out            // Pass-through output for b_in
);
   
    wire [15:0] carry;
    wire [15:0] sum;
    wire [16:0] ripple_sum;
    wire cout_wire;

    
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : csa_stage
            full_adder fa (
                .a(A[i]),
                .b(B[i]),
                .cin(C[i]),
                .sum(sum[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    assign ripple_sum[0] = sum[0];
    
    generate
        for (i = 1; i < 16; i = i + 1) begin : ripple_stage
            full_adder fa_ripple (
                .a(sum[i]),
                .b(carry[i-1]),
                .cin(1'b0),
                .sum(ripple_sum[i]),
                .cout()
            );
        end
    endgenerate

    full_adder fa_final (
        .a(carry[15]),
        .b(1'b0),
        .cin(1'b0),
        .sum(ripple_sum[16]),
        .cout(cout_wire)
    );

    
    reg [16:0] sum_out_reg;
    reg cout_reg;
    reg [7:0] a_out_reg;
    reg [7:0] b_out_reg;

    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_out_reg <= 17'b0;
            cout_reg <= 1'b0;
            a_out_reg <= 8'b0;
            b_out_reg <= 8'b0;
        end
        else begin
            sum_out_reg <= ripple_sum;
            cout_reg <= cout_wire;
            a_out_reg <= a_pass;
            b_out_reg <= b_pass;
        end
    end

    
    assign SUM = sum_out_reg;
    assign COUT = cout_reg;
    assign a_out = a_out_reg;
    assign b_out = b_out_reg;

endmodule


primitive carryOut (output Cout, input A, input B, input Cin);
    table
        1 1 ? : 1;
        1 ? 1 : 1;
        ? 1 1 : 1;
        0 0 ? : 0;
        0 ? 0 : 0;
        ? 0 0 : 0;
    endtable
endprimitive

primitive sumOut (output sum, input A, input B, input Cin);
    table
        1 1 1 : 1;
        1 0 0 : 1;
        0 1 0 : 1;
        0 0 1 : 1;
        0 0 0 : 0;
        0 1 1 : 0;
        1 0 1 : 0;
        1 1 0 : 0;
    endtable
endprimitive

module FA(output Cout, output sum, input A, input B, input Cin);
    sumOut s(sum, A, B, Cin);
    carryOut co(Cout, A, B, Cin);
endmodule 

primitive outSum(output sum, input A, input B);
    table
        0 0 : 0;
        0 1 : 1;
        1 0 : 1;
        1 1 : 0;
    endtable
endprimitive

primitive outCarry(output carry, input A, input B);
    table
        0 0 : 0;
        0 1 : 0;
        1 0 : 0;
        1 1 : 1;
    endtable
endprimitive

module HA (output carry, output sum, input A, input B);
    outSum s(sum, A, B);
    outCarry c(carry, A, B);
endmodule

module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule
