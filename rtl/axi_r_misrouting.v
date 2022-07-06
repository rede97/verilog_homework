module axi_r_misrouting #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Width of S_AXI data bus
    parameter integer AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8,
    // AXI_ID_WIDTH + AXI_ADDR_WIDTH + S_AXI_ARLEN + S_AXI_ARSIZE + S_AXI_ARBURST
    parameter integer AXI_ARCHAN_WIDTH = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2,
    // AXI_ID_WIDTH + AXI_DATA_WIDTH + S_AXI_RRESP + S_AXI_RLAST
    parameter integer AXI_RDCHAN_WIDTH = AXI_ID_WIDTH + AXI_DATA_WIDTH + 2 + 1
) (
    // Global Clock Signal
    input  wire                          ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input  wire                          ARESETN,
    // ==========================================================
    // Slave Read address channel
    // ==========================================================
    input  wire [AXI_ARCHAN_WIDTH-1 : 0] S_AXI_ARCH_i,
    input  wire                          S_AXI_ARCH_VALID_i,
    output wire                          S_AXI_ARCH_READY_o,
    // ==========================================================
    // Slave Read data channel
    // ==========================================================
    output wire [AXI_RDCHAN_WIDTH-1 : 0] S_AXI_RCH_o,
    output wire                          S_AXI_RCH_VALID_o,
    input  wire                          S_AXI_RCH_READY_i
);
    wire [AXI_ID_WIDTH-1:0] ARID;
    wire [7:0] ARLEN;
    wire [AXI_DATA_WIDTH-1:0] RDATA;
    wire RLAST;
    wire misrouting_finish;
    wire rch_en;
    reg [7:0] counter;

    assign RDATA = 'd0;
    assign ARID = S_AXI_ARCH_i[AXI_ARCHAN_WIDTH-1:AXI_ARCHAN_WIDTH-AXI_ID_WIDTH];
    assign ARLEN = S_AXI_ARCH_i[AXI_ARCHAN_WIDTH-AXI_ID_WIDTH-1:AXI_ARCHAN_WIDTH-AXI_ID_WIDTH-8];
    assign S_AXI_RCH_o = {RDATA, RLAST ? 2'b11 : 2'b00, RLAST, ARID};
    assign RLAST = counter == ARLEN;
    assign rch_enrch_en = S_AXI_RCH_VALID_o && S_AXI_RCH_READY_i;
    assign misrouting_finish = RLAST && rch_enrch_en;
    assign S_AXI_ARCH_READY_o = misrouting_finish;
    assign S_AXI_RCH_VALID_o = S_AXI_ARCH_VALID_i;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            counter <= 'd0;
        end else begin
            if (S_AXI_ARCH_VALID_i && !misrouting_finish) begin
                if (rch_enrch_en) begin
                    counter <= counter + 'd1;
                end
            end else begin
                counter <= 'd0;
            end
        end
    end

endmodule
