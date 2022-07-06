module axi_w_misrouting #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Width of S_AXI data bus
    parameter integer AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8,
    // AXI_ID_WIDTH + AXI_ADDR_WIDTH + S_AXI_AWLEN + S_AXI_AWSIZE + S_AXI_AWBURST
    parameter integer AXI_AWCHAN_WIDTH = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2,
    // AXI_DATA_WIDTH + S_AXI_WSTRB + S_AXI_WLAST
    parameter integer AXI_WDCHAN_WIDTH = AXI_DATA_WIDTH + (AXI_DATA_WIDTH / 8) + 1,
    // AXI_ID_WIDTH + S_AXI_BRESP
    parameter integer AXI_WBCHAN_WIDTH = AXI_ID_WIDTH + 2
) (
    // Global Clock Signal
    input  wire                          ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input  wire                          ARESETN,
    // ==========================================================
    // Slave Write address channel
    // ==========================================================
    input  wire [AXI_AWCHAN_WIDTH-1 : 0] S_AXI_AWCH_i,
    input  wire                          S_AXI_AWCH_VALID_i,
    output wire                          S_AXI_AWCH_READY_o,
    // ==========================================================
    // Slave Write data channel
    // ==========================================================
    input  wire [AXI_WDCHAN_WIDTH-1 : 0] S_AXI_WCH_i,
    input  wire                          S_AXI_WCH_VALID_i,
    output wire                          S_AXI_WCH_READY_o,
    // ==========================================================
    // Slave Write response channel
    // ==========================================================
    output wire [AXI_WBCHAN_WIDTH-1 : 0] S_AXI_BCH_o,
    output wire                          S_AXI_BCH_VALID_o,
    input  wire                          S_AXI_BCH_READY_i
);
    wire [AXI_ID_WIDTH-1:0] AWID;
    wire WLAST;
    assign AWID = S_AXI_AWCH_i[AXI_AWCHAN_WIDTH-1:AXI_AWCHAN_WIDTH-1-AXI_ID_WIDTH];
    assign WLAST = S_AXI_WCH_VALID_i && S_AXI_WCH_i[0];
    assign S_AXI_BCH_o = {2'b11, AWID};

    assign S_AXI_BCH_VALID_o = S_AXI_AWCH_VALID_i && WLAST;
    assign S_AXI_WCH_READY_o = S_AXI_AWCH_VALID_i ? (WLAST ? S_AXI_BCH_READY_i : 1'b1) : 1'b0;
    assign S_AXI_AWCH_READY_o = S_AXI_BCH_VALID_o && S_AXI_BCH_READY_i;

endmodule
