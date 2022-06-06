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
    // CMD interface
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
    output wire                      ctrl_rdata_valid_o,
    output wire                      ctrl_rdata_last_o,
    // CTRL-WDATA interface
    input  wire                      ctrl_wdata_last_i,
    input  wire                      ctrl_wdata_ready_i,
    output wire                      ctrl_wdata_valid_o
);
    localparam [1:0] IDLE = 2'b00, NOSEQ = 2'b10, SEQ = 2'b11, BUSY = 2'b01;

    reg  [               7:0] ctrl_transfer_counter;
    reg                       ctrl_working_flag;
    reg  [               1:0] HTRANS_next;
    reg                       ctrl_data_phase;

    wire                      ahb_read_write_ready;
    wire [AXI_ADDR_WIDTH-1:0] HADDR_inc;
    wire                      ctrl_go_working;
    wire                      ctrl_go_idle;
    wire                      ctrl_write_finish;
    wire                      ctrl_read_finish;

    assign HSIZE = 3'b010;

    assign ahb_read_write_ready = cmd_read_i ? ctrl_rdata_ready_i : (cmd_write_i ? ctrl_wdata_ready_i : 1'b0);
    assign HADDR_inc = {HADDR[AXI_ADDR_WIDTH-1:2] + 1, 2'b00};

    assign ctrl_go_working = ~ctrl_cmd_ready_o && ctrl_cmd_valid_i && ~ctrl_working_flag;
    assign ctrl_write_finish = cmd_write_i && ctrl_wdata_ready_i && ctrl_wdata_last_i;
    assign ctrl_read_finish = cmd_read_i && ctrl_rdata_ready_i && ctrl_rdata_valid_o && (ctrl_transfer_counter == cmd_transfer_len_i);
    assign ctrl_go_idle = ctrl_read_finish || ctrl_write_finish;

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_working_flag <= 1'b0;
            ctrl_cmd_ready_o  <= 1'b0;
        end else begin
            if (ctrl_go_working) begin
                ctrl_working_flag <= 1'b1;
                ctrl_cmd_ready_o  <= 1'b0;
            end else if (ctrl_go_idle) begin
                ctrl_working_flag <= 1'b0;
                ctrl_cmd_ready_o  <= 1'b1;
            end else begin
                ctrl_cmd_ready_o <= 1'b0;
            end
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_transfer_counter <= 'd0;
            HADDR <= 'd0;
        end else begin
            if (ctrl_go_working) begin
                ctrl_transfer_counter <= 'd0;
                HADDR <= cmd_start_addr_i;
            end else begin
                if ((ctrl_transfer_counter <= cmd_transfer_len_i) && ahb_read_write_ready && HREADY) begin
                    ctrl_transfer_counter <= ctrl_transfer_counter + 1;
                    case (cmd_burst_type_i)
                        2'b00: begin  // FIXED burst
                            HADDR <= HADDR;
                        end
                        2'b01: begin  // INC burst
                            HADDR <= HADDR_inc;
                        end
                        2'b10: begin  // WRAP burst
                            HADDR <= HADDR_inc & cmd_transfer_len_i;
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
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            HTRANS <= IDLE;
        end else begin
            HTRANS <= HTRANS_next;
        end
    end

    always @(*) begin
        if (HTRANS == IDLE) begin
            if (ctrl_go_working || (ctrl_working_flag && ahb_read_write_ready)) begin
                HTRANS_next = NOSEQ;
            end else begin
                HTRANS_next = HTRANS;
            end
        end else begin
            // NOSEQ or SEQ
            if (ctrl_go_idle) begin
                HTRANS_next = IDLE;
            end else begin
                if (cmd_burst_type_i == 2'b10) begin
                    // WRAP burst
                    if (!ahb_read_write_ready) begin
                        HTRANS_next = BUSY;
                    end else begin
                        HTRANS_next = SEQ;
                    end
                end else begin
                    // Terminating INC burst
                    if (!ahb_read_write_ready) begin
                        HTRANS_next = IDLE;
                    end else begin
                        HTRANS_next = NOSEQ;
                    end
                end
            end
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            ctrl_data_phase <= 1'b0;
        end else begin
            ctrl_data_phase <= ctrl_working_flag;
        end
    end

endmodule
