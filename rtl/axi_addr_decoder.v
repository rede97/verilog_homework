module axi_addr_decoder #(
    // Width of S_AXI address bus
    parameter integer AXI_ADDR_WIDTH = 32,
    // Slave interface number
    parameter integer AXI_PORT_NUM   = 2
) (
    input [AXI_ADDR_WIDTH-1:0] addr_i,
    output [AXI_PORT_NUM-1:0] trgt_o,
    output misrouting_o
);
    assign misrouting_o = trgt_o == 0;
    assign trgt_o = (addr_i < 32'h1000_0000) ? 'b001 : (addr_i < 32'h4000_0000) ? 'b010 : 'b100;
endmodule
