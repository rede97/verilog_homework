module mul #(
    parameter integer WIDTH = 16,
    parameter integer PIPELINE = 2
) (
    input wire clk_i,
    input wire rst_n_i,
    input wire [WIDTH-1:0] a_i,
    input wire [WIDTH-1:0] b_i,
    output wire [WIDTH * 2 - 1:0] c_o
);
    wire [WIDTH-1:0]abs_a = a_i[WIDTH-1] ? (-a_i) : a_i;
    wire [WIDTH-1:0]abs_b = b_i[WIDTH-1] ? (-b_i) : b_i;
    wire c_sign = a_i[WIDTH-1] ^ b_i[WIDTH-1];

    wire [WIDTH * 2 - 1:0] result;
    assign result = abs_a * abs_b;
    reg [WIDTH * 2 - 1:0] delay[PIPELINE-1:0];
    integer i;
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            for (i = 0; i < PIPELINE; i = i + 1) begin
                delay[i] <= 'd0;
            end
        end else begin
            for (i = 1; i < PIPELINE; i = i + 1) begin
                delay[i] <= delay[i-1];
            end
            delay[0] <= c_sign ? -result : result;
        end
    end

    assign c_o = delay[PIPELINE-1];
endmodule
