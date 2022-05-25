module async_fifo_tb;

    localparam DATA_WIDTH = 8;

    // system reset
    reg                   rst_n;
    // write interface
    reg                   wr_clk;
    reg                   wr_en;
    reg  [DATA_WIDTH-1:0] wr_data;
    wire                  full;
    // read Interface
    reg                   rd_clk;
    reg                   rd_en;
    wire [DATA_WIDTH-1:0] rd_data;
    wire                  empty;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(8)
    ) fifo (
        .rstn_i  (rst_n),
        // write interface
        .wr_clk_i (wr_clk),
        .wr_en_i  (wr_en),
        .wr_data_i(wr_data),
        .full_o   (full),
        // read interface
        .rd_clk_i (rd_clk),
        .rd_en_i  (rd_en),
        .rd_data_o(rd_data),
        .empty_o  (empty)
    );

    initial begin
        rst_n = 0;
        #50;
        rst_n = 1;
        #10000;
        $finish;
    end

    initial begin
        wr_clk  = 0;
        wr_en   = 0;
        wr_data = 0;
        forever begin
            #10 wr_clk = ~wr_clk;
        end
    end

    initial begin
        rd_clk = 0;
        rd_en  = 0;
        forever begin
            #7 rd_clk = ~rd_clk;
        end
    end

    task wait_wr_clk(input integer n);
        repeat (n) begin
            @(posedge wr_clk);
            #1;
        end
    endtask

    task wait_rd_clk(input integer n);
        repeat (n) begin
            @(posedge rd_clk);
            #1;
        end
    endtask

    task push(input [DATA_WIDTH-1:0] wdata);
        forever begin
            wait_wr_clk(1);
            if (!full) begin
                $display("Push %d", wdata);
                wr_data = wdata;
                wr_en   = 1;
                wait_wr_clk(1);
                wr_en = 0;
                disable push;
            end
        end
    endtask

    task pop(output [DATA_WIDTH-1:0] rdata);
        forever begin
            wait_rd_clk(1);
            if (!empty) begin
                rd_en = 1;
                wait_rd_clk(1);
                rd_en = 0;
                rdata = rd_data;
                $display("Pop %d", rdata);
                disable push;
            end
        end
    endtask

    initial begin
        @(posedge rst_n);
        repeat (32) begin
            push($random());
        end
        #1000;
        $finish;
    end

    reg [DATA_WIDTH-1:0] temp;
    initial begin
        @(posedge rst_n);
        forever begin
            pop(temp);
        end
    end


endmodule
