module bin2gray #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] data_bin_i,  // binary input
    output wire [DATA_WIDTH-1:0] data_gray_o  // gray code ouptut
);
    assign data_gray_o = (data_bin_i >> 1) ^ data_bin_i;
endmodule
