module gen_baudrate (
    input  wire        clk_i,           // system clock input
    input  wire        rst_n_i,         // system reset input
    input  wire        gen_en_i,        // generate baudrate enable
    input  wire [11:0] cfg_div_i,       // config: divder prescaler
    output wire        bit_done_o,      // bit done
    output wire        bit_half_done_o  // bit-halt dont
);

    reg [11:0] baud_counter;
    assign bit_done_o      = baud_counter == cfg_div_i;
    assign bit_half_done_o = baud_counter == cfg_div_i[11:1];

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            baud_counter <= 12'h0;
        end else begin
            if (!gen_en_i || bit_done_o) begin
                baud_counter <= 12'h0;
            end else begin
                baud_counter <= baud_counter + 1;
            end
        end
    end

endmodule
