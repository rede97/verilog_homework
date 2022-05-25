module sync_fifo_tb;
    parameter DATA_WIDTH = 32;
    parameter DATA_DEPTH = 8;

    reg                         clk;
    reg                         rst_n;

    reg                         wr_vld;
    wire                        wr_rdy;
    reg  [      DATA_WIDTH-1:0] wr_data;

    reg                         rd_rdy;
    wire                        rd_vld;
    wire [      DATA_WIDTH-1:0] rd_data;

    wire [$clog2(DATA_DEPTH):0] elem_cnt;
    wire                        full;
    wire                        empty;

    reg  [      DATA_WIDTH-1:0] temp_data;


    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) dut (
        .clk_i(clk),
        .rstn_i(rst_n),
        .wr_rdy_o(wr_rdy),
        .wr_vld_i(wr_vld),
        .wr_data_i(wr_data),
        .rd_rdy_i(rd_rdy),
        .rd_vld_o(rd_vld),
        .rd_data_o(rd_data),
        .full_o(full),
        .empty_o(empty),
        .elem_cnt_o(elem_cnt)
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
        rst_n     = 0;
        wr_vld    = 0;
        wr_data   = 0;
        rd_rdy    = 0;
        temp_data = 0;
        wait_clk(1);
        rst_n = 1;
        $display("Clear reset");
    end

    task push(input [DATA_WIDTH-1:0] data);
        begin
            wait_clk(1);
            if (!full) begin
                wr_vld  = 1;
                wr_data = data;
                wait_clk(1);
                wr_vld  = 0;
                wr_data = 0;
                $display("push[%0d]: %d", elem_cnt, data);
            end else begin
                $display("Cannot push %d into fifo, full", data);
            end
        end
    endtask

    task pop(output [DATA_WIDTH-1:0] data);
        begin
            wait_clk(1);
            if (!empty) begin
                if (rd_vld) begin
                    data   = rd_data;
                    rd_rdy = 1;
                    $display("Pop[%0d]: %d", elem_cnt, data);
                end else begin
                    $display("Pop: data invalid");
                end
                wait_clk(1);
                rd_rdy = 0;
                disable pop;
            end
            $display("Cannot pop data from fifo, empty");
        end
    endtask


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
