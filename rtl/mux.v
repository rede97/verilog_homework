module mux #(
    parameter integer DATA_WIDTH = 8,
    parameter integer PORT_NUM   = 4
) (
    input  [DATA_WIDTH*PORT_NUM-1:0] data_i,
    input  [           PORT_NUM-1:0] ctrl_i,
    output [         DATA_WIDTH-1:0] data_o
);

    wire [DATA_WIDTH-1:0] data_mux_cascade[0:PORT_NUM];
    genvar i;
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : g_data_mux_cascade
            assign data_mux_cascade[i] =
                ctrl_i[i] ? data_i[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] : data_mux_cascade[i];
        end
    endgenerate
    assign data_mux_cascade[PORT_NUM] = 'd0;
    assign data_o = data_mux_cascade[0];

endmodule
