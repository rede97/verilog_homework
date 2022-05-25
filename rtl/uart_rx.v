module uart_rx (
    input  wire        clk_i,
    input  wire        rst_n_i,
    // CONFIG
    input  wire        cfg_en_i,         // config: enable
    input  wire [11:0] cfg_div_i,        // config: clock div prescaler
    input  wire        cfg_parity_en_i,  // config: parity check
    input  wire [ 1:0] cfg_bits_i,       // config: bits 5,6,7,8
    // RX IF
    input  wire        rx_i,
    // RX stream
    input  wire        rx_rdy_i,
    output reg         rx_vld_o,
    output reg  [ 7:0] rx_data_o
);

    localparam [2:0] IDLE = 3'd0, START = 3'd1, DATA = 3'd2, PARITY = 3'd3, STOP = 3'd4;
    reg  [2:0] state;
    reg  [2:0] state_next;
    reg  [2:0] rx_data_cnt;

    reg        parity;
    reg        rx_busy;
    wire       bit_half_done;

    wire       cfg_bit_5;
    wire       cfg_bit_6;
    wire       cfg_bit_7;
    wire       cfg_bit_8;
    wire [3:0] rx_data_cnt_next;
    wire [3:0] rx_data_bits;
    wire [3:0] rx_data_bit_next_7_4;
    wire       state_is_START;
    wire       state_is_DATA;


    assign state_is_START = state == START;
    // how many bit have to send
    assign rx_data_bits = cfg_bits_i + 4'd5;
    // tx data finish flag
    assign rx_data_cnt_next = rx_data_cnt + 4'd1;
    assign rx_data_done = (rx_data_cnt_next == rx_data_bits) && bit_half_done;
    assign cfg_bit_5 = cfg_bits_i == 0;
    assign cfg_bit_6 = cfg_bits_i == 1;
    assign cfg_bit_7 = cfg_bits_i == 2;
    assign cfg_bit_8 = cfg_bits_i == 3;
    // next data
    assign rx_data_bit_next_7_4 = {
        cfg_bit_8 ? rx_i : 1'b0,
        cfg_bit_7 ? rx_i : rx_data_o[7],
        cfg_bit_6 ? rx_i : rx_data_o[6],
        cfg_bit_5 ? rx_i : rx_data_o[5]
    };

    gen_baudrate gen_baud (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .gen_en_i(rx_busy),
        .cfg_div_i(cfg_div_i),
        .bit_done_o(),
        .bit_half_done_o(bit_half_done)
    );

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            if (cfg_en_i) begin
                state <= state_next;
            end else begin
                state <= IDLE;
            end
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (!rx_i) begin
                    state_next = START;
                end else begin
                    state_next = state;

                end
            end
            START: begin
                if (bit_half_done) begin
                    if (rx_i) begin
                        state_next = IDLE;
                    end else begin
                        state_next = DATA;
                    end
                end else begin
                    state_next = state;
                end
            end
            DATA: begin
                if (rx_data_done) begin
                    if (cfg_parity_en_i) begin
                        state_next = PARITY;
                    end else begin
                        state_next = STOP;
                    end
                end else begin
                    state_next = state;
                end
            end
            PARITY: begin
                if (bit_half_done) begin
                    state_next = STOP;
                end else begin
                    state_next = state;
                end
            end
            STOP: begin
                if (bit_half_done) begin
                    state_next = IDLE;
                end else begin
                    state_next = state;
                end
            end
            default: begin
                state_next = IDLE;
            end
        endcase
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_data_cnt <= 3'd0;
            rx_data_o   <= 8'h0;
        end else begin
            if (state == DATA) begin
                if (bit_half_done) begin
                    rx_data_o   <= {rx_data_bit_next_7_4, rx_data_o[4:1]};
                    rx_data_cnt <= rx_data_cnt_next;
                end
            end else if (state_is_START) begin
                rx_data_o   <= 8'h0;
                rx_data_cnt <= 8'h0;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_vld_o <= 1'b0;
        end else begin
            if (state == STOP && bit_half_done) begin
                rx_vld_o <= cfg_parity_en_i ? (!parity) : 1'b1;
            end else if (rx_rdy_i || state_is_START) begin
                rx_vld_o <= 1'b0;
            end
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            parity <= 8'h0;
        end else begin
            if (state == IDLE) begin
                parity <= 8'h0;
            end else if (bit_half_done) begin
                if (state == DATA || state == PARITY) begin
                    // if data is correct, the parity should be clear after PARITY-STATE
                    parity <= parity ^ rx_i;
                end
            end
        end
    end

    // Update rx_busy flag
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            rx_busy <= 1'b0;
        end else begin
            rx_busy <= (state_next != IDLE);
        end
    end


endmodule
