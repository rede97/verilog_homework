module uart_tx_rx_tb;
    parameter DATA_WIDTH = 8;
    parameter DATA_DEPTH = 8;
    reg clk;
    reg rst_n;

    reg wr_vld;
    wire wr_rdy;
    reg [DATA_WIDTH-1:0] wr_data;

    wire tx_rdy;
    wire tx_vld;
    wire [DATA_WIDTH-1:0] tx_data;

    wire tx;
    wire tx_busy;

    wire rx_rdy;
    wire rx_vld;
    wire [7:0] rx_data;


    wire rd_vld;
    wire [7:0] rd_data;

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) fifo_tx (
        .clk_i(clk),
        .rstn_i(rst_n),
        .wr_rdy_o(wr_rdy),
        .wr_vld_i(wr_vld),
        .wr_data_i(wr_data),
        .rd_rdy_i(tx_rdy),
        .rd_vld_o(tx_vld),
        .rd_data_o(tx_data),
        .full_o(),
        .empty_o(),
        .elem_cnt_o()
    );

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_DEPTH(DATA_DEPTH)
    ) fifo_rx (
        .clk_i(clk),
        .rstn_i(rst_n),
        .wr_rdy_o(rx_rdy),
        .wr_vld_i(rx_vld),
        .wr_data_i(rx_data),
        .rd_rdy_i(1'b1),
        .rd_vld_o(rd_vld),
        .rd_data_o(rd_data),
        .full_o(),
        .empty_o(),
        .elem_cnt_o()
    );

    uart uart_dut (
        .clk_i(clk),
        .rst_n_i(rst_n),
        .cfg_en_i(1'b1),
        .cfg_div_i(12'd15),
        .cfg_bits_i(2'b11),
        .cfg_parity_en_i(1'b1),
        .cfg_stop_bits_i(1'b1),
        .tx_o(tx),
        .tx_busy_o(tx_busy),
        .tx_data_i(tx_data),
        .tx_vld_i(tx_vld),
        .tx_rdy_o(tx_rdy),
        .rx_i(tx),
        .rx_data_o(rx_data),
        .rx_vld_o(rx_vld),
        .rx_rdy_i(rx_rdy)
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
        wr_vld  = 0;
        wr_data = 0;
        wait_clk(1);
        rst_n = 1;
        $display("Clear reset");


        wait_clk(1024 * 512);
        $display("Problem");
        $finish;
    end

    task push(input [DATA_WIDTH-1:0] data);
        begin
            wait_clk(1);
            if (wr_rdy) begin
                wr_vld  = 1;
                wr_data = data;
                wait_clk(1);
                wr_vld  = 0;
                wr_data = 0;
                $display("push: 0x%0x", data);
            end else begin
                $display("Cannot push %d into fifo, full", data);
            end
        end
    endtask

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        end else begin
            if (rd_vld) begin
                $display("UART RX: 0x%0x", rd_data);
            end
        end
    end


    initial begin
        wait (rst_n == 1);
        wait_clk(8);
        push(8'h34);
        push(8'h23);
        push(8'ha3);


        wait (tx_vld == 0 && tx_busy == 0);
        wait_clk(128);

        $finish;
    end

endmodule
