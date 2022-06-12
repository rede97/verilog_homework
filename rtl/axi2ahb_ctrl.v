module axi2ahb_ctrl #(
    // Width of AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8
) (
    input  wire                      ACLK,
    input  wire                      ARESETN,
    // AHB Manager interface
    output reg  [AXI_ADDR_WIDTH-1:0] HADDR,
    output reg  [               2:0] HBURST,
    output wire [               2:0] HSIZE,
    output reg  [               1:0] HTRANS,
    input  wire                      HREADY,
    output reg                       HWRITE,
    // CMD interface
    input  wire                      cmd_error_i,
    input  wire                      cmd_read_i,
    input  wire                      cmd_write_i,
    input  wire [AXI_ADDR_WIDTH-1:0] cmd_start_addr_i,
    input  wire [               7:0] cmd_transfer_len_i,
    input  wire [               1:0] cmd_burst_type_i,
    // CTRL-CMD interface
    input  wire                      ctrl_cmd_valid_i,
    output reg                       ctrl_cmd_ready_o,
    // CTRL-RDATA interface
    input  wire                      ctrl_rdata_ready_i,
    output reg                       ctrl_rdata_valid_o,
    output reg                       ctrl_rdata_last_o,
    // CTRL-WDATA interface
    input  wire                      ctrl_wdata_last_i,
    input  wire                      ctrl_wdata_ready_i,
    output wire                      ctrl_wdata_valid_o
);
    localparam [1:0] IDLE = 2'b00, NOSEQ = 2'b10, SEQ = 2'b11, BUSY = 2'b01;

    reg  [               7:0] ctrl_transfer_counter;
    reg                       ctrl_working;
    reg                       ctrl_next_cmd_phase;
    reg  [               1:0] HTRANS_next;

    wire [AXI_ADDR_WIDTH-1:0] HADDR_inc;
    wire                      HADDR_wrap_en;
    wire                      ahb_read_write_ready;
    wire                      ctrl_working_start;
    wire                      ctrl_working_finish;
    wire                      ctrl_counter_full;
    wire                      ctrl_gen_ahb_control;

    assign HSIZE = 3'b010;
    assign HADDR_inc = {HADDR[AXI_ADDR_WIDTH-1:2] + 1, 2'b00};
    assign HADDR_wrap_en = ((HADDR[AXI_ADDR_WIDTH-1:2] & cmd_transfer_len_i) == cmd_transfer_len_i) ? 1'b1 : 1'b0;
    // Is WDATA module and RDATA module ready?
    assign ahb_read_write_ready = cmd_read_i ? ctrl_rdata_ready_i : (cmd_write_i ? ctrl_wdata_ready_i : 1'b0);
    // Generate control signal flag
    assign ctrl_gen_ahb_control = ahb_read_write_ready && (ctrl_working_start || ctrl_working) && HREADY;
    // Update WDATA immediatly when CTRL ready to enter cmd pahse and data ready
    assign ctrl_wdata_valid_o = ctrl_gen_ahb_control && cmd_write_i;
    // Initializing CTRL module aacording to CMD signals
    assign ctrl_working_start = ~ctrl_cmd_ready_o && ctrl_cmd_valid_i && ~ctrl_working && ahb_read_write_ready;
    // Is the last CONTROL signals sended from AHB master
    assign ctrl_counter_full = ctrl_transfer_counter == cmd_transfer_len_i;
    // Is RDATA or WDATA finish
    assign ctrl_working_finish = ctrl_counter_full && ctrl_working;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_working <= 1'b0;
        end else begin
            if (ctrl_working_start) begin
                ctrl_working <= 1'b1;
            end else if (ctrl_working_finish) begin
                ctrl_working <= 1'b0;
            end
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_cmd_ready_o <= 1'b0;
        end else begin
            ctrl_cmd_ready_o <= ctrl_working_finish;
        end
    end

    // Generate ahb comman
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_transfer_counter <= 'd0;
            HADDR <= 'd0;
        end else begin
            if (ctrl_working_start) begin
                ctrl_transfer_counter <= 'd0;
                HADDR <= cmd_start_addr_i;
            end else begin
                if (ctrl_gen_ahb_control) begin
                    ctrl_transfer_counter <= ctrl_transfer_counter + 1;
                    case (cmd_burst_type_i)
                        2'b00: begin  // FIXED burst
                            HADDR <= HADDR;
                        end
                        2'b01: begin  // INC burst
                            HADDR <= HADDR_inc;
                        end
                        2'b10: begin  // WRAP burst
                            HADDR <= HADDR_wrap_en ? {HADDR[AXI_ADDR_WIDTH-1:2] - cmd_transfer_len_i} : HADDR_inc;
                        end
                        default: begin
                            HADDR <= HADDR_inc;
                        end
                    endcase
                end
            end
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            HBURST <= 'd0;
        end else begin
            if (cmd_error_i) begin
                HBURST <= 'd0;
            end else begin
                if (ctrl_gen_ahb_control) begin
                    case (cmd_burst_type_i)
                        2'b00: begin  // FIXED burst
                            HBURST <= 'd0;
                        end
                        2'b01: begin  // INC burst
                            HBURST <= 'd1;
                        end
                        2'b10: begin  // WRAP burst
                            case (cmd_transfer_len_i)
                                8'd3:  HBURST <= 3'b010;
                                8'd7:  HBURST <= 3'b100;
                                8'd15: HBURST <= 3'b110;
                                default: begin
                                    HBURST <= 'd0;
                                end
                            endcase
                        end
                        default: begin
                            HBURST <= 'd0;
                        end
                    endcase
                end else if (ctrl_working_finish) begin
                    HBURST <= 'd0;
                end
            end
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            HTRANS <= IDLE;
        end else begin
            HTRANS <= cmd_error_i ? IDLE : HTRANS_next;
        end
    end

    always @(*) begin
        if (ctrl_gen_ahb_control || ctrl_working) begin
            if (cmd_burst_type_i == 2'b10) begin
                // WRAP burst
                if (ctrl_counter_full) begin
                    HTRANS_next = NOSEQ;
                end else begin
                    case (HTRANS)
                        IDLE: begin
                            HTRANS_next = ctrl_gen_ahb_control ? NOSEQ : IDLE;
                        end
                        NOSEQ: begin
                            HTRANS_next = ctrl_gen_ahb_control ? SEQ : BUSY;
                        end
                        SEQ: begin
                            HTRANS_next = ctrl_gen_ahb_control ? SEQ : BUSY;
                        end
                        BUSY: begin
                            HTRANS_next = ctrl_gen_ahb_control ? NOSEQ : BUSY;
                        end
                        default: begin
                            HTRANS_next = IDLE;
                        end
                    endcase
                end
            end else begin
                // INC BURST
                HTRANS_next = NOSEQ;
            end
        end else begin
            // Terminating INC burst
            HTRANS_next = IDLE;
        end
    end


    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            HWRITE <= 1'b0;
        end else begin
            HWRITE <= ctrl_wdata_valid_o && !(cmd_error_i);
        end
    end


    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_rdata_valid_o  <= 1'b0;
            ctrl_next_cmd_phase <= 1'b0;
            ctrl_rdata_last_o   <= 1'b0;
        end else begin
            ctrl_next_cmd_phase <= ctrl_gen_ahb_control;
            ctrl_rdata_valid_o  <= ctrl_next_cmd_phase && cmd_read_i && ctrl_working;
            ctrl_rdata_last_o   <= ctrl_counter_full;
        end
    end

endmodule
