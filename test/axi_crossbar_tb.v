module axi_crossbar_tb;
    initial begin
        $dumpfile("axi_crossbar_tb.vcd");  //生成的vcd文件名称
        $dumpvars(0, axi_crossbar_tb);  //tb模块名称
        $timeformat(-9, 2, "ns", 4);
    end

    localparam integer T = 10;
    localparam integer AXI_ID_WIDTH = 1;
    localparam integer AXI_DATA_WIDTH = 32;
    localparam integer AXI_ADDR_WIDTH = 32;

    reg                           aclk;
    reg                           aresetn;

    // write address channel
    reg  [      AXI_ID_WIDTH-1:0] axi_awid;
    reg  [    AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg  [                   7:0] axi_awlen;
    reg  [                   2:0] axi_awsize;
    reg  [                   1:0] axi_awburst;
    reg                           axi_awvalid;
    wire                          axi_awready;

    // write data channel
    reg  [    AXI_DATA_WIDTH-1:0] axi_wdata;
    reg  [(AXI_DATA_WIDTH/8)-1:0] axi_wstrb;
    reg                           axi_wlast;
    reg                           axi_wvalid;
    wire                          axi_wready;

    // write response channel
    wire [      AXI_ID_WIDTH-1:0] axi_bid;
    wire [                   1:0] axi_bresp;
    wire                          axi_bvalid;
    reg                           axi_bready;

    // read address channel
    reg  [      AXI_ID_WIDTH-1:0] axi_arid;
    reg  [    AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg  [                   7:0] axi_arlen;
    reg  [                   2:0] axi_arsize;
    reg  [                   1:0] axi_arburst;
    reg                           axi_arvalid;
    wire                          axi_arready;

    // read data channel
    wire [      AXI_ID_WIDTH-1:0] axi_rid;
    wire [    AXI_DATA_WIDTH-1:0] axi_rdata;
    wire [                   1:0] axi_rresp;
    wire                          axi_rlast;
    wire                          axi_rvalid;
    reg                           axi_rready;


    // write address channel
    wire [      AXI_ID_WIDTH-1:0] s0_axi_awid;
    wire [    AXI_ADDR_WIDTH-1:0] s0_axi_awaddr;
    wire [                   7:0] s0_axi_awlen;
    wire [                   2:0] s0_axi_awsize;
    wire [                   1:0] s0_axi_awburst;
    wire                          s0_axi_awvalid;
    wire                          s0_axi_awready;

    // write data channel
    wire [    AXI_DATA_WIDTH-1:0] s0_axi_wdata;
    wire [(AXI_DATA_WIDTH/8)-1:0] s0_axi_wstrb;
    wire                          s0_axi_wlast;
    wire                          s0_axi_wvalid;
    wire                          s0_axi_wready;

    // write response channel
    wire [      AXI_ID_WIDTH-1:0] s0_axi_bid;
    wire [                   1:0] s0_axi_bresp;
    wire                          s0_axi_bvalid;
    wire                          s0_axi_bready;

    // read address channel
    wire [      AXI_ID_WIDTH-1:0] s0_axi_arid;
    wire [    AXI_ADDR_WIDTH-1:0] s0_axi_araddr;
    wire [                   7:0] s0_axi_arlen;
    wire [                   2:0] s0_axi_arsize;
    wire [                   1:0] s0_axi_arburst;
    wire                          s0_axi_arvalid;
    wire                          s0_axi_arready;

    // read data channel
    wire [      AXI_ID_WIDTH-1:0] s0_axi_rid;
    wire [    AXI_DATA_WIDTH-1:0] s0_axi_rdata;
    wire [                   1:0] s0_axi_rresp;
    wire                          s0_axi_rlast;
    wire                          s0_axi_rvalid;
    wire                          s0_axi_rready;

    initial begin
        #0 aclk = 0;
        forever #(T / 2) aclk = ~aclk;
    end

    initial begin
        axi_awid = 0;
        axi_awaddr = 0;
        axi_awlen = 0;
        axi_awsize = 0;
        axi_awburst = 0;
        axi_awvalid = 0;

        axi_wdata = 0;
        axi_wstrb = 0;
        axi_wlast = 0;
        axi_wvalid = 0;

        axi_bready = 0;

        axi_arid = 0;
        axi_araddr = 0;
        axi_arlen = 0;
        axi_arsize = 0;
        axi_arburst = 0;

        axi_arvalid = 0;
        axi_rready = 0;

        axi_wait(1024 * 2);
        $display("timeout");
        $finish;
    end

    axi_crossbar #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) axi_crossbar (
        .ACLK         (aclk),
        .ARESETN      (aresetn),
        // write address
        .S_AXI_AWID   (axi_awid),
        .S_AXI_AWADDR (axi_awaddr),
        .S_AXI_AWLEN  (axi_awlen),
        .S_AXI_AWSIZE (axi_awsize),
        .S_AXI_AWBURST(axi_awburst),
        .S_AXI_AWVALID(axi_awvalid),
        .S_AXI_AWREADY(axi_awready),
        // write data
        .S_AXI_WDATA  (axi_wdata),
        .S_AXI_WSTRB  (axi_wstrb),
        .S_AXI_WLAST  (axi_wlast),
        .S_AXI_WVALID (axi_wvalid),
        .S_AXI_WREADY (axi_wready),
        // write response
        .S_AXI_BID    (axi_bid),
        .S_AXI_BRESP  (axi_bresp),
        .S_AXI_BVALID (axi_bvalid),
        .S_AXI_BREADY (axi_bready),
        // read address
        .S_AXI_ARID   (axi_arid),
        .S_AXI_ARADDR (axi_araddr),
        .S_AXI_ARLEN  (axi_arlen),
        .S_AXI_ARSIZE (axi_arsize),
        .S_AXI_ARBURST(axi_arburst),
        .S_AXI_ARVALID(axi_arvalid),
        .S_AXI_ARREADY(axi_arready),
        // read data
        .S_AXI_RID    (axi_rid),
        .S_AXI_RDATA  (axi_rdata),
        .S_AXI_RRESP  (axi_rresp),
        .S_AXI_RLAST  (axi_rlast),
        .S_AXI_RVALID (axi_rvalid),
        .S_AXI_RREADY (axi_rready),
        // Slave
        .M_AXI_AWID   (s0_axi_awid),
        .M_AXI_AWADDR (s0_axi_awaddr),
        .M_AXI_AWLEN  (s0_axi_awlen),
        .M_AXI_AWSIZE (s0_axi_awsize),
        .M_AXI_AWBURST(s0_axi_awburst),
        .M_AXI_AWVALID(s0_axi_awvalid),
        .M_AXI_AWREADY(s0_axi_awready),
        .M_AXI_WDATA  (s0_axi_wdata),
        .M_AXI_WSTRB  (s0_axi_wstrb),
        .M_AXI_WLAST  (s0_axi_wlast),
        .M_AXI_WVALID (s0_axi_wvalid),
        .M_AXI_WREADY (s0_axi_wready),
        .M_AXI_BID    (s0_axi_bid),
        .M_AXI_BRESP  (s0_axi_bresp),
        .M_AXI_BVALID (s0_axi_bvalid),
        .M_AXI_BREADY (s0_axi_bready),
        .M_AXI_ARID   (s0_axi_arid),
        .M_AXI_ARADDR (s0_axi_araddr),
        .M_AXI_ARLEN  (s0_axi_arlen),
        .M_AXI_ARSIZE (s0_axi_arsize),
        .M_AXI_ARBURST(s0_axi_arburst),
        .M_AXI_ARVALID(s0_axi_arvalid),
        .M_AXI_ARREADY(s0_axi_arready),
        .M_AXI_RID    (s0_axi_rid),
        .M_AXI_RDATA  (s0_axi_rdata),
        .M_AXI_RRESP  (s0_axi_rresp),
        .M_AXI_RLAST  (s0_axi_rlast),
        .M_AXI_RVALID (s0_axi_rvalid),
        .M_AXI_RREADY (s0_axi_rready)
    );


    axi_slave #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) axi_slave_0 (
        .S_AXI_ACLK   (aclk),
        .S_AXI_ARESETN(aresetn),
        .S_AXI_AWID   (s0_axi_awid),
        .S_AXI_AWADDR (s0_axi_awaddr),
        .S_AXI_AWLEN  (s0_axi_awlen),
        .S_AXI_AWSIZE (s0_axi_awsize),
        .S_AXI_AWBURST(s0_axi_awburst),
        .S_AXI_AWVALID(s0_axi_awvalid),
        .S_AXI_AWREADY(s0_axi_awready),
        .S_AXI_WDATA  (s0_axi_wdata),
        .S_AXI_WSTRB  (s0_axi_wstrb),
        .S_AXI_WLAST  (s0_axi_wlast),
        .S_AXI_WVALID (s0_axi_wvalid),
        .S_AXI_WREADY (s0_axi_wready),
        .S_AXI_BID    (s0_axi_bid),
        .S_AXI_BRESP  (s0_axi_bresp),
        .S_AXI_BVALID (s0_axi_bvalid),
        .S_AXI_BREADY (s0_axi_bready),
        .S_AXI_ARID   (s0_axi_arid),
        .S_AXI_ARADDR (s0_axi_araddr),
        .S_AXI_ARLEN  (s0_axi_arlen),
        .S_AXI_ARSIZE (s0_axi_arsize),
        .S_AXI_ARBURST(s0_axi_arburst),
        .S_AXI_ARVALID(s0_axi_arvalid),
        .S_AXI_ARREADY(s0_axi_arready),
        .S_AXI_RID    (s0_axi_rid),
        .S_AXI_RDATA  (s0_axi_rdata),
        .S_AXI_RRESP  (s0_axi_rresp),
        .S_AXI_RLAST  (s0_axi_rlast),
        .S_AXI_RVALID (s0_axi_rvalid),
        .S_AXI_RREADY (s0_axi_rready)
    );

    localparam BURST_FIXED = 2'b00, BURST_INC = 2'b01, BURST_WRAP = 2'b10;

    task axi_wait;
        input integer n;
        begin
            repeat (n) @(posedge aclk);
        end
    endtask

    task axi_arclr;
        begin
            axi_araddr  <= 0;
            axi_arlen   <= 0;
            axi_arburst <= 0;
            axi_arsize  <= 0;
            axi_arvalid <= 0;
        end
    endtask

    task axi_rclr;
        begin
            axi_rready <= 0;
        end
    endtask

    task axi_awclr;
        begin
            axi_awaddr  <= 0;
            axi_awlen   <= 0;
            axi_awburst <= 0;
            axi_awsize  <= 0;
            axi_awvalid <= 0;
        end
    endtask

    task axi_wclr;
        begin
            axi_wdata  <= 0;
            axi_wstrb  <= 0;
            axi_wlast  <= 0;
            axi_wvalid <= 0;
        end
    endtask

    task axi_bclr;
        begin
            axi_bready <= 0;
        end
    endtask

    reg [31:0] axi_wbuffer[255:0];
    reg [31:0] axi_rbuffer[255:0];
    task axi_read;
        input [AXI_ADDR_WIDTH-3:0] raddr;
        input [7:0] rlen;
        input [1:0] burst;
        integer addr_cnt;
        begin
            axi_araddr  <= {raddr, 2'b00};
            axi_arlen   <= rlen - 1;
            axi_arburst <= burst;
            axi_arsize  <= 3'b010;
            axi_arvalid <= 1'b1;
            addr_cnt = 0;
            // wait arready
            repeat (16) begin
                axi_wait(1);
                if (axi_arready) begin
                    axi_arclr;
                    // start read
                    axi_rready <= 1'b1;
                    while (addr_cnt < rlen) begin
                        axi_wait(1);
                        if (axi_rvalid) begin
                            if (axi_rresp != 2'b00) begin
                                $display("[%m]#%t ERROR: Invalid rresp: %d", $time, axi_bresp);
                                $stop;
                            end
                            axi_rbuffer[addr_cnt] = axi_rdata;
                            addr_cnt = addr_cnt + 1;
                        end
                    end
                    axi_rclr;
                    disable axi_read;
                end
            end
            $display("[%m]#%t ERROR: Timeout, wait arready", $time);
            $stop;
        end
    endtask

    task axi_write;
        input [AXI_ADDR_WIDTH-3:0] waddr;
        input [7:0] wlen;
        input [1:0] burst;
        integer addr_cnt;
        begin
            axi_awaddr <= {waddr, 2'b00};
            axi_awlen <= wlen - 1;
            axi_awburst <= burst;
            axi_awsize <= 3'b010;
            axi_awvalid <= 1'b1;
            addr_cnt <= 0;
            // wait awready
            repeat (16) begin
                axi_wait(1);
                while (!axi_awready) begin
                    axi_wait(1);
                end
                axi_awclr;
                while (addr_cnt < wlen) begin
                    // start write
                    axi_wvalid <= 1'b1;
                    axi_wstrb  <= 4'b1111;
                    if (addr_cnt + 1 == wlen) begin
                        axi_wlast <= 1'b1;
                    end
                    axi_wdata <= axi_wbuffer[addr_cnt];
                    axi_wait(1);
                    if (axi_wready) begin
                        addr_cnt = addr_cnt + 1;
                        axi_wclr;
                        // axi_wait(2);

                    end
                end
                axi_wait(1);
                axi_wclr;
                // wait bresp
                repeat (16) begin
                    axi_wait(1);
                    if (axi_bvalid) begin
                        if (axi_bresp != 2'b00) begin
                            $display("[%m]#%t ERROR: Invalid bresp: %d", $time, axi_bresp);
                            $stop;
                        end
                        axi_bready <= 1'b1;
                        axi_wait(1);
                        axi_bclr;
                        disable axi_write;
                    end
                end
                $display("[%m]#%t ERROR: Timeout, wait bresp", $time);
                $stop;
            end
            $display("[%m]#%t ERROR: Timeout, wait awready", $time);
            $stop;
        end
    endtask


    integer idx;
    initial begin
        aresetn = 1'b0;
        repeat (5) @(posedge aclk);
        aresetn = 1'b1;
        axi_wbuffer[0] = 32'h03;
        axi_write(0, 1, BURST_INC);
        axi_wbuffer[0]  = 32'h64343962;
        axi_wbuffer[1]  = 32'h39623732;
        axi_wbuffer[2]  = 32'h64343339;
        axi_wbuffer[3]  = 32'h38306533;
        axi_wbuffer[4]  = 32'h65323561;
        axi_wbuffer[5]  = 32'h37643235;
        axi_wbuffer[6]  = 32'h64376164;
        axi_wbuffer[7]  = 32'h61666261;
        axi_wbuffer[8]  = 32'h34383463;
        axi_wbuffer[9]  = 32'h33656665;
        axi_wbuffer[10] = 32'h33356137;
        axi_wbuffer[11] = 32'h65653038;
        axi_wbuffer[12] = 32'h38383039;
        axi_wbuffer[13] = 32'h63613766;
        axi_wbuffer[14] = 32'h66653265;
        axi_wbuffer[15] = 32'h39656463;
        axi_wbuffer[16] = 32'h00000080;
        axi_wbuffer[17] = 32'h00000000;
        axi_wbuffer[18] = 32'h00000000;
        axi_wbuffer[19] = 32'h00000000;
        axi_wbuffer[20] = 32'h00000000;
        axi_wbuffer[21] = 32'h00000000;
        axi_wbuffer[22] = 32'h00000000;
        axi_wbuffer[23] = 32'h00000000;
        axi_wbuffer[24] = 32'h00000000;
        axi_wbuffer[25] = 32'h00000000;
        axi_wbuffer[26] = 32'h00000000;
        axi_wbuffer[27] = 32'h00000000;
        axi_wbuffer[28] = 32'h00000000;
        axi_wbuffer[29] = 32'h00000000;
        axi_wbuffer[30] = 32'h00000000;
        axi_wbuffer[31] = 32'h00020000;
        axi_write(16, 32, BURST_INC);
        axi_wait(4);

        $display("===Write TESTPASS===");
        axi_read(16, 32, BURST_INC);
        $display("===Read TESTPASS===");

        $finish;
    end
endmodule
