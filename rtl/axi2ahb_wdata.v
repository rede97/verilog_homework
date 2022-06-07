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
    output wire [      AXI_DATA_WIDTH-1:0] HWDATA,
    input  wire                            HREADY,
    // CTRL interface
    input  wire [        AXI_ID_WIDTH-1:0] cmd_id_i,
    output wire                            ctrl_wdata_last_o,
    input  wire                            ctrl_wdata_valid_i,
    output wire                            ctrl_wdata_ready_o
);
    assign HWDATA             = WDATA;
    assign WREADY             = ctrl_wdata_valid_i;
    assign ctrl_wdata_ready_o = WVALID;
    assign ctrl_wdata_last_o  = WLAST;

    sync_fifo #(
        .DATA_WIDTH(AXI_ID_WIDTH + 2),
        .DATA_DEPTH(8)
    ) wdata_resp_fifo (
        .clk_i(ACLK),
        .rstn_i(ARESETN),
        .wr_rdy_o(),
        .wr_vld_i(ctrl_wdata_valid_i & WLAST),
        .wr_data_i({cmd_id_i, 2'b00}),
        .rd_rdy_i(BREADY),
        .rd_vld_o(BVALID),
        .rd_data_o({BID, BRESP})
    );

    // always @(posedge ACLK or negedge ARESETN) begin
    //     if (!ARESETN) begin
    //         ctrl_cmd_ready_o <= 1'b0;
    //     end else begin
    //         ctrl_cmd_ready_o <= ctrl_working_flag & ctrl_go_idle;
    //     end
    // end

endmodule
