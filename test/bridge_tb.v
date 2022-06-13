module bridge_tb;
    initial begin
        $dumpfile("bridge_tb.vcd");  //生成的vcd文件名称
        $dumpvars(0, bridge_tb);  //tb模块名称
        $timeformat(-9, 2, "ns", 4);
    end

    localparam T = 10;
    localparam AXI_ID_WIDTH = 1;
    localparam AXI_DATA_WIDTH = 32;
    localparam AXI_ADDR_WIDTH = 8;

    reg aclk;
    reg aresetn;

    // write address channel
    reg [AXI_ID_WIDTH-1:0] axi_awid;
    reg [AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg [7:0] axi_awlen;
    reg [2:0] axi_awsize;
    reg [1:0] axi_awburst;
    reg axi_awvalid;
    wire axi_awready;

    // write data channel
    reg [AXI_DATA_WIDTH-1:0] axi_wdata;
    reg [(AXI_DATA_WIDTH/8)-1:0] axi_wstrb;
    reg axi_wlast;
    reg axi_wvalid;
    wire axi_wready;

    // write response channel
    wire [AXI_ID_WIDTH-1:0] axi_bid;
    wire [1:0] axi_bresp;
    wire axi_bvalid;
    reg axi_bready;

    // read address channel
    reg [AXI_ID_WIDTH-1:0] axi_arid;
    reg [AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg [7:0] axi_arlen;
    reg [2:0] axi_arsize;
    reg [1:0] axi_arburst;
    reg axi_arvalid;
    wire axi_arready;

    // read data channel
    wire [AXI_ID_WIDTH-1:0] axi_rid;
    wire [AXI_DATA_WIDTH-1:0] axi_rdata;
    wire [1:0] axi_rresp;
    wire axi_rlast;
    wire axi_rvalid;
    reg axi_rready;

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


    wire [ 7:0] haddr;
    wire [31:0] hwdata;
    wire [ 2:0] hburst;
    wire [ 2:0] hsize;
    wire        hwrite;
    wire [ 1:0] htrans;
    wire        hreadyout;
    wire        hreadyin;
    wire [31:0] hrdata;
    wire [ 1:0] hresp;

    axi2ahb #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) bridge (
        .ACLK   (aclk),
        .ARESETN(aresetn),
        // write address
        .AWID   (axi_awid),
        .AWADDR (axi_awaddr),
        .AWLEN  (axi_awlen),
        .AWSIZE (axi_awsize),
        .AWBURST(axi_awburst),
        .AWVALID(axi_awvalid),
        .AWREADY(axi_awready),
        // write data
        .WDATA  (axi_wdata),
        .WSTRB  (axi_wstrb),
        .WLAST  (axi_wlast),
        .WVALID (axi_wvalid),
        .WREADY (axi_wready),
        // write response
        .BID    (axi_bid),
        .BRESP  (axi_bresp),
        .BVALID (axi_bvalid),
        .BREADY (axi_bready),
        // read address
        .ARID   (axi_arid),
        .ARADDR (axi_araddr),
        .ARLEN  (axi_arlen),
        .ARSIZE (axi_arsize),
        .ARBURST(axi_arburst),
        .ARVALID(axi_arvalid),
        .ARREADY(axi_arready),
        // read data
        .RID    (axi_rid),
        .RDATA  (axi_rdata),
        .RRESP  (axi_rresp),
        .RLAST  (axi_rlast),
        .RVALID (axi_rvalid),
        .RREADY (axi_rready),
        // AHB
        .HADDR  (haddr),
        .HBURST (hburst),
        .HSIZE  (hsize),
        .HTRANS (htrans),
        .HWRITE (hwrite),
        .HWDATA (hwdata),
        .HREADY (hreadyout),
        .HRESP  (hresp[0]),
        .HRDATA (hrdata)
    );

    sramc_top u_sramc_top(                 //2.通过接口例化连接DUT顶层文件；结合1、2两步骤建立DUT与TB之间的连接
        .hclk(aclk),
        .sram_clk(~aclk),
        .hresetn(aresetn),  //给DUT
        .hsel(1'b1),  //给DUT
        .hwrite(hwrite),  //给DUT
        .htrans(htrans),  //给DUT
        .hsize(hsize),  //给DUT
        .hready(hreadyout),  //给DUT
        .hburst(3'b0),  //无用 burst没用的话就接0，在tr里面激励产生什么都关系不大了
        .haddr({24'h0, haddr}),  //给DUT
        .hwdata(hwdata),  //给DUT
        .hrdata(hrdata),  //给DUT
        .dft_en(1'b0),  //不测    dft不测，写成0
        .bist_en(1'b0),  //不测
        .hready_resp(hreadyout),
        .hresp(hresp),
        .bist_done(),  //不测
        .bist_fail()  //不测
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
        fork : arbit
            axi_read(16, 8, BURST_INC);
            axi_write(5, 8, BURST_WRAP);
        join
        axi_wait(4);
        for (idx = 0; idx < 8; idx = idx + 1) begin
            if (axi_wbuffer[idx] != axi_rbuffer[idx]) begin
                $display("Error: wdata:%x != rdata:%x %d", axi_wbuffer[idx], axi_rbuffer[idx], idx);
                $finish;
            end
        end
        $display("===TESTPASS===");

        $finish;
    end

endmodule
