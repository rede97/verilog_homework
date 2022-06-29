module axi_id_decoder #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Master interface number
    parameter integer AXI_PORT_NUM = 2
) (
    input  wire [AXI_ID_WIDTH-1:0] id_i,
    output wire [AXI_PORT_NUM-1:0] gnt_o
);
    assign gnt_o = 'b1;
endmodule
