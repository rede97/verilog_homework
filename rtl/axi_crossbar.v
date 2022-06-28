module axi_crossbar #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Width of S_AXI data bus
    parameter integer AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8,
    // Slave interface number
    parameter integer AXI_SLAVE_PORT = 1,
    // Master interface number
    parameter integer AXI_MASTER_PORT = 1
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



endmodule
