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
    wire [      AXI_ID_WIDTH-1:0] axi_awid;
    wire [    AXI_ADDR_WIDTH-1:0] axi_awaddr;
    wire [                   7:0] axi_awlen;
    wire [                   2:0] axi_awsize;
    wire [                   1:0] axi_awburst;
    wire                          axi_awvalid;
    wire                          axi_awready;

    // write data channel
    wire [    AXI_DATA_WIDTH-1:0] axi_wdata;
    wire [(AXI_DATA_WIDTH/8)-1:0] axi_wstrb;
    wire                          axi_wlast;
    wire                          axi_wvalid;
    wire                          axi_wready;

    // write response channel
    wire [      AXI_ID_WIDTH-1:0] axi_bid;
    wire [                   1:0] axi_bresp;
    wire                          axi_bvalid;
    wire                          axi_bready;

    // read address channel
    wire [      AXI_ID_WIDTH-1:0] axi_arid;
    wire [    AXI_ADDR_WIDTH-1:0] axi_araddr;
    wire [                   7:0] axi_arlen;
    wire [                   2:0] axi_arsize;
    wire [                   1:0] axi_arburst;
    wire                          axi_arvalid;
    wire                          axi_arready;

    // read data channel
    wire [      AXI_ID_WIDTH-1:0] axi_rid;
    wire [    AXI_DATA_WIDTH-1:0] axi_rdata;
    wire [                   1:0] axi_rresp;
    wire                          axi_rlast;
    wire                          axi_rvalid;
    wire                          axi_rready;


    // write address channel
    wire [      AXI_ID_WIDTH-1:0] s_axi_awid   [2:0];
    wire [    AXI_ADDR_WIDTH-1:0] s_axi_awaddr [2:0];
    wire [                   7:0] s_axi_awlen  [2:0];
    wire [                   2:0] s_axi_awsize [2:0];
    wire [                   1:0] s_axi_awburst[2:0];
    wire                          s_axi_awvalid[2:0];
    wire                          s_axi_awready[2:0];

    // write data channel
    wire [    AXI_DATA_WIDTH-1:0] s_axi_wdata  [2:0];
    wire [(AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb  [2:0];
    wire                          s_axi_wlast  [2:0];
    wire                          s_axi_wvalid [2:0];
    wire                          s_axi_wready [2:0];

    // write response channel
    wire [      AXI_ID_WIDTH-1:0] s_axi_bid    [2:0];
    wire [                   1:0] s_axi_bresp  [2:0];
    wire                          s_axi_bvalid [2:0];
    wire                          s_axi_bready [2:0];

    // read address channel
    wire [      AXI_ID_WIDTH-1:0] s_axi_arid   [2:0];
    wire [    AXI_ADDR_WIDTH-1:0] s_axi_araddr [2:0];
    wire [                   7:0] s_axi_arlen  [2:0];
    wire [                   2:0] s_axi_arsize [2:0];
    wire [                   1:0] s_axi_arburst[2:0];
    wire                          s_axi_arvalid[2:0];
    wire                          s_axi_arready[2:0];

    // read data channel
    wire [      AXI_ID_WIDTH-1:0] s_axi_rid    [2:0];
    wire [    AXI_DATA_WIDTH-1:0] s_axi_rdata  [2:0];
    wire [                   1:0] s_axi_rresp  [2:0];
    wire                          s_axi_rlast  [2:0];
    wire                          s_axi_rvalid [2:0];
    wire                          s_axi_rready [2:0];

    initial begin
        #0 aclk = 0;
        forever #(T / 2) aclk = ~aclk;
    end

    task aclk_wait;
        input integer n;
        begin
            repeat (n) @(posedge aclk);
        end
    endtask



    initial begin
        aresetn = 0;
        aclk_wait(5);
        aresetn = 1;
        aclk_wait(512);
        $finish;
    end

    axi_crossbar #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_SLAVE_PORT(3)
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
        .M_AXI_AWID   ({s_axi_awid[2], s_axi_awid[1], s_axi_awid[0]}),
        .M_AXI_AWADDR ({s_axi_awaddr[2], s_axi_awaddr[1], s_axi_awaddr[0]}),
        .M_AXI_AWLEN  ({s_axi_awlen[2], s_axi_awlen[1], s_axi_awlen[0]}),
        .M_AXI_AWSIZE ({s_axi_awsize[2], s_axi_awsize[1], s_axi_awsize[0]}),
        .M_AXI_AWBURST({s_axi_awburst[2], s_axi_awburst[1], s_axi_awburst[0]}),
        .M_AXI_AWVALID({s_axi_awvalid[2], s_axi_awvalid[1], s_axi_awvalid[0]}),
        .M_AXI_AWREADY({s_axi_awready[2], s_axi_awready[1], s_axi_awready[0]}),
        .M_AXI_WDATA  ({s_axi_wdata[2], s_axi_wdata[1], s_axi_wdata[0]}),
        .M_AXI_WSTRB  ({s_axi_wstrb[2], s_axi_wstrb[1], s_axi_wstrb[0]}),
        .M_AXI_WLAST  ({s_axi_wlast[2], s_axi_wlast[1], s_axi_wlast[0]}),
        .M_AXI_WVALID ({s_axi_wvalid[2], s_axi_wvalid[1], s_axi_wvalid[0]}),
        .M_AXI_WREADY ({s_axi_wready[2], s_axi_wready[1], s_axi_wready[0]}),
        .M_AXI_BID    ({s_axi_bid[2], s_axi_bid[1], s_axi_bid[0]}),
        .M_AXI_BRESP  ({s_axi_bresp[2], s_axi_bresp[1], s_axi_bresp[0]}),
        .M_AXI_BVALID ({s_axi_bvalid[2], s_axi_bvalid[1], s_axi_bvalid[0]}),
        .M_AXI_BREADY ({s_axi_bready[2], s_axi_bready[1], s_axi_bready[0]}),
        .M_AXI_ARID   ({s_axi_arid[2], s_axi_arid[1], s_axi_arid[0]}),
        .M_AXI_ARADDR ({s_axi_araddr[2], s_axi_araddr[1], s_axi_araddr[0]}),
        .M_AXI_ARLEN  ({s_axi_arlen[2], s_axi_arlen[1], s_axi_arlen[0]}),
        .M_AXI_ARSIZE ({s_axi_arsize[2], s_axi_arsize[1], s_axi_arsize[0]}),
        .M_AXI_ARBURST({s_axi_arburst[2], s_axi_arburst[1], s_axi_arburst[0]}),
        .M_AXI_ARVALID({s_axi_arvalid[2], s_axi_arvalid[1], s_axi_arvalid[0]}),
        .M_AXI_ARREADY({s_axi_arready[2], s_axi_arready[1], s_axi_arready[0]}),
        .M_AXI_RID    ({s_axi_rid[2], s_axi_rid[1], s_axi_rid[0]}),
        .M_AXI_RDATA  ({s_axi_rdata[2], s_axi_rdata[1], s_axi_rdata[0]}),
        .M_AXI_RRESP  ({s_axi_rresp[2], s_axi_rresp[1], s_axi_rresp[0]}),
        .M_AXI_RLAST  ({s_axi_rlast[2], s_axi_rlast[1], s_axi_rlast[0]}),
        .M_AXI_RVALID ({s_axi_rvalid[2], s_axi_rvalid[1], s_axi_rvalid[0]}),
        .M_AXI_RREADY ({s_axi_rready[2], s_axi_rready[1], s_axi_rready[0]})
    );

    genvar i;
    generate
        for (i = 0; i < 3; i = i + 1) begin : g_slave
            axi_slave #(
                .AXI_ID_WIDTH  (AXI_ID_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_SLAVE_ID  (i)
            ) axi_slave (
                .S_AXI_ACLK   (aclk),
                .S_AXI_ARESETN(aresetn),
                .S_AXI_AWID   (s_axi_awid[i]),
                .S_AXI_AWADDR (s_axi_awaddr[i]),
                .S_AXI_AWLEN  (s_axi_awlen[i]),
                .S_AXI_AWSIZE (s_axi_awsize[i]),
                .S_AXI_AWBURST(s_axi_awburst[i]),
                .S_AXI_AWVALID(s_axi_awvalid[i]),
                .S_AXI_AWREADY(s_axi_awready[i]),
                .S_AXI_WDATA  (s_axi_wdata[i]),
                .S_AXI_WSTRB  (s_axi_wstrb[i]),
                .S_AXI_WLAST  (s_axi_wlast[i]),
                .S_AXI_WVALID (s_axi_wvalid[i]),
                .S_AXI_WREADY (s_axi_wready[i]),
                .S_AXI_BID    (s_axi_bid[i]),
                .S_AXI_BRESP  (s_axi_bresp[i]),
                .S_AXI_BVALID (s_axi_bvalid[i]),
                .S_AXI_BREADY (s_axi_bready[i]),
                .S_AXI_ARID   (s_axi_arid[i]),
                .S_AXI_ARADDR (s_axi_araddr[i]),
                .S_AXI_ARLEN  (s_axi_arlen[i]),
                .S_AXI_ARSIZE (s_axi_arsize[i]),
                .S_AXI_ARBURST(s_axi_arburst[i]),
                .S_AXI_ARVALID(s_axi_arvalid[i]),
                .S_AXI_ARREADY(s_axi_arready[i]),
                .S_AXI_RID    (s_axi_rid[i]),
                .S_AXI_RDATA  (s_axi_rdata[i]),
                .S_AXI_RRESP  (s_axi_rresp[i]),
                .S_AXI_RLAST  (s_axi_rlast[i]),
                .S_AXI_RVALID (s_axi_rvalid[i]),
                .S_AXI_RREADY (s_axi_rready[i])
            );
        end
    endgenerate

    generate
        for (i = 0; i < 1; i = i + 1) begin : g_master
            axi_master #(
                .AXI_ID_WIDTH  (AXI_ID_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_MASTER_ID (i)
            ) axi_master (
                .aclk(aclk),
                .aresetn(aresetn),
                .axi_awid(axi_awid),
                .axi_awaddr(axi_awaddr),
                .axi_awlen(axi_awlen),
                .axi_awsize(axi_awsize),
                .axi_awburst(axi_awburst),
                .axi_awvalid(axi_awvalid),
                .axi_awready(axi_awready),
                .axi_wdata(axi_wdata),
                .axi_wstrb(axi_wstrb),
                .axi_wlast(axi_wlast),
                .axi_wvalid(axi_wvalid),
                .axi_wready(axi_wready),
                .axi_bid(axi_bid),
                .axi_bresp(axi_bresp),
                .axi_bvalid(axi_bvalid),
                .axi_bready(axi_bready),
                .axi_arid(axi_arid),
                .axi_araddr(axi_araddr),
                .axi_arlen(axi_arlen),
                .axi_arsize(axi_arsize),
                .axi_arburst(axi_arburst),
                .axi_arvalid(axi_arvalid),
                .axi_arready(axi_arready),
                .axi_rid(axi_rid),
                .axi_rdata(axi_rdata),
                .axi_rresp(axi_rresp),
                .axi_rlast(axi_rlast),
                .axi_rvalid(axi_rvalid),
                .axi_rready(axi_rready)
            );
        end
    endgenerate
endmodule
