module sync_fifo_tb;
    parameter DATA_WIDTH = 32;
    parameter DATA_DEPTH = 8;

    reg clk;
    reg rst_n;

    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;

    reg rd_en;
    wire rd_data_vaild;
    wire [DATA_WIDTH-1:0] rd_data;

    wire [$clog2(DATA_DEPTH):0] elem_cnt;
    wire full;
    wire empty;

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en_i(wr_en),
        .wr_data_i(wr_data),
        .rd_en_i(rd_en),
        .rd_data_vaild_o(rd_data_vaild),
        .rd_data_o(rd_data),
        .elem_cnt_o(elem_cnt),
        .full_o(full),
        .empty_o(empty)
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
        rst_n   = 0;
        wr_en   = 0;
        wr_data = 0;
        rd_en   = 0;
        wait_clk(1);
        rst_n = 1;
        $display("Clear reset");
    end

    task push(input [DATA_WIDTH-1:0] data);
        begin
            if (!full) begin
                wr_en   = 1;
                wr_data = data;
                $display("push: %d", data);
                wait_clk(1);
                wr_en   = 0;
                wr_data = 0;
            end else begin
                $display("Cannot push %d into fifo, full", data);
            end
        end
    endtask

    task pop(output [DATA_WIDTH-1:0] data);
        begin
            if (!empty) begin
                rd_en = 1;
                wait_clk(1);
                if (rd_data_vaild) begin
                    data = rd_data;
                    $display("Pop: %d", data);
                end else begin
                    $display("Pop: data invaild");
                end
                rd_en = 0;
                disable pop;
            end
            $display("Cannot pop data from fifo, empty");
        end
    endtask


    reg [DATA_WIDTH-1:0] temp_data;
    initial begin
        @(posedge rst_n);
        wait_clk(1);

        pop(temp_data);
        pop(temp_data);
        pop(temp_data);
        pop(temp_data);
        push(5);
        push(6);
        push(7);
        push(8);
        push(9);
        push(10);
        push(11);
        push(12);
        push(13);
        push(14);

        pop(temp_data);
        pop(temp_data);
        pop(temp_data);
        fork
            push(23);
            pop(temp_data);
        join

        fork
            push(45);
            pop(temp_data);
        join
        pop(temp_data);
        pop(temp_data);
        pop(temp_data);
        pop(temp_data);
        pop(temp_data);
        pop(temp_data);
        pop(temp_data);

        wait_clk(8);
        $finish;
    end

endmodule
