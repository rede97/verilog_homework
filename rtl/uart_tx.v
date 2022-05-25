module uart_tx (
    input  wire        clk_i,
    input  wire        rst_n_i,
    // CONFIG
    input  wire        cfg_en_i,         // config: enable
    input  wire [11:0] cfg_div_i,        // config: clock div prescaler
    input  wire [ 1:0] cfg_bits_i,       // config: bits 5,6,7,8
    input  wire        cfg_parity_en_i,  // config: parity check
    input  wire        cfg_stop_bits_i,  // config: stop bit enable, 2-bits stop bit
    // TX IF
    output reg         tx_o,
    output reg         tx_busy_o,
    // Tx stream
    input  wire [ 7:0] tx_data_i,
    input  wire        tx_vld_i,
    output reg         tx_rdy_o
);

    localparam [2:0] IDLE = 3'd0, START = 3'd1, DATA = 3'd2, PARITY = 3'd3, STOP = 3'd4;
    // state register
    reg  [2:0] state;
    reg  [2:0] state_next;
    // tx data and counter register
    reg  [2:0] tx_data_cnt;
    reg  [7:0] tx_data;
    // tx data odd paroty
    reg        parity;
    // stop flag register
    reg  [1:0] stop;
    // flags
    wire [3:0] tx_data_cnt_next;
    wire [3:0] tx_data_bits;
    wire       tx_data_done;
    wire       bit_done;
    wire       stop_done;
    wire       state_next_is_IDLE;

    // is current state is IDLE
    assign state_next_is_IDLE = state_next == IDLE;
    // next value of tx data counter
    assign tx_data_cnt_next = tx_data_cnt + 1;
    // how many bit have to send
    assign tx_data_bits = cfg_bits_i + 4'd5;
    // tx data finish flag
    assign tx_data_done = (tx_data_cnt_next == tx_data_bits) && bit_done;
    // double stop bit required when cfg_stop_bits_i was set
    assign stop_done = (!cfg_stop_bits_i || (cfg_stop_bits_i && stop[1])) && stop[0];

    gen_baudrate gen_baud (
        .clk_i(clk_i),
        .rst_n_i(rst_n_i),
        .gen_en_i(tx_busy_o),
        .cfg_div_i(cfg_div_i),
        .bit_done_o(bit_done),
        .bit_half_done_o()
    );

    // Update state
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

    // Generate next state
    always @(*) begin
        case (state)
            IDLE: begin
                if (tx_vld_i) begin
                    state_next = START;
                end else begin
                    state_next = state;
                end
            end
            START: begin
                if (bit_done) begin
                    state_next = DATA;
                end else begin
                    state_next = state;
                end
            end
            DATA: begin
                if (tx_data_done) begin
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
                if (bit_done) begin
                    state_next = STOP;
                end else begin
                    state_next = state;
                end
            end
            STOP: begin
                if (stop_done) begin
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

    // Update Tx output
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            tx_o <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_o <= 1'b1;
                end
                START: begin
                    tx_o <= 1'b0;
                end
                DATA: begin
                    tx_o <= tx_data[0];
                end
                PARITY: begin
                    tx_o <= parity;
                end
                STOP: begin
                    tx_o <= 1'b1;
                end
                default: begin
                    tx_o <= 1'b1;
                end
            endcase
        end
    end

    // Generate parity of data and counter of tx data
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            parity <= 1'b0;
            tx_data_cnt <= 3'd0;
        end else begin
            if (state == DATA) begin
                if (bit_done) begin
                    parity <= parity ^ tx_data[0];
                    tx_data_cnt <= tx_data_cnt_next;
                end
            end else if (state == START) begin
                parity <= 1'b0;
                tx_data_cnt <= 3'd0;
            end
        end
    end

    // Update Tx busy
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            tx_busy_o <= 1'b0;
        end else begin
            tx_busy_o <= !state_next_is_IDLE;
        end
    end

    // Update Tx ready
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            tx_rdy_o <= 1'b0;
        end else begin
            tx_rdy_o <= state == START && bit_done;
        end
    end

    // Generate TX data
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            tx_data <= 8'h0;
        end else begin
            if (bit_done) begin
                if (state == START) begin
                    tx_data <= tx_data_i;
                end else begin
                    tx_data <= {1'b0, tx_data[7:1]};
                end
            end
        end
    end

    // Generate stop flag
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            stop <= 2'b0;
        end else begin
            if (bit_done) begin
                stop[0] <= state == STOP;
                stop[1] <= stop[0];
            end
        end
    end

endmodule
