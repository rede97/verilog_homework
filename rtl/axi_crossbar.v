module axi_crossbar #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Width of S_AXI data bus
    parameter integer AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer AXI_ADDR_WIDTH = 32,
    // Slave interface number
    parameter integer AXI_SLAVE_PORT = 1,
    // Master interface number
    parameter integer AXI_MASTER_PORT = 1,
    // AXI_ID_WIDTH + AXI_ADDR_WIDTH + S_AXI_AWLEN + S_AXI_AWSIZE + S_AXI_AWBURST
    parameter integer AXI_AWCHAN_WIDTH = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2,
    // AXI_DATA_WIDTH + S_AXI_WSTRB + S_AXI_WLAST
    parameter integer AXI_WDCHAN_WIDTH = AXI_DATA_WIDTH + (AXI_DATA_WIDTH / 8) + 1,
    // AXI_ID_WIDTH + S_AXI_BRESP
    parameter integer AXI_WBCHAN_WIDTH = AXI_ID_WIDTH + 2,
    // AXI_ID_WIDTH + AXI_ADDR_WIDTH + S_AXI_ARLEN + S_AXI_ARSIZE + S_AXI_ARBURST
    parameter integer AXI_ARCHAN_WIDTH = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2,
    // AXI_ID_WIDTH + AXI_DATA_WIDTH + S_AXI_RRESP + S_AXI_RLAST
    parameter integer AXI_RDCHANB_WIDTH = AXI_ID_WIDTH + AXI_DATA_WIDTH + 2 + 1
) (
    // Global Clock Signal
    input  wire                            ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input  wire                            ARESETN,
    // ==========================================================
    // Slave Write address channel
    // ==========================================================
    input  wire [      AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
    input  wire [    AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input  wire [                   7 : 0] S_AXI_AWLEN,
    input  wire [                   2 : 0] S_AXI_AWSIZE,
    input  wire [                   1 : 0] S_AXI_AWBURST,
    input  wire                            S_AXI_AWVALID,
    output wire                            S_AXI_AWREADY,
    // ==========================================================
    // Slave Write data channel
    // ==========================================================
    input  wire [    AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input  wire [(AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input  wire                            S_AXI_WLAST,
    input  wire                            S_AXI_WVALID,
    output wire                            S_AXI_WREADY,
    // ==========================================================
    // Slave Write response channel
    // ==========================================================
    output wire [      AXI_ID_WIDTH-1 : 0] S_AXI_BID,
    output wire [                   1 : 0] S_AXI_BRESP,
    output wire                            S_AXI_BVALID,
    input  wire                            S_AXI_BREADY,
    // ==========================================================
    // Slave Read address channel
    // ==========================================================
    input  wire [      AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
    input  wire [    AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input  wire [                   7 : 0] S_AXI_ARLEN,
    input  wire [                   2 : 0] S_AXI_ARSIZE,
    input  wire [                   1 : 0] S_AXI_ARBURST,
    input  wire                            S_AXI_ARVALID,
    output wire                            S_AXI_ARREADY,
    // ==========================================================
    // Slave Read data channel
    // ==========================================================
    output wire [      AXI_ID_WIDTH-1 : 0] S_AXI_RID,
    output wire [    AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [                   1 : 0] S_AXI_RRESP,
    output wire                            S_AXI_RLAST,
    output wire                            S_AXI_RVALID,
    input  wire                            S_AXI_RREADY,
    // ==========================================================
    // Master Write address channel
    // ==========================================================
    output wire [      AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
    output wire [    AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
    output wire [                   7 : 0] M_AXI_AWLEN,
    output wire [                   2 : 0] M_AXI_AWSIZE,
    output wire [                   1 : 0] M_AXI_AWBURST,
    output wire                            M_AXI_AWVALID,
    input  wire                            M_AXI_AWREADY,
    // ==========================================================
    // Master Write data channel
    // ==========================================================
    output wire [    AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
    output wire [(AXI_DATA_WIDTH/8)-1 : 0] M_AXI_WSTRB,
    output wire                            M_AXI_WLAST,
    output wire                            M_AXI_WVALID,
    input  wire                            M_AXI_WREADY,
    // ==========================================================
    // Master Write response channel
    // ==========================================================
    input  wire [      AXI_ID_WIDTH-1 : 0] M_AXI_BID,
    input  wire [                   1 : 0] M_AXI_BRESP,
    input  wire                            M_AXI_BVALID,
    output wire                            M_AXI_BREADY,
    // ==========================================================
    // Master Read address channel
    // ==========================================================
    output wire [      AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
    output wire [    AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
    output wire [                   7 : 0] M_AXI_ARLEN,
    output wire [                   2 : 0] M_AXI_ARSIZE,
    output wire [                   1 : 0] M_AXI_ARBURST,
    output wire                            M_AXI_ARVALID,
    input  wire                            M_AXI_ARREADY,
    // ==========================================================
    // Master Read data channel
    // ==========================================================
    input  wire [      AXI_ID_WIDTH-1 : 0] M_AXI_RID,
    input  wire [    AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
    input  wire [                   1 : 0] M_AXI_RRESP,
    input  wire                            M_AXI_RLAST,
    input  wire                            M_AXI_RVALID,
    output wire                            M_AXI_RREADY
);

    wire [ AXI_AWCHAN_WIDTH-1:0] LINK_AXI_AWCH;
    wire                         LINK_AXI_AWCH_VALID;
    wire                         LINK_AXI_AWCH_READY;
    wire [ AXI_WDCHAN_WIDTH-1:0] LINK_AXI_WCH;
    wire                         LINK_AXI_WCH_VALID;
    wire                         LINK_AXI_WCH_READY;
    wire [ AXI_WBCHAN_WIDTH-1:0] LINK_AXI_BCH;
    wire                         LINK_AXI_BCH_VALID;
    wire                         LINK_AXI_BCH_READY;
    wire [ AXI_ARCHAN_WIDTH-1:0] LINK_AXI_ARCH;
    wire                         LINK_AXI_ARCH_VALID;
    wire                         LINK_AXI_ARCH_READY;
    wire [AXI_RDCHANB_WIDTH-1:0] LINK_AXI_RCH;
    wire                         LINK_AXI_RCH_VALID;
    wire                         LINK_AXI_RCH_READY;

    axi_master_router #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_SLAVE_PORT(AXI_SLAVE_PORT)
    ) axi_master_router_0 (
        .ACLK              (ACLK),
        .ARESETN           (ARESETN),
        .S_AXI_AWID        (S_AXI_AWID),
        .S_AXI_AWADDR      (S_AXI_AWADDR),
        .S_AXI_AWLEN       (S_AXI_AWLEN),
        .S_AXI_AWSIZE      (S_AXI_AWSIZE),
        .S_AXI_AWBURST     (S_AXI_AWBURST),
        .S_AXI_AWVALID     (S_AXI_AWVALID),
        .S_AXI_AWREADY     (S_AXI_AWREADY),
        .S_AXI_WDATA       (S_AXI_WDATA),
        .S_AXI_WSTRB       (S_AXI_WSTRB),
        .S_AXI_WLAST       (S_AXI_WLAST),
        .S_AXI_WVALID      (S_AXI_WVALID),
        .S_AXI_WREADY      (S_AXI_WREADY),
        .S_AXI_BID         (S_AXI_BID),
        .S_AXI_BRESP       (S_AXI_BRESP),
        .S_AXI_BVALID      (S_AXI_BVALID),
        .S_AXI_BREADY      (S_AXI_BREADY),
        .S_AXI_ARID        (S_AXI_ARID),
        .S_AXI_ARADDR      (S_AXI_ARADDR),
        .S_AXI_ARLEN       (S_AXI_ARLEN),
        .S_AXI_ARSIZE      (S_AXI_ARSIZE),
        .S_AXI_ARBURST     (S_AXI_ARBURST),
        .S_AXI_ARVALID     (S_AXI_ARVALID),
        .S_AXI_ARREADY     (S_AXI_ARREADY),
        .S_AXI_RID         (S_AXI_RID),
        .S_AXI_RDATA       (S_AXI_RDATA),
        .S_AXI_RRESP       (S_AXI_RRESP),
        .S_AXI_RLAST       (S_AXI_RLAST),
        .S_AXI_RVALID      (S_AXI_RVALID),
        .S_AXI_RREADY      (S_AXI_RREADY),
        .M_AXI_AWCH_o      (LINK_AXI_AWCH),
        .M_AXI_AWCH_VALID_o(LINK_AXI_AWCH_VALID),
        .M_AXI_AWCH_READY_i(LINK_AXI_AWCH_READY),
        .M_AXI_WCH_o       (LINK_AXI_WCH),
        .M_AXI_WCH_VALID_o (LINK_AXI_WCH_VALID),
        .M_AXI_WCH_READY_i (LINK_AXI_WCH_READY),
        .M_AXI_BCH_i       (LINK_AXI_BCH),
        .M_AXI_BCH_VALID_i (LINK_AXI_BCH_VALID),
        .M_AXI_BCH_READY_o (LINK_AXI_BCH_READY),
        .M_AXI_ARCH_o      (LINK_AXI_ARCH),
        .M_AXI_ARCH_VALID_o(LINK_AXI_ARCH_VALID),
        .M_AXI_ARCH_READY_i(LINK_AXI_ARCH_READY),
        .M_AXI_RCH_i       (LINK_AXI_RCH),
        .M_AXI_RCH_VALID_i (LINK_AXI_RCH_VALID),
        .M_AXI_RCH_READY_o (LINK_AXI_RCH_READY)
    );

    axi_slave_router #(
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_MASTER_PORT(AXI_MASTER_PORT)
    ) axi_slave_router_0 (
        .ACLK              (ACLK),
        .ARESETN           (ARESETN),
        .M_AXI_AWID        (M_AXI_AWID),
        .M_AXI_AWADDR      (M_AXI_AWADDR),
        .M_AXI_AWLEN       (M_AXI_AWLEN),
        .M_AXI_AWSIZE      (M_AXI_AWSIZE),
        .M_AXI_AWBURST     (M_AXI_AWBURST),
        .M_AXI_AWVALID     (M_AXI_AWVALID),
        .M_AXI_AWREADY     (M_AXI_AWREADY),
        .M_AXI_WDATA       (M_AXI_WDATA),
        .M_AXI_WSTRB       (M_AXI_WSTRB),
        .M_AXI_WLAST       (M_AXI_WLAST),
        .M_AXI_WVALID      (M_AXI_WVALID),
        .M_AXI_WREADY      (M_AXI_WREADY),
        .M_AXI_BID         (M_AXI_BID),
        .M_AXI_BRESP       (M_AXI_BRESP),
        .M_AXI_BVALID      (M_AXI_BVALID),
        .M_AXI_BREADY      (M_AXI_BREADY),
        .M_AXI_ARID        (M_AXI_ARID),
        .M_AXI_ARADDR      (M_AXI_ARADDR),
        .M_AXI_ARLEN       (M_AXI_ARLEN),
        .M_AXI_ARSIZE      (M_AXI_ARSIZE),
        .M_AXI_ARBURST     (M_AXI_ARBURST),
        .M_AXI_ARVALID     (M_AXI_ARVALID),
        .M_AXI_ARREADY     (M_AXI_ARREADY),
        .M_AXI_RID         (M_AXI_RID),
        .M_AXI_RDATA       (M_AXI_RDATA),
        .M_AXI_RRESP       (M_AXI_RRESP),
        .M_AXI_RLAST       (M_AXI_RLAST),
        .M_AXI_RVALID      (M_AXI_RVALID),
        .M_AXI_RREADY      (M_AXI_RREADY),
        .S_AXI_AWCH_i      (LINK_AXI_AWCH),
        .S_AXI_AWCH_VALID_i(LINK_AXI_AWCH_VALID),
        .S_AXI_AWCH_READY_o(LINK_AXI_AWCH_READY),
        .S_AXI_WCH_i       (LINK_AXI_WCH),
        .S_AXI_WCH_VALID_i (LINK_AXI_WCH_VALID),
        .S_AXI_WCH_READY_o (LINK_AXI_WCH_READY),
        .S_AXI_BCH_o       (LINK_AXI_BCH),
        .S_AXI_BCH_VALID_o (LINK_AXI_BCH_VALID),
        .S_AXI_BCH_READY_i (LINK_AXI_BCH_READY),
        .S_AXI_ARCH_i      (LINK_AXI_ARCH),
        .S_AXI_ARCH_VALID_i(LINK_AXI_ARCH_VALID),
        .S_AXI_ARCH_READY_o(LINK_AXI_ARCH_READY),
        .S_AXI_RCH_o       (LINK_AXI_RCH),
        .S_AXI_RCH_VALID_o (LINK_AXI_RCH_VALID),
        .S_AXI_RCH_READY_i (LINK_AXI_RCH_READY)
    );


endmodule
