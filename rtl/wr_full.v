module wr_full #(
    parameter WIDTH = 8  // WIDTH >= 3
) (
    input  wire [WIDTH-1:0] rd_ptr_gray_i,  // gray code read-pointer
    input  wire [WIDTH-1:0] wr_ptr_gray_i,  // gray code write-pointer
    output wire             full_o          // full flag
);
    assign full_o = wr_ptr_gray_i == {~rd_ptr_gray_i[WIDTH-1:WIDTH-2], rd_ptr_gray_i[WIDTH-3:0]};
endmodule
