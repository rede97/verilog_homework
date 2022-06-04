module axi2ahb_ctrl #(
    // Width of AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8
) (
    input  wire                      ACLK,
    input  wire                      ARESETN,
    // AHB Manager interface
    output wire [AXI_ADDR_WIDTH-1:0] HADDR,
    output wire [               2:0] HBURST,
    output wire [               2:0] HSIZE,
    output wire [               1:0] HTRANS,
    output wire                      HWDATA,
    input  wire                      HREADY,
    // CMD interface
    input  wire                      cmd_read,
    input  wire                      cmd_write,
    input  wire                      cmd_start_addr,
    input  wire                      cmd_transfer_len,
    input  wire                      cmd_burst_type,
    // CTRL-CMD interface
    input  wire                      ctrl_cmd_valid,
    output wire                      ctrl_cmd_ready
);

endmodule
