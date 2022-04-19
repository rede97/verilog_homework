module general_syncer_tb;
    reg clk;
    reg rst_n;
    reg [7:0] tempdata;
    wire [7:0] data;

    general_syncer #(
        .FISTR_EDGE(1),
        .LAST_EDGE(1),
        .MID_STAGE_NUM(1),
        .DATA_WIDTH(8)
    ) dut (
        .clk_i(clk),
        .rstn_i(rst_n),
        .data_unsync_i(tempdata),
        .data_synced_o(data)
    );

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    initial begin
        rst_n = 0;
        @(posedge clk);
        #1;
        rst_n = 1;
        #1000;
        $finish;
    end

    initial begin
        tempdata = 0;
        forever begin
            #1.67;
            tempdata = $random();
        end
    end


endmodule
