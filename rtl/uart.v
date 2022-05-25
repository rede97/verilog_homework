module uart (
    input  wire        clk_i,
    input  wire        rst_n_i,
    // CONFIG IF
    input  wire        cfg_en_i,         // config: enable
    input  wire [11:0] cfg_div_i,        // config: clock div prescaler
    input  wire        cfg_parity_en_i,  // config: parity check enable
    input  wire [ 1:0] cfg_bits_i,       // config: bits 5,6,7
    input  wire        cfg_stop_bits_i,  // config: stop bit enable, 2-biots stop bit
    // UART IF
    input  wire        rx_i,
    output wire        tx_o,
    output wire        tx_busy_o,
    // Tx stream
    input  wire [ 7:0] tx_data_i,
    input  wire        tx_vld_i,
    output wire        tx_rdy_o,
    // Rx Stream
    output wire [ 7:0] rx_data_o,
    output wire        rx_vld_o,
    input  wire        rx_rdy_i
);


    uart_tx tx_u0 (
        .clk_i          (clk_i),
        .rst_n_i        (rst_n_i),
        .cfg_en_i       (cfg_en_i),
        .cfg_div_i      (cfg_div_i),
        .cfg_bits_i     (cfg_bits_i),
        .cfg_parity_en_i(cfg_parity_en_i),
        .cfg_stop_bits_i(cfg_stop_bits_i),
        .tx_o           (tx_o),
        .tx_busy_o      (tx_busy_o),
        .tx_data_i      (tx_data_i),
        .tx_vld_i       (tx_vld_i),
        .tx_rdy_o       (tx_rdy_o)
    );

    uart_rx rx_u1 (
        .clk_i          (clk_i),
        .rst_n_i        (rst_n_i),
        .cfg_en_i       (cfg_en_i),
        .cfg_div_i      (cfg_div_i),
        .cfg_bits_i     (cfg_bits_i),
        .cfg_parity_en_i(cfg_parity_en_i),
        .rx_i           (rx_i),
        .rx_data_o      (rx_data_o),
        .rx_vld_o       (rx_vld_o),
        .rx_rdy_i       (rx_rdy_i)
    );

endmodule
