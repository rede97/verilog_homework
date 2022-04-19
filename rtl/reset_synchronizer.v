module reset_synchronizer (
    input  wire clk_i,
    input  wire rstn_unsync_i,
    output wire rstn_sync_o
);
    reg [1:0] reset_dff;
    assign rstn_sync_o = reset_dff[1];

    // reset_dff
    always @(posedge clk_i or negedge rstn_unsync_i) begin
        if (!rstn_unsync_i) begin
            reset_dff <= 2'b00;
        end else begin
            reset_dff <= {reset_dff[0], 1'b1};
        end
    end
endmodule
