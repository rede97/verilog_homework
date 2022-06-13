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
    reg                         error_flag;
    reg  [  AXI_DATA_WIDTH-1:0] buffer_WDATA;
    reg                         buffer_WLAST;
    reg                         resp_valid;
    wire                        resp_error;
    wire [(AXI_DATA_WIDTH/8):0] expect_wstrb;

    assign WREADY             = ctrl_wdata_valid_i;
    assign ctrl_wdata_ready_o = WVALID;
    assign ctrl_wdata_last_o  = WLAST;
    assign expect_wstrb       = ((1 << (AXI_DATA_WIDTH / 8)) - 'd1);
    assign resp_error         = error_flag || HRESP;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            error_flag <= 1'b0;
        end else begin
            if (resp_valid) begin
                error_flag <= 1'b0;
            end else begin
                error_flag <= cmd_error_i || HRESP || (WVALID && (WSTRB != expect_wstrb));
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
            buffer_WDATA <= WDATA;
            HWDATA <= buffer_WDATA;
            buffer_WLAST <= ctrl_wdata_valid_i & WLAST;
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

endmodule
