module spi_tx (
    input  wire        clk_i,                 // system clock
    input  wire        rst_n_i,               // system reset
    // SPI control
    input  wire        en_i,
    input  wire        tx_edge_i,             // SPI clock edge flag
    output wire        tx_done_o,             // SPI Tx finish
    output wire        sdo,                   // SPI Tx output
    // SPI TX len input
    input  wire [15:0] tx_bits_len_i,
    input  wire        tx_bits_len_update_i,
    // SPI TX data input
    input  wire [31:0] tx_data_i,
    input  wire        tx_data_vld_i,
    output wire        tx_data_rdy_o
);

    localparam IDLE = 1'b0, TRANSMIT = 1'b1;

    reg         state;  // current state
    reg  [15:0] tx_bits_len;  // totally length
    reg  [31:0] tx_data;  // data register
    reg  [15:0] tx_counter;  // transfer counter
    wire [15:0] tx_counter_next;  // transfer counter next
    wire        state_next;  // next state
    wire        state_go_idle;  // next state is IDLE
    wire        state_go_transmit;  // next state is TRANSMIT
    wire        state_is_idle;  // current state is IDLE
    wire        state_is_transmit;  // current state is TRANSMIT
    wire        word_done;  // 32bit(4 bytes) was transfered
    wire        tx_active;  // transfer active

    assign tx_counter_next   = tx_counter + 16'h1;
    assign sdo               = tx_data[31];
    assign state_is_idle     = state == IDLE;
    assign state_is_transmit = state == TRANSMIT;
    assign tx_data_rdy_o     = state_is_idle;
    assign word_done         = (tx_counter[4:0] == 5'b11111) && tx_edge_i;
    assign tx_done_o         = (tx_counter_next == tx_bits_len) && tx_edge_i;
    assign tx_active         = state_is_transmit && tx_edge_i && (!tx_done_o);
    assign state_go_idle     = state_is_transmit && (word_done && !tx_data_vld_i) || tx_done_o;
    assign state_go_transmit = state_is_idle && en_i && tx_data_vld_i;
    assign state_next        = state_go_transmit ? TRANSMIT : (state_go_idle ? IDLE : state);

    // update transfer length
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            tx_bits_len <= 16'h0;
        end else begin
            if (tx_bits_len_update_i) begin
                tx_bits_len <= tx_bits_len_i;
            end
        end
    end

    // update transfer counter
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            tx_counter <= 16'h0;
        end else begin
            if (state_go_transmit) begin
                tx_counter <= 16'h0;
            end else if (tx_active) begin
                tx_counter <= tx_counter_next;
            end
        end
    end


    // data output
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            tx_data <= 32'h0;
        end else begin
            if (state_go_transmit || (word_done && tx_data_vld_i)) begin
                tx_data <= tx_data_i;
            end else if (tx_active) begin
                tx_data <= {tx_data[30:0], tx_data[31]};
            end
        end
    end

    // update state
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

endmodule
