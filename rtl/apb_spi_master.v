module apb_spi_master (
    input  wire        pclk_i,
    input  wire        rst_n_i,
    input  wire        psel_i,
    input  wire        penable_i,
    input  wire [ 3:0] paddr_i,
    input  wire        pwrite_i,
    input  wire [31:0] pwdata_i,
    output wire [31:0] prdata_o,
    output wire        pready_o,
    // SPI interface
    output wire        spi_clk_o,
    output wire        spi_sdo_o,
    output wire        spi_cs_n_o,
    input  wire        spi_sdi_i
);

    wire        eot;
    wire [31:0] stream_data_tx;
    wire        stream_data_tx_vld;
    wire        stream_data_tx_rdy;
    wire [31:0] spi_stream_rx;
    wire        spi_stream_rx_rdy;
    wire        spi_stream_rx_vld;
    wire        spi_clk_div_vld;
    wire [15:0] spi_clk_div;

    // SPI master controller
    spi_master_controller spi_master (
        .clk_i               (pclk_i),
        .rst_n_i             (rst_n_i),
        .spi_clk_div_i       (spi_clk_div),
        .spi_clk_div_vld_i   (spi_clk_div_vld),
        .stream_data_tx_i    (stream_data_tx),
        .stream_data_tx_vld_i(stream_data_tx_vld),
        .stream_data_tx_rdy_o(stream_data_tx_rdy),
        .stream_data_rx_o    (spi_stream_rx),
        .stream_data_rx_vld_o(spi_stream_rx_vld),
        .stream_data_rx_rdy_i(spi_stream_rx_rdy),
        .spi_clk_o           (spi_clk_o),
        .spi_cs_n_o          (spi_cs_n_o),
        .spi_sdo_o           (spi_sdo_o),
        .spi_sdi_i           (spi_sdi_i),
        .eot_o               (eot)
    );

    // APB Registers
    apb_spi_rf apb_registers (
        .pclk_i              (pclk_i),
        .rst_n_i             (rst_n_i),
        .psel_i              (psel_i),
        .penable_i           (penable_i),
        .paddr_i             (paddr_i),
        .pwrite_i            (pwrite_i),
        .pwdata_i            (pwdata_i),
        .prdata_o            (prdata_o),
        .pready_o            (pready_o),
        .spi_clk_div_vld_o   (spi_clk_div_vld),
        .spi_clk_div_o       (spi_clk_div),
        .eot_i               (eot),                 // end of transmit/receive
        .stream_data_tx_o    (stream_data_tx),      // tx data stream input
        .stream_data_tx_vld_o(stream_data_tx_vld),  // tx data stream valid
        .stream_data_tx_rdy_i(stream_data_tx_rdy),  // tx data stream teady
        .stream_data_rx_i    (spi_stream_rx),       // rx data stream output
        .stream_data_rx_vld_i(spi_stream_rx_vld),   // rx data stream valid
        .stream_data_rx_rdy_o(spi_stream_rx_rdy)    // rx data stream ready
    );
endmodule
