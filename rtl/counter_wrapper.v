module counter_wrpper #(
    parameter CNT_WIDTH = 5
) (
    input wire clk_i,  // clock input
    input wire rstn_i, // system reset

    input wire cnt_en_i,       // counter enable
    input wire cnt_forbiden_i, // counter disable

    output wire [CNT_WIDTH-1:0] addr_o,     // address output
    output wire [  CNT_WIDTH:0] ptr_gray_o  // pointer output
);
    reg [CNT_WIDTH:0] counter;  // internal counter, 1-bit more than address
    assign addr_o = counter[CNT_WIDTH-1:0];

    // update counter
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            counter <= 'h0;
        end else begin
            if (cnt_en_i && !cnt_forbiden_i) begin
                counter <= counter + 'h1;
            end
        end
    end

    // convert pointer to gray code
    bin2gray #(
        .DATA_WIDTH(CNT_WIDTH + 1)
    ) bin2gray_u0 (
        .data_bin_i (counter),
        .data_gray_o(ptr_gray_o)
    );

endmodule
