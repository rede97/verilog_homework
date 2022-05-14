module ahb2apb_bridge #(
    parameter ADDR_WIDTH = 8
) (
    input  wire                  clk_i,
    input  wire                  rst_n_i,
    // AHB
    input  wire [ADDR_WIDTH-1:0] haddr_i,
    input  wire [          31:0] hwdata_i,
    input  wire                  hwrite_i,
    // input  wire [           2:0] hsize_i,
    // input  wire [           1:0] htrans_i,
    input  wire                  hsel_i,
    input  wire                  hready_i,
    output reg                   hready_o,
    output reg  [          31:0] hrdata_o,
    // output reg  [           1:0] hresp,
    // APB
    output reg                   psel_o,
    output reg                   penable_o,
    output reg  [ADDR_WIDTH-1:0] paddr_o,
    output reg                   pwrite_o,
    output wire [          31:0] pwdata_o,
    input  wire [          31:0] prdata_i,
    input  wire                  pready_i
);

    localparam [1:0] IDLE = 2'd0, SETUP = 2'd1, ACCESS = 2'd2;
    localparam [1:0] AHB_TRANS_IDLE = 2'b00;
    localparam [2:0] AHB_SIZE_32bit = 3'b010;

    wire       bridge_enable;
    reg  [1:0] apb_fsm_state;
    reg  [1:0] apb_fsm_state_next;

    wire       go_idle;
    wire       go_setup;
    wire       go_access;

    assign bridge_enable = hsel_i & hready_i;
    assign go_idle       = apb_fsm_state_next == IDLE;
    assign go_setup      = apb_fsm_state_next == SETUP;
    assign go_access     = apb_fsm_state_next == ACCESS;

    assign pwdata_o      = hwdata_i;

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            apb_fsm_state <= IDLE;
        end else begin
            apb_fsm_state <= apb_fsm_state_next;
        end
    end

    always @(*) begin
        case (apb_fsm_state)
            IDLE: begin
                if (bridge_enable && pready_i) begin
                    apb_fsm_state_next = SETUP;
                end else begin
                    apb_fsm_state_next = apb_fsm_state;
                end
            end
            SETUP: begin
                apb_fsm_state_next = ACCESS;
            end
            ACCESS: begin
                if (pready_i) begin
                    apb_fsm_state_next = IDLE;
                end else begin
                    apb_fsm_state_next = apb_fsm_state;
                end
            end
            default: begin
                apb_fsm_state_next = IDLE;
            end
        endcase
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            psel_o <= 1'b0;
            penable_o <= 1'b0;
            paddr_o <= 'd0;
            pwrite_o <= 1'b0;
        end else begin
            case (apb_fsm_state_next)
                IDLE: begin
                    psel_o <= 1'b0;
                    penable_o <= 1'b0;
                    paddr_o <= 'd0;
                    pwrite_o <= 1'b0;
                end
                SETUP: begin
                    psel_o <= 1'b1;
                    penable_o <= 1'b0;
                    paddr_o <= haddr_i;
                    pwrite_o <= hwrite_i;
                end
                ACCESS: begin
                    psel_o <= 1'b1;
                    penable_o <= 1'b1;
                    paddr_o <= paddr_o;
                    pwrite_o <= pwrite_o;
                end
                default: begin
                    psel_o <= 1'b0;
                    penable_o <= 1'b0;
                    paddr_o <= 'd0;
                    pwrite_o <= 1'b0;
                end
            endcase
        end
    end

    always @(posedge clk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            hready_o <= 1'b0;
            hrdata_o <= 32'h0;
        end
        begin
            if (go_idle) begin
                hready_o <= pready_i;
                hrdata_o <= prdata_i;
            end else begin
                hready_o <= 1'b0;
                hrdata_o <= hrdata_o;
            end
        end
    end

endmodule
