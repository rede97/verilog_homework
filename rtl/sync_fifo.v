module sync_fifo #(
    //common module
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 8,
    parameter CNT_WIDTH  = $clog2(DATA_DEPTH)
) (
    // system and reset
    input  wire                  clk_i,
    input  wire                  rstn_i,
    // write interface
    input  wire                  wr_en_i,
    input  wire [DATA_WIDTH-1:0] wr_data_i,
    // read interface
    input  wire                  rd_en_i,
    output reg                   rd_data_valid_o,
    output reg  [DATA_WIDTH-1:0] rd_data_o,
    // flags
    output wire                  empty_o,
    output wire                  full_o,
    output reg  [   CNT_WIDTH:0] elem_cnt_o
);
    reg  [ CNT_WIDTH-1:0] wr_ptr;
    reg  [ CNT_WIDTH-1:0] rd_ptr;
    reg  [DATA_WIDTH-1:0] ram      [0:DATA_DEPTH-1];
    wire                  wr_valid;
    wire                  rd_valid;

    assign full_o   = elem_cnt_o == DATA_DEPTH;
    assign empty_o  = elem_cnt_o == 0;

    assign wr_valid = wr_en_i & (!full_o);
    assign rd_valid = rd_en_i & (!empty_o);

    // Elements counter
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            elem_cnt_o <= 'b0;
        end else begin
            if (rd_valid && wr_valid) begin
                elem_cnt_o <= elem_cnt_o;
            end else if (rd_valid) begin
                elem_cnt_o <= elem_cnt_o - 1;
            end else if (wr_valid) begin
                elem_cnt_o <= elem_cnt_o + 1;
            end else begin
                elem_cnt_o <= elem_cnt_o;
            end
        end
    end

    // Generate data output valid
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rd_data_valid_o <= 1'b0;
        end else begin
            rd_data_valid_o <= rd_valid;
        end
    end

    // Update data
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rd_data_o <= 'b0;
        end else begin
            if (rd_valid) begin
                rd_data_o <= ram[rd_ptr];
            end else begin
                rd_data_o <= 'hdeadbeaf;
            end
        end
    end

    // Read pointer
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rd_ptr <= 'd0;
        end else begin
            if (rd_valid) begin
                rd_ptr <= rd_ptr + 1;
            end else begin
                rd_ptr <= rd_ptr;
            end
        end
    end

    // Write data to ram
    integer i;
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            for (i = 0; i < DATA_DEPTH; i = i + 1) begin
                ram[i] <= 'd0;
            end
        end else begin
            if (wr_valid) begin
                ram[wr_ptr] <= wr_data_i;
            end
        end
    end

    // Write pointer
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            wr_ptr <= 'd0;
        end else begin
            if (wr_valid) begin
                wr_ptr <= wr_ptr + 1;
            end else begin
                wr_ptr <= wr_ptr;
            end
        end
    end

endmodule
