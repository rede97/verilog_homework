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
    // CTRL & CMD interface
    input  wire [  AXI_ID_WIDTH-1:0] cmd_id,
    input  wire                      ctrl_rdata_ready,
    output wire                      ctrl_rdata_valid
);


endmodule
