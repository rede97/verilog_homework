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
    parameter integer AXI_RDCHAN_WIDTH = AXI_ID_WIDTH + AXI_DATA_WIDTH + 2 + 1
) (
    // Global Clock Signal
    input  wire                                            ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input  wire                                            ARESETN,
    // ==========================================================
    // Slave Write address channel
    // ==========================================================
    input  wire [      AXI_ID_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_AWID,
    input  wire [    AXI_ADDR_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_AWADDR,
    input  wire [                 8*AXI_MASTER_PORT-1 : 0] S_AXI_AWLEN,
    input  wire [                 3*AXI_MASTER_PORT-1 : 0] S_AXI_AWSIZE,
    input  wire [                 2*AXI_MASTER_PORT-1 : 0] S_AXI_AWBURST,
    input  wire [                     AXI_MASTER_PORT-1:0] S_AXI_AWVALID,
    output wire [                     AXI_MASTER_PORT-1:0] S_AXI_AWREADY,
    // ==========================================================
    // Slave Write data channel
    // ==========================================================
    input  wire [    AXI_DATA_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_WDATA,
    input  wire [(AXI_DATA_WIDTH/8)*AXI_MASTER_PORT-1 : 0] S_AXI_WSTRB,
    input  wire [                     AXI_MASTER_PORT-1:0] S_AXI_WLAST,
    input  wire [                     AXI_MASTER_PORT-1:0] S_AXI_WVALID,
    output wire [                     AXI_MASTER_PORT-1:0] S_AXI_WREADY,
    // ==========================================================
    // Slave Write response channel
    // ==========================================================
    output wire [      AXI_ID_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_BID,
    output wire [                 2*AXI_MASTER_PORT-1 : 0] S_AXI_BRESP,
    output wire [                     AXI_MASTER_PORT-1:0] S_AXI_BVALID,
    input  wire [                     AXI_MASTER_PORT-1:0] S_AXI_BREADY,
    // ==========================================================
    // Slave Read address channel
    // ==========================================================
    input  wire [      AXI_ID_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_ARID,
    input  wire [    AXI_ADDR_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_ARADDR,
    input  wire [                 8*AXI_MASTER_PORT-1 : 0] S_AXI_ARLEN,
    input  wire [                 3*AXI_MASTER_PORT-1 : 0] S_AXI_ARSIZE,
    input  wire [                 2*AXI_MASTER_PORT-1 : 0] S_AXI_ARBURST,
    input  wire [                     AXI_MASTER_PORT-1:0] S_AXI_ARVALID,
    output wire [                     AXI_MASTER_PORT-1:0] S_AXI_ARREADY,
    // ==========================================================
    // Slave Read data channel
    // ==========================================================
    output wire [      AXI_ID_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_RID,
    output wire [    AXI_DATA_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_RDATA,
    output wire [                 2*AXI_MASTER_PORT-1 : 0] S_AXI_RRESP,
    output wire [                     AXI_MASTER_PORT-1:0] S_AXI_RLAST,
    output wire [                     AXI_MASTER_PORT-1:0] S_AXI_RVALID,
    input  wire [                     AXI_MASTER_PORT-1:0] S_AXI_RREADY,
    // ==========================================================
    // Master Write address channel
    // ==========================================================
    output wire [       AXI_ID_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_AWID,
    output wire [     AXI_ADDR_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_AWADDR,
    output wire [                  8*AXI_SLAVE_PORT-1 : 0] M_AXI_AWLEN,
    output wire [                  3*AXI_SLAVE_PORT-1 : 0] M_AXI_AWSIZE,
    output wire [                  2*AXI_SLAVE_PORT-1 : 0] M_AXI_AWBURST,
    output wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_AWVALID,
    input  wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_AWREADY,
    // ==========================================================
    // Master Write data channel
    // ==========================================================
    output wire [     AXI_DATA_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_WDATA,
    output wire [ (AXI_DATA_WIDTH/8)*AXI_SLAVE_PORT-1 : 0] M_AXI_WSTRB,
    output wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_WLAST,
    output wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_WVALID,
    input  wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_WREADY,
    // ==========================================================
    // Master Write response channel
    // ==========================================================
    input  wire [       AXI_ID_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_BID,
    input  wire [                  2*AXI_SLAVE_PORT-1 : 0] M_AXI_BRESP,
    input  wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_BVALID,
    output wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_BREADY,
    // ==========================================================
    // Master Read address channel
    // ==========================================================
    output wire [       AXI_ID_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_ARID,
    output wire [     AXI_ADDR_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_ARADDR,
    output wire [                  8*AXI_SLAVE_PORT-1 : 0] M_AXI_ARLEN,
    output wire [                  3*AXI_SLAVE_PORT-1 : 0] M_AXI_ARSIZE,
    output wire [                  2*AXI_SLAVE_PORT-1 : 0] M_AXI_ARBURST,
    output wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_ARVALID,
    input  wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_ARREADY,
    // ==========================================================
    // Master Read data channel
    // ==========================================================
    input  wire [       AXI_ID_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_RID,
    input  wire [     AXI_DATA_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_RDATA,
    input  wire [                  2*AXI_SLAVE_PORT-1 : 0] M_AXI_RRESP,
    input  wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_RLAST,
    input  wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_RVALID,
    output wire [                    AXI_SLAVE_PORT-1 : 0] M_AXI_RREADY
);

    wire [AXI_AWCHAN_WIDTH*AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_AWCH[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_AWCH_VALID[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_AWCH_READY[0:AXI_SLAVE_PORT-1];
    wire [AXI_WDCHAN_WIDTH*AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_WCH[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_WCH_VALID[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_WCH_READY[0:AXI_SLAVE_PORT-1];
    wire [AXI_WBCHAN_WIDTH*AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_BCH[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_BCH_VALID[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_BCH_READY[0:AXI_SLAVE_PORT-1];
    wire [AXI_ARCHAN_WIDTH*AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_ARCH[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_ARCH_VALID[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_ARCH_READY[0:AXI_SLAVE_PORT-1];
    wire [AXI_RDCHAN_WIDTH*AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_RCH[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_RCH_VALID[0:AXI_SLAVE_PORT-1];
    wire [AXI_MASTER_PORT-1:0] LINK_SLAVE_ROUTE_AXI_RCH_READY[0:AXI_SLAVE_PORT-1];


    wire [ AXI_AWCHAN_WIDTH*AXI_SLAVE_PORT-1:0]  LINK_MASTER_ROUTE_AXI_AWCH[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_AWCH_VALID[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_AWCH_READY[0:AXI_MASTER_PORT-1];
    wire [AXI_WDCHAN_WIDTH*AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_WCH[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_WCH_VALID[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_WCH_READY[0:AXI_MASTER_PORT-1];
    wire [AXI_WBCHAN_WIDTH*AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_BCH[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_BCH_VALID[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_BCH_READY[0:AXI_MASTER_PORT-1];
    wire [ AXI_ARCHAN_WIDTH*AXI_SLAVE_PORT-1:0]  LINK_MASTER_ROUTE_AXI_ARCH      [0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_ARCH_VALID[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_ARCH_READY[0:AXI_MASTER_PORT-1];
    wire [AXI_RDCHAN_WIDTH*AXI_SLAVE_PORT-1:0]  LINK_MASTER_ROUTE_AXI_RCH       [0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_RCH_VALID[0:AXI_MASTER_PORT-1];
    wire [AXI_SLAVE_PORT-1:0] LINK_MASTER_ROUTE_AXI_RCH_READY[0:AXI_MASTER_PORT-1];

    genvar i, j;
    for (i = 0; i < AXI_MASTER_PORT; i = i + 1) begin : g_link_i
        for (j = 0; j < AXI_SLAVE_PORT; j = j + 1) begin : g_link_j
            assign LINK_SLAVE_ROUTE_AXI_AWCH[j][AXI_AWCHAN_WIDTH*(i+1)-1:AXI_AWCHAN_WIDTH*i] =
                LINK_MASTER_ROUTE_AXI_AWCH[i][AXI_AWCHAN_WIDTH*(j+1)-1: AXI_AWCHAN_WIDTH*j];
            assign LINK_SLAVE_ROUTE_AXI_AWCH_VALID[j][(i+1)-1:i] =
                LINK_MASTER_ROUTE_AXI_AWCH_VALID[i][(j+1)-1:j];
            assign LINK_MASTER_ROUTE_AXI_AWCH_READY[i][(j+1)-1:j] =
                LINK_SLAVE_ROUTE_AXI_AWCH_READY[j][(i+1)-1:i];

            assign LINK_SLAVE_ROUTE_AXI_WCH[j][AXI_WDCHAN_WIDTH*(i+1)-1:AXI_WDCHAN_WIDTH*i] =
                LINK_MASTER_ROUTE_AXI_WCH[i][AXI_WDCHAN_WIDTH*(j+1)-1: AXI_WDCHAN_WIDTH*j];
            assign LINK_SLAVE_ROUTE_AXI_WCH_VALID[j][(i+1)-1:i] =
                LINK_MASTER_ROUTE_AXI_WCH_VALID[i][(j+1)-1:j];
            assign LINK_MASTER_ROUTE_AXI_WCH_READY[i][(j+1)-1:j] =
                LINK_SLAVE_ROUTE_AXI_WCH_READY[j][(i+1)-1:i];

            assign LINK_MASTER_ROUTE_AXI_BCH[i][AXI_WBCHAN_WIDTH*(j+1)-1:AXI_WBCHAN_WIDTH*j] =
                LINK_SLAVE_ROUTE_AXI_BCH[j][AXI_WBCHAN_WIDTH*(i+1)-1:AXI_WBCHAN_WIDTH*i];
            assign LINK_MASTER_ROUTE_AXI_BCH_VALID[i][(j+1)-1:j] =
                LINK_SLAVE_ROUTE_AXI_BCH_VALID[j][(i+1)-1:i];
            assign LINK_SLAVE_ROUTE_AXI_BCH_READY[j][(i+1)-1:i] =
                LINK_MASTER_ROUTE_AXI_BCH_READY[i][(j+1)-1:j];

            assign LINK_SLAVE_ROUTE_AXI_ARCH[j][AXI_ARCHAN_WIDTH*(i+1)-1:AXI_ARCHAN_WIDTH*i] =
                LINK_MASTER_ROUTE_AXI_ARCH[i][AXI_ARCHAN_WIDTH*(j+1)-1: AXI_ARCHAN_WIDTH*j];
            assign LINK_SLAVE_ROUTE_AXI_ARCH_VALID[j][(i+1)-1:i] =
                LINK_MASTER_ROUTE_AXI_ARCH_VALID[i][(j+1)-1:j];
            assign LINK_MASTER_ROUTE_AXI_ARCH_READY[i][(j+1)-1:j] =
                LINK_SLAVE_ROUTE_AXI_ARCH_READY[j][(i+1)-1:i];

            assign LINK_MASTER_ROUTE_AXI_RCH[i][AXI_RDCHAN_WIDTH*(j+1)-1:AXI_RDCHAN_WIDTH*j] =
                LINK_SLAVE_ROUTE_AXI_RCH[j][AXI_RDCHAN_WIDTH*(i+1)-1:AXI_RDCHAN_WIDTH*i];
            assign LINK_MASTER_ROUTE_AXI_RCH_VALID[i][(j+1)-1:j] =
                LINK_SLAVE_ROUTE_AXI_RCH_VALID[j][(i+1)-1:i];
            assign LINK_SLAVE_ROUTE_AXI_RCH_READY[j][(i+1)-1:i] =
                LINK_MASTER_ROUTE_AXI_RCH_READY[i][(j+1)-1:j];
        end
    end
    generate

    endgenerate

    generate
        for (i = 0; i < AXI_MASTER_PORT; i = i + 1) begin : g_master_router
            axi_master_router #(
                .AXI_ID_WIDTH  (AXI_ID_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_SLAVE_PORT(AXI_SLAVE_PORT)
            ) axi_master_router (
                .ACLK              (ACLK),
                .ARESETN           (ARESETN),
                .S_AXI_AWID        (S_AXI_AWID[AXI_ID_WIDTH*(i+1)-1 : AXI_ID_WIDTH*i]),
                .S_AXI_AWADDR      (S_AXI_AWADDR[AXI_ADDR_WIDTH*(i+1)-1:AXI_ADDR_WIDTH*i]),
                .S_AXI_AWLEN       (S_AXI_AWLEN[8*(i+1)-1:8*i]),
                .S_AXI_AWSIZE      (S_AXI_AWSIZE[3*(i+1)-1:3*i]),
                .S_AXI_AWBURST     (S_AXI_AWBURST[2*(i+1)-1:2*i]),
                .S_AXI_AWVALID     (S_AXI_AWVALID[(i+1)-1:i]),
                .S_AXI_AWREADY     (S_AXI_AWREADY[(i+1)-1:i]),
                .S_AXI_WDATA       (S_AXI_WDATA[AXI_DATA_WIDTH*(i+1)-1:AXI_DATA_WIDTH*i]),
                .S_AXI_WSTRB       (S_AXI_WSTRB[(AXI_DATA_WIDTH/8)*(i+1)-1:(AXI_DATA_WIDTH/8)*i]),
                .S_AXI_WLAST       (S_AXI_WLAST[(i+1)-1:i]),
                .S_AXI_WVALID      (S_AXI_WVALID[(i+1)-1:i]),
                .S_AXI_WREADY      (S_AXI_WREADY[(i+1)-1:i]),
                .S_AXI_BID         (S_AXI_BID[AXI_ID_WIDTH*(i+1)-1:AXI_ID_WIDTH*i]),
                .S_AXI_BRESP       (S_AXI_BRESP[2*(i+1)-1:2*i]),
                .S_AXI_BVALID      (S_AXI_BVALID[(i+1)-1:i]),
                .S_AXI_BREADY      (S_AXI_BREADY[(i+1)-1:i]),
                .S_AXI_ARID        (S_AXI_ARID[AXI_ID_WIDTH*(i+1)-1:AXI_ID_WIDTH*i]),
                .S_AXI_ARADDR      (S_AXI_ARADDR[AXI_ADDR_WIDTH*(i+1)-1:AXI_ADDR_WIDTH*i]),
                .S_AXI_ARLEN       (S_AXI_ARLEN[8*(i+1)-1:8*i]),
                .S_AXI_ARSIZE      (S_AXI_ARSIZE[3*(i+1)-1:3*i]),
                .S_AXI_ARBURST     (S_AXI_ARBURST[2*(i+1)-1:2*i]),
                .S_AXI_ARVALID     (S_AXI_ARVALID[(i+1)-1:i]),
                .S_AXI_ARREADY     (S_AXI_ARREADY[(i+1)-1:i]),
                .S_AXI_RID         (S_AXI_RID[AXI_ID_WIDTH*(i+1)-1:AXI_ID_WIDTH*i]),
                .S_AXI_RDATA       (S_AXI_RDATA[AXI_DATA_WIDTH*(i+1)-1:AXI_DATA_WIDTH*i]),
                .S_AXI_RRESP       (S_AXI_RRESP[2*(i+1)-1:2*i]),
                .S_AXI_RLAST       (S_AXI_RLAST[(i+1)-1:i]),
                .S_AXI_RVALID      (S_AXI_RVALID[(i+1)-1:i]),
                .S_AXI_RREADY      (S_AXI_RREADY[(i+1)-1:i]),
                .M_AXI_AWCH_o      (LINK_MASTER_ROUTE_AXI_AWCH[i]),
                .M_AXI_AWCH_VALID_o(LINK_MASTER_ROUTE_AXI_AWCH_VALID[i]),
                .M_AXI_AWCH_READY_i(LINK_MASTER_ROUTE_AXI_AWCH_READY[i]),
                .M_AXI_WCH_o       (LINK_MASTER_ROUTE_AXI_WCH[i]),
                .M_AXI_WCH_VALID_o (LINK_MASTER_ROUTE_AXI_WCH_VALID[i]),
                .M_AXI_WCH_READY_i (LINK_MASTER_ROUTE_AXI_WCH_READY[i]),
                .M_AXI_BCH_i       (LINK_MASTER_ROUTE_AXI_BCH[i]),
                .M_AXI_BCH_VALID_i (LINK_MASTER_ROUTE_AXI_BCH_VALID[i]),
                .M_AXI_BCH_READY_o (LINK_MASTER_ROUTE_AXI_BCH_READY[i]),
                .M_AXI_ARCH_o      (LINK_MASTER_ROUTE_AXI_ARCH[i]),
                .M_AXI_ARCH_VALID_o(LINK_MASTER_ROUTE_AXI_ARCH_VALID[i]),
                .M_AXI_ARCH_READY_i(LINK_MASTER_ROUTE_AXI_ARCH_READY[i]),
                .M_AXI_RCH_i       (LINK_MASTER_ROUTE_AXI_RCH[i]),
                .M_AXI_RCH_VALID_i (LINK_MASTER_ROUTE_AXI_RCH_VALID[i]),
                .M_AXI_RCH_READY_o (LINK_MASTER_ROUTE_AXI_RCH_READY[i])
            );
        end
    endgenerate


    generate
        for (i = 0; i < AXI_SLAVE_PORT; i = i + 1) begin : g_slave_router
            axi_slave_router #(
                .AXI_ID_WIDTH(AXI_ID_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_MASTER_PORT(AXI_MASTER_PORT)
            ) axi_slave_router_0 (
                .ACLK              (ACLK),
                .ARESETN           (ARESETN),
                .M_AXI_AWID        (M_AXI_AWID[AXI_ID_WIDTH*(i+1)-1:AXI_ID_WIDTH*i]),
                .M_AXI_AWADDR      (M_AXI_AWADDR[AXI_ADDR_WIDTH*(i+1)-1:AXI_ADDR_WIDTH*i]),
                .M_AXI_AWLEN       (M_AXI_AWLEN[8*(i+1)-1:8*i]),
                .M_AXI_AWSIZE      (M_AXI_AWSIZE[3*(i+1)-1:3*i]),
                .M_AXI_AWBURST     (M_AXI_AWBURST[2*(i+1)-1:2*i]),
                .M_AXI_AWVALID     (M_AXI_AWVALID[(i+1)-1:i]),
                .M_AXI_AWREADY     (M_AXI_AWREADY[(i+1)-1:i]),
                .M_AXI_WDATA       (M_AXI_WDATA[AXI_DATA_WIDTH*(i+1)-1:AXI_DATA_WIDTH*i]),
                .M_AXI_WSTRB       (M_AXI_WSTRB[(AXI_DATA_WIDTH/8)*(i+1)-1:(AXI_DATA_WIDTH/8)*i]),
                .M_AXI_WLAST       (M_AXI_WLAST[(i+1)-1:i]),
                .M_AXI_WVALID      (M_AXI_WVALID[(i+1)-1:i]),
                .M_AXI_WREADY      (M_AXI_WREADY[(i+1)-1:i]),
                .M_AXI_BID         (M_AXI_BID[AXI_ID_WIDTH*(i+1)-1:AXI_ID_WIDTH*i]),
                .M_AXI_BRESP       (M_AXI_BRESP[2*(i+1)-1:2*i]),
                .M_AXI_BVALID      (M_AXI_BVALID[(i+1)-1:i]),
                .M_AXI_BREADY      (M_AXI_BREADY[(i+1)-1:i]),
                .M_AXI_ARID        (M_AXI_ARID[AXI_ID_WIDTH*(i+1)-1:AXI_ID_WIDTH*i]),
                .M_AXI_ARADDR      (M_AXI_ARADDR[AXI_ADDR_WIDTH*(i+1)-1:AXI_ADDR_WIDTH*i]),
                .M_AXI_ARLEN       (M_AXI_ARLEN[8*(i+1)-1:8*i]),
                .M_AXI_ARSIZE      (M_AXI_ARSIZE[3*(i+1)-1:3*i]),
                .M_AXI_ARBURST     (M_AXI_ARBURST[2*(i+1)-1:2*i]),
                .M_AXI_ARVALID     (M_AXI_ARVALID[(i+1)-1:i]),
                .M_AXI_ARREADY     (M_AXI_ARREADY[(i+1)-1:i]),
                .M_AXI_RID         (M_AXI_RID[AXI_ID_WIDTH*(i+1)-1:AXI_ID_WIDTH*i]),
                .M_AXI_RDATA       (M_AXI_RDATA[AXI_DATA_WIDTH*(i+1)-1:AXI_DATA_WIDTH*i]),
                .M_AXI_RRESP       (M_AXI_RRESP[2*(i+1)-1:2*i]),
                .M_AXI_RLAST       (M_AXI_RLAST[(i+1)-1:i]),
                .M_AXI_RVALID      (M_AXI_RVALID[(i+1)-1:i]),
                .M_AXI_RREADY      (M_AXI_RREADY[(i+1)-1:i]),
                .S_AXI_AWCH_i      (LINK_SLAVE_ROUTE_AXI_AWCH[i]),
                .S_AXI_AWCH_VALID_i(LINK_SLAVE_ROUTE_AXI_AWCH_VALID[i]),
                .S_AXI_AWCH_READY_o(LINK_SLAVE_ROUTE_AXI_AWCH_READY[i]),
                .S_AXI_WCH_i       (LINK_SLAVE_ROUTE_AXI_WCH[i]),
                .S_AXI_WCH_VALID_i (LINK_SLAVE_ROUTE_AXI_WCH_VALID[i]),
                .S_AXI_WCH_READY_o (LINK_SLAVE_ROUTE_AXI_WCH_READY[i]),
                .S_AXI_BCH_o       (LINK_SLAVE_ROUTE_AXI_BCH[i]),
                .S_AXI_BCH_VALID_o (LINK_SLAVE_ROUTE_AXI_BCH_VALID[i]),
                .S_AXI_BCH_READY_i (LINK_SLAVE_ROUTE_AXI_BCH_READY[i]),
                .S_AXI_ARCH_i      (LINK_SLAVE_ROUTE_AXI_ARCH[i]),
                .S_AXI_ARCH_VALID_i(LINK_SLAVE_ROUTE_AXI_ARCH_VALID[i]),
                .S_AXI_ARCH_READY_o(LINK_SLAVE_ROUTE_AXI_ARCH_READY[i]),
                .S_AXI_RCH_o       (LINK_SLAVE_ROUTE_AXI_RCH[i]),
                .S_AXI_RCH_VALID_o (LINK_SLAVE_ROUTE_AXI_RCH_VALID[i]),
                .S_AXI_RCH_READY_i (LINK_SLAVE_ROUTE_AXI_RCH_READY[i])
            );
        end
    endgenerate


endmodule
