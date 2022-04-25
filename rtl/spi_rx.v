module spi_rx (
    input  wire        clk_i,                 // system clock
    input  wire        rst_n_i,               // system reset
    // SPI control
    input  wire        en_i,                  // enable
    input  wire        sdi,                   // SPI Rx input
    output wire        rx_done_o,             // SPI Rx finish
    input  wire        rx_edge_i,             // SPI clock edge flag
    // SPI Rx len input
    input  wire [15:0] rx_bits_len_i,
    input  wire        rx_bits_len_update_i,
    // SPI Rx data output
    output wire [31:0] rx_data_o,
    output wire        rx_data_vld_o,
    input  wire        rx_data_rdy_i
);

    localparam IDLE = 0, RECEIVE = 1;

    reg         state;  // current state
    reg  [15:0] rx_bits_len;  // totally length
    reg  [31:0] rx_data;  // data register
    reg  [15:0] rx_counter;  // receive counter
    wire [15:0] rx_counter_next;  // receive counter next
    wire        state_next;  // next state
    wire        state_go_idle;  // next state is idle
    wire        state_go_receive;  // next state is receive
    wire        state_is_idle;  // current state is idle
    wire        state_is_receive;  // current state is receive
    wire        word_done;  //  32bit(4 bytes) was received
    wire        rx_active;  // receive active

    assign rx_counter_next  = rx_counter + 16'h1;
    assign rx_data_o        = rx_data;
    assign state_is_idle    = state == IDLE;
    assign state_is_receive = state == RECEIVE;
    assign rx_data_vld_o    = state_is_idle;
    assign word_done        = (rx_counter == 5'b11111) && rx_edge_i;
    assign rx_done_o        = (rx_counter_next == rx_bits_len) && rx_edge_i;
    assign rx_active        = state_is_receive && rx_edge_i;
    assign state_go_idle    = state_is_receive && (word_done && !rx_data_rdy_i) || rx_done_o;
    assign state_go_receive = state_is_idle && en_i && rx_data_rdy_i;
    assign state_next       = state_go_receive ? RECEIVE : (state_go_idle ? IDLE : state);

    // update receive length
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_bits_len <= 16'h0;
        end else begin
            if (rx_bits_len_update_i) begin
                rx_bits_len <= rx_bits_len_i;
            end
        end
    end

    // update receive counter
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_counter <= 16'h0;
        end else begin
            if (state_go_receive) begin
                rx_counter <= 16'h0;
            end else if (rx_active) begin
                rx_counter <= rx_counter_next;
            end
        end
    end

    // data input
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_data <= 32'h0;
        end else begin
            if (rx_active) begin
                rx_data <= {rx_data[30:0], sdi};
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
