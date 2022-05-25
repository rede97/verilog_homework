module rd_empty #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] rd_ptr_gray_i,  // gray code read-pointer
    input  wire [WIDTH-1:0] wr_ptr_gray_i,  // gray code write-pointer
    output wire             empty_o         // empty flag
);
    assign empty_o = rd_ptr_gray_i == wr_ptr_gray_i;
endmodule
