module fsm_seq_4bit (
    input  wire       clk_i,
    input  wire       rst_n_i,
    input  wire [3:0] data_i, // Data input
    output reg        found_o // Detected output
);

    // Define STATE
    localparam IDLE = 0, DETECTED_1 = 1, DETECTED_0 = 2, DETECTED_2 = 3, DETECTED_4 = 4;
    reg [2:0] state;  // Current state
    reg [2:0] state_next;  // Next state

    // Update state
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            state <= IDLE;
        end else begin
            state <= state_next;
        end
    end

    // Detecting data_i to generate next state
    // Seq: 1 -> 0 -> 2 -> 4
    always @(*) begin
        case (state)
            DETECTED_1:
            if (data_i == 4'd0) begin
                state_next = DETECTED_0;
            end else begin
                state_next = IDLE;
            end
            DETECTED_0:
            if (data_i == 4'd2) begin
                state_next = DETECTED_2;
            end else begin
                state_next = IDLE;
            end
            DETECTED_2:
            if (data_i == 4'd4) begin
                state_next = DETECTED_4;
            end else begin
                state_next = IDLE;
            end
            // IDLE, DETECTED_4 and something else
            default:
            if (data_i == 4'd1) begin
                state_next = DETECTED_1;
            end else begin
                state_next = IDLE;
            end
        endcase
    end

    // Generate found_o
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            found_o <= 1'b0;
        end else begin
            found_o <= (state == DETECTED_4);
        end
    end

endmodule
