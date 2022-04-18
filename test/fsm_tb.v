module fsm_tb;
    reg clk;
    reg rst_n;

    reg [3:0] data;
    wire found;

    reg [1:0] seed;
    integer found_cnt;
    integer continuous_found_cnt;

    localparam EXPECT_CONTINUOUS_FOUNT_CNT = 3;

    fsm dut (
        .clk_i  (clk),
        .rst_n_i(rst_n),
        .data_i (data),
        .found_o(found)
    );

    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    task wait_clk(input integer n);
        begin
            repeat (n) begin
                @(posedge clk);
            end
            #1;
        end
    endtask

    initial begin
        rst_n = 0;
        wait_clk(3);
        rst_n = 1;
    end

    // Times of found
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            found_cnt <= 0;
        end else begin
            if (found) begin
                found_cnt <= found_cnt + 1;
            end
        end
    end

    // Contionous times of found
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            continuous_found_cnt <= 0;
        end else begin
            if (found) begin
                continuous_found_cnt <= continuous_found_cnt + 4;
            end else begin
                if (continuous_found_cnt > 0) begin
                    continuous_found_cnt <= continuous_found_cnt - 1;
                end
            end
        end
    end

    always @(posedge clk) begin
        // running until continuous_found_cnt equal EXPECT_CONTINUOUS_FOUNT_CNT
        if (found && continuous_found_cnt == (EXPECT_CONTINUOUS_FOUNT_CNT - 1)) begin
            wait_clk(1);
            $display("Found %d", found_cnt);
            $finish;
        end
    end

    initial begin
        @(posedge rst_n);
        forever begin
            wait_clk(1);
            seed = $random();
            if (3 == seed) begin
                data = 4;
            end else begin
                data = {2'b00, seed};
            end
        end
    end

    initial begin
        #1000000000;
        $finish;
    end

endmodule
