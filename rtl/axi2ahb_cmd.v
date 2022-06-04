module axi2ahb_cmd #(
    // Width of ID for write address
    parameter integer AXI_ID_WIDTH   = 1,
    // Width of AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8
) (
    input  wire                        ACLK,
    input  wire                        ARESETN,
    // AXI Write Address channel
    input  wire [    AXI_ID_WIDTH-1:0] AWID,
    input  wire [  AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire [                 7:0] AWLEN,
    input  wire [                 2:0] AWSIZE,
    input  wire [                 1:0] AWBURST,
    input  wire                        AWVALID,
    output reg                         AWREADY,
    // AXI Read Address channel
    input  wire [    AXI_ID_WIDTH-1:0] ARID,
    input  wire [AXI_ADDR_WIDTH-1 : 0] ARADDR,
    input  wire [                 7:0] ARLEN,
    input  wire [                 2:0] ARSIZE,
    input  wire [                 1:0] ARBURST,
    input  wire                        ARVALID,
    output reg                         ARREADY,
    // CMD output
    output reg  [    AXI_ID_WIDTH-1:0] cmd_id_o,
    output reg                         cmd_read_o,
    output reg                         cmd_write_o,
    output reg                         cmd_start_addr_o,
    output reg  [                 3:0] cmd_transfer_len_o,
    output reg  [                 1:0] cmd_burst_type_o,
    output reg                         cmd_error_o,
    output reg                         ctrl_cmd_valid_o,
    input  wire                        ctrl_cmd_ready_i
);
    wire update_cmd = (!ctrl_cmd_valid_o || ctrl_cmd_ready_i) && (AWVALID | ARVALID);
    wire arbiter_next_action_write = AWVALID ? (ARVALID ? cmd_read_o : 1'b1) : 1'b0;
    wire [1:0] burst_type = arbiter_next_action_write ? AWBURST : ARBURST;
    wire is_burst_wrap = burst_type == 2'b10;
    wire [3:0] transfer_len = arbiter_next_action_write ? AWLEN : ARLEN;
    wire [2:0] transfer_size = arbiter_next_action_write ? AWSIZE : ARSIZE;
    wire transefer_size_err = transfer_size != 3'b010;
    reg is_transfer_len_4_8_16;
    wire cmd_error = transefer_size_err | (is_burst_wrap & is_transfer_len_4_8_16);

    always @(*) begin
        case (transfer_len)
            'd4:  is_transfer_len_4_8_16 = 1'b0;
            'd8:  is_transfer_len_4_8_16 = 1'b0;
            'd16: is_transfer_len_4_8_16 = 1'b0;
            default: begin
                is_transfer_len_4_8_16 = 1'b1;
            end
        endcase
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            cmd_id_o           <= 'd0;
            cmd_read_o         <= 'd0;
            cmd_write_o        <= 'd0;
            cmd_start_addr_o   <= 'd0;
            cmd_transfer_len_o <= 'd0;
            cmd_burst_type_o   <= 'd0;
            cmd_error_o        <= 'b0;
        end else begin
            cmd_id_o           <= arbiter_next_action_write ? AWID : ARID;
            cmd_read_o         <= arbiter_next_action_write ? 1'b0 : 1'b1;
            cmd_write_o        <= arbiter_next_action_write ? 1'b1 : 1'b0;
            cmd_start_addr_o   <= arbiter_next_action_write ? AWADDR : ARADDR;
            cmd_transfer_len_o <= transfer_len;
            cmd_burst_type_o   <= burst_type;
            cmd_error_o        <= cmd_error;
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_cmd_valid_o <= 1'b0;
            AWREADY <= 1'b0;
            ARREADY <= 1'b0;
        end else begin
            ctrl_cmd_valid_o <= update_cmd;
            AWREADY <= arbiter_next_action_write & update_cmd;
            ARREADY <= !arbiter_next_action_write & update_cmd;
        end
    end

endmodule
