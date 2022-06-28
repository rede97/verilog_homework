module demux #(
    parameter integer DATA_WIDTH = 8,
    parameter integer PORT_NUM   = 4
) (
    input  wire [            DATA_WIDTH-1:0] data_i,
    input  wire [              PORT_NUM-1:0] ctrl_i,
    output wire [DATA_WIDTH * PORT_NUM -1:0] data_o
);

    genvar i;
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : g_demux
            assign data_o[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] = ctrl_i[i] ? data_i : 'd0;
        end
    endgenerate

endmodule
