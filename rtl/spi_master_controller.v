module spi_master_controller (
    input  wire        clk_i,                 // system clock
    input  wire        rst_n_i,               // system reset
    input  wire [15:0] spi_clk_div_i,         // spi clock divider
    input  wire        spi_clk_div_vld_i,     // spi clock divider input valid
    input  wire [31:0] stream_data_tx_i,      // tx data stream input
    input  wire        stream_data_tx_vld_i,  // tx data stream valid
    output wire        stream_data_tx_rdy_o,  // tx data stream teady
    output wire [31:0] stream_data_rx_o,      // rx data stream output
    output wire        stream_data_rx_vld_o,  // rx data stream valid
    input  wire        stream_data_rx_rdy_i,  // rx data stream ready
    output wire        spi_clk_o,             // SPI CLK
    output reg         spi_cs_n_o,            // SPI CS
    output wire        spi_sdo_o,             // SPI MOSI
    input  wire        spi_sdi_i,             // SPI MISO
    output reg         eot_o                  // end of transmit
);
    localparam ReadReq = 4'b1010, WriteReq = 4'b1011;
    localparam IDLE = 3'd0, CMD = 1, ADDR = 2, DUMMY = 3, TX = 4, RX = 5, EOT = 6;
    reg  [ 2:0] state;
    reg  [ 2:0] state_next;
    wire        state_is_idle;
    wire        state_is_cmd;
    wire        state_is_addr;
    wire        state_is_dummy;
    wire        state_is_tx;
    wire        state_is_rx;
    wire        state_is_eot;
    wire        state_go_idle;
    wire        state_go_cmd;
    wire        state_go_addr;
    wire        state_go_dummy;
    wire        state_go_tx;
    wire        state_go_rx;
    wire        state_go_eot;
    // SPI clock and enable
    reg         spi_clk_en;
    wire        spi_clk_rise_edge;
    wire        spi_clk_fall_edge;
    reg         spi_tx_en;
    reg         spi_rx_en;
    // ====== reuquest ======
    reg  [ 3:0] cmd;  // command
    reg  [ 3:0] addr;  // address
    reg  [ 7:0] wr_rd_len;  // write/read length
    reg  [15:0] wr_data;  // write data
    // ====== reuquest ======
    reg  [31:0] tx_data;
    reg         tx_data_vld;
    wire        tx_data_rdy;
    reg  [15:0] tx_len;
    reg         tx_len_vld;
    reg  [15:0] rx_len;
    reg         rx_len_vld;
    reg         rx_wait;
    wire        tx_done;
    wire        rx_done;
    wire        spi_rd_seq;  // flag: spi read
    wire        spi_wr_seq;  // flag: spi write
    // DUMMY counter
    reg  [ 7:0] dummy_cnt;
    wire        dummy_cnt_is_2;  // flag: dummy counter equal 2

    assign spi_rd_seq     = cmd == ReadReq;
    assign spi_wr_seq     = cmd == WriteReq;

    assign dummy_cnt_is_2 = dummy_cnt == 2;

    assign state_is_idle  = state == IDLE;
    assign state_is_cmd   = state == CMD;
    assign state_is_addr  = state == ADDR;
    assign state_is_dummy = state == DUMMY;
    assign state_is_tx    = state == TX;
    assign state_is_rx    = state == RX;
    assign state_is_eot   = state == EOT;
    assign state_go_cmd   = state_is_idle & stream_data_tx_vld_i & (spi_rd_seq | spi_wr_seq);
    assign state_go_addr  = state_is_cmd & tx_done;
    assign state_go_dummy = state_is_addr & tx_done;
    assign state_go_rx    = state_is_dummy & dummy_cnt_is_2 & spi_rd_seq;
    assign state_go_tx    = state_is_dummy & dummy_cnt_is_2 & spi_wr_seq;
    assign state_go_eot   = (state_is_rx & rx_wait & spi_clk_fall_edge) | (state_is_tx & tx_done);
    assign state_go_idle  = state_is_eot;

    spi_clkgen #(
        .CNT_WIDTH(16)
    ) clk_gen (
        .clk_i            (clk_i),
        .rst_n_i          (rst_n_i),
        .spi_clk_en_i     (spi_clk_en),
        .spi_clk_div_i    (spi_clk_div_i),
        .spi_clk_div_vld_i(spi_clk_div_vld_i),
        .spi_clk_o        (spi_clk_o),
        .spi_fall_edge_o  (spi_clk_fall_edge),
        .spi_rise_edge_o  (spi_clk_rise_edge)
    );

    spi_tx spi_transfer (
        .clk_i               (clk_i),
        .rst_n_i             (rst_n_i),
        .en_i                (spi_tx_en),
        .tx_edge_i           (spi_clk_fall_edge),
        .tx_done_o           (tx_done),
        .sdo                 (spi_sdo_o),
        // SPI TX len input
        .tx_bits_len_i       (tx_len),
        .tx_bits_len_update_i(tx_len_vld),
        .tx_data_i           (tx_data),
        .tx_data_vld_i       (tx_data_vld),
        .tx_data_rdy_o       (tx_data_rdy)
    );

    spi_rx spi_receiver (
        .clk_i               (clk_i),
        .rst_n_i             (rst_n_i),
        .en_i                (spi_rx_en),
        .rx_edge_i           (spi_clk_rise_edge),
        .rx_done_o           (rx_done),
        .sdi                 (spi_sdi_i),
        .rx_bits_len_i       (rx_len),
        .rx_bits_len_update_i(rx_len_vld),
        .rx_data_o           (stream_data_rx_o),
        .rx_data_vld_o       (stream_data_rx_vld_o),
        .rx_data_rdy_i       (stream_data_rx_rdy_i)
    );

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            {cmd, addr, wr_rd_len, wr_data} <= 32'h0;
        end else begin
            if (eot_o) begin
                {cmd, addr, wr_rd_len, wr_data} <= 32'h0;
            end else if ((state == IDLE) && stream_data_tx_vld_i) begin
                {cmd, addr, wr_rd_len, wr_data} <= stream_data_tx_i;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

    always @(*) begin
        if (state_go_cmd) begin
            state_next = CMD;
        end else if (state_go_addr) begin
            state_next = ADDR;
        end else if (state_go_dummy) begin
            state_next = DUMMY;
        end else if (state_go_rx) begin
            state_next = RX;
        end else if (state_go_tx) begin
            state_next = TX;
        end else if (state_go_eot) begin
            state_next = EOT;
        end else if (state_go_idle) begin
            state_next = IDLE;
        end else begin
            state_next = state;
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            spi_clk_en <= 1'b0;
        end else begin
            if (state_go_cmd) begin
                spi_clk_en <= 1'b1;
            end else if (state_go_eot) begin
                spi_clk_en <= 1'b0;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            dummy_cnt <= 8'd0;
        end else begin
            if (state_go_dummy) begin
                dummy_cnt <= 8'd0;
            end else if (state_is_dummy && spi_clk_fall_edge) begin
                dummy_cnt <= dummy_cnt + 8'd1;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            spi_tx_en   <= 1'b0;
            tx_len      <= 16'h0;
            tx_len_vld  <= 1'b0;
            tx_data     <= 32'b0;
            tx_data_vld <= 1'b0;
        end else begin
            if (state_go_dummy || state_go_eot || state_go_idle) begin
                spi_tx_en   <= 1'b0;
                tx_len      <= 16'h0;
                tx_len_vld  <= 1'b0;
                tx_data     <= 32'h0;
                tx_data_vld <= 1'b1;
            end else if (state_go_cmd) begin
                spi_tx_en   <= 1'b1;
                tx_len      <= 16'h4;
                tx_len_vld  <= 1'b1;
                tx_data     <= {cmd, 28'h0};
                tx_data_vld <= 1'b1;
            end else if (state_go_addr) begin
                spi_tx_en   <= 1'b1;
                tx_len      <= 16'h4;
                tx_len_vld  <= 1'b1;
                tx_data     <= {addr, 28'h0};
                tx_data_vld <= 1'b1;
            end else if (state_go_tx) begin
                spi_tx_en   <= 1'b1;
                tx_len      <= wr_rd_len;
                tx_len_vld  <= 1'b1;
                tx_data     <= {wr_data, 16'h0};
                tx_data_vld <= 1'b1;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            spi_rx_en  <= 1'b0;
            rx_len     <= 16'h0;
            rx_len_vld <= 1'b0;
        end else begin
            if (state_go_eot) begin
                spi_rx_en  <= 1'b0;
                rx_len     <= 16'h0;
                rx_len_vld <= 1'b0;
            end else if (state_go_rx) begin
                spi_rx_en  <= 1'b1;
                rx_len     <= wr_rd_len;
                rx_len_vld <= 1'b1;
            end
        end
    end

    // pending rx state until spi_clk_fall_edge
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_wait <= 1'b0;
        end else begin
            if (spi_clk_fall_edge) begin
                rx_wait <= 1'b0;
            end else if (rx_done) begin
                rx_wait <= 1'b1;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            spi_cs_n_o <= 1'b1;
        end else begin
            if (state_go_cmd) begin
                spi_cs_n_o <= 1'b0;
            end else if (state_go_eot) begin
                spi_cs_n_o <= 1'b1;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            eot_o <= 1'b0;
        end else begin
            eot_o <= state_go_eot;
        end
    end

    assign stream_data_tx_rdy_o = state_is_idle;

endmodule
