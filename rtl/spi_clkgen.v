module spi_clkgen #(
    parameter CNT_WIDTH = 8
) (
    input  wire                 clk_i,
    input  wire                 rst_n_i,
    input  wire                 spi_clk_en_i,
    // SPI clock config
    input  wire [CNT_WIDTH-1:0] spi_clk_div_i,      // divier prescalar, DIV >= 1
    input  wire                 spi_clk_div_vld_i,
    // SPI clock output
    output reg                  spi_clk_o,          // SPI clock output
    output wire                 spi_fall_edge_o,
    output wire                 spi_rise_edge_o
);

    reg                  d_q;
    reg  [CNT_WIDTH-1:0] counter;
    wire [CNT_WIDTH-1:0] counter_next;  // next counter value
    wire                 counter_disable;  // flag: disable counter
    wire                 counter_full;  // flag: counter full

    assign counter_next    = counter + 'h1;
    assign counter_disable = !(spi_clk_en_i && spi_clk_div_vld_i);
    assign counter_full    = counter_next == spi_clk_div_i;
    assign spi_rise_edge_o = d_q & (~spi_clk_o);    // flag: rising edge
    assign spi_fall_edge_o = (~d_q) & spi_clk_o;    // flag: falling edge

    // clock divider counter
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            counter <= 1'b0;
        end else begin
            if (counter_full || counter_disable) begin
                counter <= 'h0;
            end else begin
                counter <= counter_next;
            end
        end
    end

    // invert internal SPI clock
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            d_q <= 1'b0;
        end else begin
            if (counter_disable) begin
                d_q <= 1'b0;
            end else if (counter_full) begin
                d_q <= ~d_q;
            end
        end
    end

    // update SPI clock output
    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            spi_clk_o <= 'h0;
        end else begin
            spi_clk_o <= d_q;
        end
    end

endmodule
