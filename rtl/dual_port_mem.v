module dual_port_mem #(
    parameter DATA_WIDTH = 8,
    parameter DATA_DEPTH = 32,
    parameter ADDR_WIDTH = $clog2(DATA_DEPTH)
) (
    input  wire                  rstn_i,     //system reset
    // read interface
    input  wire                  rd_clk_i,
    input  wire [ADDR_WIDTH-1:0] rd_addr_i,
    output reg  [DATA_DEPTH-1:0] rd_data_o,
    // write interface
    input  wire                  wr_clk_i,
    input  wire                  wr_en_i,
    input  wire                  wr_en_n_i,
    input  wire [ADDR_WIDTH-1:0] wr_addr_i,
    input  wire [DATA_DEPTH-1:0] wr_data_i
);

    // memory array
    reg [DATA_WIDTH-1:0] mem[0:DATA_DEPTH-1];

    // read data from mem
    always @(posedge rd_clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rd_data_o <= 'h0;
        end else begin
            rd_data_o <= mem[rd_addr_i];
        end
    end

    // write data to mem
    integer i;
    always @(posedge wr_clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            for (i = 0; i < DATA_DEPTH; i = i + 1) begin
                mem[i] <= 'h0;
            end
        end else begin
            if (wr_en_i && !wr_en_n_i) begin
                mem[wr_addr_i] <= wr_data_i;
            end
        end
    end
endmodule
