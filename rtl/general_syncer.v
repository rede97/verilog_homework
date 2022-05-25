module general_syncer #(
    parameter FISTR_EDGE    = 1,  // first register latch edge option, 1: posedge, 0, negedge
    parameter LAST_EDGE     = 1,  // last register latch edge option, 1: posedge, 0, negedge
    parameter MID_STAGE_NUM = 1,  // stage of middle dffs to sync data, MID_STAGE_NUM >= 0
    parameter DATA_WIDTH    = 32
) (
    input  wire                  clk_i,          // dest clock
    input  wire                  rstn_i,         // reset input
    input  wire [DATA_WIDTH-1:0] data_unsync_i,  // async input
    output wire [DATA_WIDTH-1:0] data_synced_o   // sync output
);
    // DFFs
    reg [DATA_WIDTH-1:0] first_stage;  // first stage dff
    reg [DATA_WIDTH-1:0] last_stage;  // last stage dff
    reg [DATA_WIDTH-1:0] middle_stage[0:MID_STAGE_NUM-1];  // middle stage dff

    // Middle output stage data
    wire [DATA_WIDTH-1:0] middle_stage_data;

    // Output data from last stage
    assign data_synced_o = last_stage;

    // First stage
    generate
        if (FISTR_EDGE == 0) begin
            always @(negedge clk_i or negedge rstn_i) begin
                if (!rstn_i) begin
                    first_stage <= 'h0;
                end else begin
                    first_stage <= data_unsync_i;
                end
            end
        end else begin
            always @(posedge clk_i or negedge rstn_i) begin
                if (!rstn_i) begin
                    first_stage <= 'h0;
                end else begin
                    first_stage <= data_unsync_i;
                end
            end
        end
    endgenerate

    // Middle stage
    genvar i;
    generate
        if (MID_STAGE_NUM == 0) begin
            assign middle_stage_data = first_stage;
        end else begin
            assign middle_stage_data = middle_stage[MID_STAGE_NUM-1];
            always @(posedge clk_i or negedge rstn_i) begin
                if (!rstn_i) begin
                    middle_stage[0] <= 'h0;
                end else begin
                    middle_stage[0] <= first_stage;
                end
            end
            for (i = 1; i < MID_STAGE_NUM; i = i + 1) begin : gen_middle_stage
                always @(posedge clk_i or negedge rstn_i) begin
                    if (!rstn_i) begin
                        middle_stage[i] <= 'h0;
                    end else begin
                        middle_stage[i] <= middle_stage[i-1];
                    end
                end
            end
        end
    endgenerate

    // Last stage
    generate
        if (LAST_EDGE == 0) begin
            always @(negedge clk_i or negedge rstn_i) begin
                if (!rstn_i) begin
                    last_stage <= 'h0;
                end else begin
                    last_stage <= middle_stage_data;
                end
            end
        end else begin
            always @(posedge clk_i or negedge rstn_i) begin
                if (!rstn_i) begin
                    last_stage <= 'h0;
                end else begin
                    last_stage <= middle_stage_data;
                end
            end
        end
    endgenerate


endmodule
