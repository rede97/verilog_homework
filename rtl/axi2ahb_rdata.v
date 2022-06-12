module axi2ahb_rdata #(
    parameter integer AXI_ID_WIDTH   = 1,
    parameter integer AXI_DATA_WIDTH = 32
) (
    input  wire                      ACLK,
    input  wire                      ARESETN,
    // AXI Read data channel
    output wire [  AXI_ID_WIDTH-1:0] RID,
    output wire [AXI_DATA_WIDTH-1:0] RDATA,
    output wire [               1:0] RRESP,
    output wire                      RLAST,
    output wire                      RVALID,
    input  wire                      RREADY,
    // AHB Read interface
    input  wire [AXI_DATA_WIDTH-1:0] HRDATA,
    input  wire                      HREADY,
    input  wire                      HRESP,
    // CTRL & CMD interface
    input  wire [  AXI_ID_WIDTH-1:0] cmd_id_i,
    input  wire                      cmd_error_i,
    output wire                      ctrl_rdata_ready_o,
    input  wire                      ctrl_rdata_last_i,
    input  wire                      ctrl_rdata_valid_i
);
    reg  error_flag;
    wire rdata_fifo_wr_valid;
    wire resp_error;
    assign resp_error = error_flag || HRESP;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            error_flag <= 1'b0;
        end else begin
            if (rdata_fifo_wr_valid) begin
                error_flag <= 1'b0;
            end else begin
                error_flag <= cmd_error_i || HRESP;
            end
        end
    end

    assign rdata_fifo_wr_valid = ctrl_rdata_valid_i && HREADY;
    sync_fifo #(
        .DATA_WIDTH(AXI_ID_WIDTH + AXI_DATA_WIDTH + 2 + 1),
        .DATA_DEPTH(32)
    ) rdata_fifo (
        .clk_i(ACLK),
        .rstn_i(ARESETN),
        .wr_rdy_o(ctrl_rdata_ready_o),
        .wr_vld_i(rdata_fifo_wr_valid),
        .wr_data_i({cmd_id_i, HRDATA, resp_error ? 2'b10 : 2'b00, ctrl_rdata_last_i}),
        .rd_rdy_i(RREADY),
        .rd_vld_o(RVALID),
        .rd_data_o({RID, RDATA, RRESP, RLAST})
    );

endmodule
