module general_syncer (
    input  clk_i,
    input  reset_async,
    output reset_sync
);
    reg [1:0] reset_dff;
    assign reset_sync = reset_dff[1];

    // reset_dff
    always @(posedge clk or negedge reset_async) begin
        if (!reset_async) begin
            reset_dff <= 2'b00;
        end else begin
            reset_dff <= {reset_dff[0], 1'b1};
        end
    end
endmodule
