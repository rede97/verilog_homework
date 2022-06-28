module axis_demux #(
    parameter integer DATA_WIDTH = 8,
    parameter integer PORT_NUM   = 4
) (
    input  wire [              PORT_NUM-1:0] demux_ctrl_i,
    input  wire [            DATA_WIDTH-1:0] s_axi_dat_i,
    input  wire                              s_axi_vld_i,
    output wire                              s_axi_rdy_o,
    output wire [DATA_WIDTH * PORT_NUM -1:0] m_axi_dat_o,
    output wire [              PORT_NUM-1:0] m_axi_vld_o,
    input  wire [              PORT_NUM-1:0] m_axi_rdy_i
);

    genvar i;
    generate
        for (i = 0; i < PORT_NUM; i = i + 1) begin : g_data_connect
            assign m_axi_dat_o[(i+1)*DATA_WIDTH-1:i*DATA_WIDTH] = s_axi_dat_i;
        end
    endgenerate

    // demux vld of axi stream
    demux #(
        .DATA_WIDTH(1),
        .PORT_NUM  (PORT_NUM)
    ) axi_vld_demux (
        .data_i(s_axi_vld_i),
        .ctrl_i(demux_ctrl_i),
        .data_o(m_axi_vld_o)
    );

    // mux rdy of axi stream
    mux #(
        .DATA_WIDTH(1),
        .PORT_NUM  (PORT_NUM)
    ) axi_rdy_mux (
        .data_i(m_axi_rdy_i),
        .ctrl_i(demux_ctrl_i),
        .data_o(s_axi_rdy_o)
    );

endmodule
