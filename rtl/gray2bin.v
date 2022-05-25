module gray2bin #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] data_gray_i,  // gray code input
    output wire [DATA_WIDTH-1:0] data_bin_o    // binary output
);
    assign data_bin_o[DATA_WIDTH-1] = data_gray_i[DATA_WIDTH-1];
    generate
        genvar i;
        for (i = 0; i < DATA_WIDTH - 1; i = i + 1) begin : gen_gray_to_bin
            assign data_bin_o[i] = data_bin_o[i+1] ^ data_gray_i[i];
        end
    endgenerate

endmodule
