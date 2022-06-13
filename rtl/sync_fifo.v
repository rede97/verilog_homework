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
    output wire                  wr_rdy_o,
    input  wire                  wr_vld_i,
    input  wire [DATA_WIDTH-1:0] wr_data_i,
    // read interface
    input  wire                  rd_rdy_i,
    output reg                   rd_vld_o,
    output reg  [DATA_WIDTH-1:0] rd_data_o,
    // flags
    output wire                  full_o,
    output wire                  empty_o,
    output wire [   CNT_WIDTH:0] elem_cnt_o
);
    reg  [ CNT_WIDTH-1:0] wr_ptr;
    reg  [ CNT_WIDTH-1:0] rd_ptr;
    reg  [   CNT_WIDTH:0] elem_cnt;
    reg  [DATA_WIDTH-1:0] ram        [0:DATA_DEPTH-1];
    wire                  wr_valid;
    wire                  rd_valid;
    wire                  rd_preread;
    wire                  empty;
    wire                  full;

    assign elem_cnt_o = elem_cnt;
    assign full       = elem_cnt == DATA_DEPTH;
    assign empty      = elem_cnt == 0;
    assign full_o     = full;
    assign empty_o    = !rd_vld_o && empty;

    assign wr_rdy_o   = !full;
    assign wr_valid   = wr_vld_i && wr_rdy_o;
    assign rd_preread = !rd_vld_o || rd_rdy_i;
    assign rd_valid   = rd_preread && (!empty);

    // Elements counter
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            elem_cnt <= 'b0;
        end else begin
            if (rd_valid && wr_valid) begin
                elem_cnt <= elem_cnt;
            end else if (rd_valid) begin
                elem_cnt <= elem_cnt - 1;
            end else if (wr_valid) begin
                elem_cnt <= elem_cnt + 1;
            end else begin
                elem_cnt <= elem_cnt;
            end
        end
    end

    // Generate data output valid
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rd_vld_o <= 1'b0;
        end else begin
            if (rd_preread) begin
                rd_vld_o <= !empty;
            end
        end
    end

    // Update data
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            rd_data_o <= 'b0;
        end else begin
            if (rd_preread) begin
                rd_data_o <= empty ? 'd0 : ram[rd_ptr];
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
