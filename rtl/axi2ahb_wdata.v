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
    output reg                             WREADY,
    // AXI Response channel
    output wire [        AXI_ID_WIDTH-1:0] BID,
    output wire [                     1:0] BRESP,
    output wire                            BVALID,
    input  wire                            BREADY,
    // AHB Write interface
    output wire [      AXI_DATA_WIDTH-1:0] HWDATA,
    input  wire                            HREADY,
    // CTRL interface
    input  wire [        AXI_ID_WIDTH-1:0] cmd_id,
    output wire                            ctrl_wdata_last,
    output wire                            ctrl_wdata_valid,
    input  wire                            ctrl_wdata_ready
);

endmodule
