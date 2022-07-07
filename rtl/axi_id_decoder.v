module axi_id_decoder #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Master interface number
    parameter integer AXI_PORT_NUM = 2
) (
    input  wire [AXI_ID_WIDTH-1:0] id_i,
    output wire [AXI_PORT_NUM-1:0] gnt_o
);
    reg [AXI_PORT_NUM-1:0] gnt;
    assign gnt_o = gnt;
    always @(*) begin
        case (id_i)
            'd0: begin
                gnt = 3'b001;
            end
            'd1: begin
                gnt = 3'b010;
            end
            'd2: begin
                gnt = 3'b100;
            end
            default: begin
                $display("Error: invalid id %0d", id_i);
                $stop;
            end
        endcase
    end
endmodule
