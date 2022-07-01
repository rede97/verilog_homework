module axis_mux #(
    parameter integer DATA_WIDTH = 8,
    parameter integer PORT_NUM   = 4
) (
    input  wire [              PORT_NUM-1:0] mux_ctrl_i,
    input  wire [DATA_WIDTH * PORT_NUM -1:0] s_axi_dat_i,
    input  wire [              PORT_NUM-1:0] s_axi_vld_i,
    output wire [              PORT_NUM-1:0] s_axi_rdy_o,
    output wire [            DATA_WIDTH-1:0] m_axi_dat_o,
    output wire                              m_axi_vld_o,
    input  wire                              m_axi_rdy_i
);

    // mux data of axi stream
    mux #(
        .DATA_WIDTH(DATA_WIDTH),
        .PORT_NUM  (PORT_NUM)
    ) axi_dat_mux (
        .ctrl_i(mux_ctrl_i),
        .data_i(s_axi_dat_i),
        .data_o(m_axi_dat_o)
    );

    // mux vld of axi stream
    mux #(
        .DATA_WIDTH(1),
        .PORT_NUM  (PORT_NUM)
    ) axi_vld_mux (
        .ctrl_i(mux_ctrl_i),
        .data_i(s_axi_vld_i),
        .data_o(m_axi_vld_o)
    );

    // demux rdy of axi stream
    demux #(
        .DATA_WIDTH(1),
        .PORT_NUM  (PORT_NUM)
    ) axi_rdy_demux (
        .ctrl_i(mux_ctrl_i),
        .data_i(m_axi_rdy_i),
        .data_o(s_axi_rdy_o)
    );

endmodule
