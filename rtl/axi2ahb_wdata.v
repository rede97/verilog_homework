module axi2ahb_wdata #(
    parameter integer AXI_ID_WIDTH   = 1,
    parameter integer AXI_DATA_WIDTH = 32
) (
    input  wire                            ACLK,
    input  wire                            ARESETN,
    // AXI Write data channel
    input  wire [      AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [(AXI_DATA_WIDTH/8)-1 : 0] WSTRB,
    input  wire                            WLAST,
    input  wire                            WVALID,
    output wire                            WREADY,
    // AXI Response channel
    output wire [        AXI_ID_WIDTH-1:0] BID,
    output wire [                     1:0] BRESP,
    output wire                            BVALID,
    input  wire                            BREADY,
    // AHB Write interface
    output reg  [      AXI_DATA_WIDTH-1:0] HWDATA,
    input  wire                            HREADY,
    input  wire                            HRESP,
    // CTRL interface
    input  wire [        AXI_ID_WIDTH-1:0] cmd_id_i,
    input  wire                            cmd_error_i,
    output wire                            ctrl_wdata_last_o,
    input  wire                            ctrl_wdata_valid_i,
    output wire                            ctrl_wdata_ready_o
);
    wire [      AXI_DATA_WIDTH-1:0] wdata_fifo_wdata;
    wire [(AXI_DATA_WIDTH/8)-1 : 0] wdata_fifo_strb;
    wire                            wdata_fifo_last;
    wire                            wdata_fifo_valid;
    wire                            wdata_fifo_ready;


    reg                             error_flag;
    reg  [      AXI_DATA_WIDTH-1:0] buffer_WDATA;
    reg                             buffer_WLAST;
    reg                             resp_valid;
    wire                            resp_error;
    wire [    (AXI_DATA_WIDTH/8):0] expect_wstrb;

    assign wdata_fifo_ready   = ctrl_wdata_valid_i;
    assign ctrl_wdata_ready_o = wdata_fifo_valid;
    assign ctrl_wdata_last_o  = wdata_fifo_last;
    assign expect_wstrb       = ((1 << (AXI_DATA_WIDTH / 8)) - 'd1);
    assign resp_error         = error_flag || HRESP;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            error_flag <= 1'b0;
        end else begin
            if (resp_valid) begin
                error_flag <= 1'b0;
            end else begin
                error_flag <= cmd_error_i || HRESP || (wdata_fifo_valid && (wdata_fifo_strb != expect_wstrb));
            end
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            buffer_WDATA <= 'd0;
            HWDATA <= 'd0;
            buffer_WLAST <= 'b0;
            resp_valid <= 'b0;
        end else begin
            buffer_WDATA <= wdata_fifo_wdata;
            HWDATA <= buffer_WDATA;
            buffer_WLAST <= ctrl_wdata_valid_i & wdata_fifo_last;
            resp_valid <= buffer_WLAST;
        end
    end

    sync_fifo #(
        .DATA_WIDTH(AXI_ID_WIDTH + 2),
        .DATA_DEPTH(32)
    ) wdata_resp_fifo (
        .clk_i(ACLK),
        .rstn_i(ARESETN),
        .wr_rdy_o(),
        .wr_vld_i(resp_valid),
        .wr_data_i({cmd_id_i, resp_error ? 2'b10 : 2'b00}),
        .rd_rdy_i(BREADY),
        .rd_vld_o(BVALID),
        .rd_data_o({BID, BRESP}),
        .full_o(),
        .empty_o(),
        .elem_cnt_o()
    );

    sync_fifo #(
        .DATA_WIDTH({AXI_DATA_WIDTH + (AXI_DATA_WIDTH / 8) + 1}),
        .DATA_DEPTH(32)
    ) wdata_fifo (
        .clk_i(ACLK),
        .rstn_i(ARESETN),
        .wr_rdy_o(WREADY),
        .wr_vld_i(WVALID),
        .wr_data_i({WDATA, WSTRB, WLAST}),
        .rd_rdy_i(wdata_fifo_ready),
        .rd_vld_o(wdata_fifo_valid),
        .rd_data_o({wdata_fifo_wdata, wdata_fifo_strb, wdata_fifo_last}),
        .full_o(),
        .empty_o(),
        .elem_cnt_o()
    );

endmodule
