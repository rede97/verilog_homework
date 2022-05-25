module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 8
) (
    // system reset
    input  wire                  rstn_i,
    // write interface
    input  wire                  wr_clk_i,
    input  wire                  wr_en_i,
    input  wire [DATA_WIDTH-1:0] wr_data_i,
    output wire                  full_o,
    // read Interface
    input  wire                  rd_clk_i,
    input  wire                  rd_en_i,
    output wire [DATA_WIDTH-1:0] rd_data_o,
    output wire                  empty_o
);
    localparam CNT_WIDTH = $clog2(FIFO_DEPTH);

    wire [CNT_WIDTH-1:0] wr_addr, rd_addr;
    wire [CNT_WIDTH:0] wr_ptr_gray, rd_ptr_gray;
    wire [CNT_WIDTH:0] wr_ptr_gray_synced, rd_ptr_gray_synced;

    dual_port_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(FIFO_DEPTH)
    ) dual_port_mem_u0 (
        .rstn_i   (rstn_i),
        // read interface
        .rd_clk_i (rd_clk_i),
        .rd_addr_i(rd_addr),
        .rd_data_o(rd_data_o),
        // write interface
        .wr_clk_i (wr_clk_i),
        .wr_en_i  (wr_en_i),
        .wr_en_n_i(full_o),
        .wr_addr_i(wr_addr),
        .wr_data_i(wr_data_i)
    );


    // read counter
    counter_wrpper #(
        .CNT_WIDTH(CNT_WIDTH)
    ) rd_counter_u1 (
        .clk_i         (rd_clk_i),
        .rstn_i        (rstn_i),
        .cnt_en_i      (rd_en_i),
        .cnt_forbiden_i(empty_o),
        .addr_o        (rd_addr),
        .ptr_gray_o    (rd_ptr_gray)
    );

    // read empty logic
    rd_empty #(
        .WIDTH(CNT_WIDTH + 1)
    ) rd_empty_u2 (
        .rd_ptr_gray_i(rd_ptr_gray),
        .wr_ptr_gray_i(wr_ptr_gray_synced),
        .empty_o      (empty_o)
    );

    // write counter
    counter_wrpper #(
        .CNT_WIDTH(CNT_WIDTH)
    ) wr_counter_u3 (
        .clk_i         (wr_clk_i),
        .rstn_i        (rstn_i),
        .cnt_en_i      (wr_en_i),
        .cnt_forbiden_i(full_o),
        .addr_o        (wr_addr),
        .ptr_gray_o    (wr_ptr_gray)
    );

    // write full logic
    wr_full #(
        .WIDTH(CNT_WIDTH + 1)
    ) wr_full_u4 (
        .rd_ptr_gray_i(rd_ptr_gray_synced),
        .wr_ptr_gray_i(wr_ptr_gray),
        .full_o       (full_o)
    );

    // synchronizing rd_ptr_gray from read-clock-domain to write-clock-domain
    general_syncer #(
        .FISTR_EDGE(1),
        .LAST_EDGE(1),
        .MID_STAGE_NUM(0),
        .DATA_WIDTH(CNT_WIDTH + 1)
    ) rd_ptr_gray_syncer_u5 (
        .clk_i        (wr_clk_i),
        .rstn_i       (rstn_i),
        .data_unsync_i(rd_ptr_gray),
        .data_synced_o(rd_ptr_gray_synced)
    );

    // synchronizing wr_ptr_gray from write-clock-domain to read-clock-domain
    general_syncer #(
        .FISTR_EDGE(1),
        .LAST_EDGE(1),
        .MID_STAGE_NUM(0),
        .DATA_WIDTH(CNT_WIDTH + 1)
    ) wr_ptr_gray_syncer_u6 (
        .clk_i        (rd_clk_i),
        .rstn_i       (rstn_i),
        .data_unsync_i(wr_ptr_gray),
        .data_synced_o(wr_ptr_gray_synced)
    );

endmodule
