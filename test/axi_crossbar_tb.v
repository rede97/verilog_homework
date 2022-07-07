module axi_crossbar_tb;
    initial begin
        $dumpfile("axi_crossbar_tb.vcd");  //生成的vcd文件名称
        $dumpvars(0, axi_crossbar_tb);  //tb模块名称
        $timeformat(-9, 2, "ns", 4);
    end

    localparam integer T = 10;
    localparam integer AXI_ID_WIDTH = 2;
    localparam integer AXI_DATA_WIDTH = 32;
    localparam integer AXI_ADDR_WIDTH = 32;

    reg                           aclk;
    reg                           aresetn;

    // write address channel
    wire [      AXI_ID_WIDTH-1:0] axi_awid     [2:0];
    wire [    AXI_ADDR_WIDTH-1:0] axi_awaddr   [2:0];
    wire [                   7:0] axi_awlen    [2:0];
    wire [                   2:0] axi_awsize   [2:0];
    wire [                   1:0] axi_awburst  [2:0];
    wire                          axi_awvalid  [2:0];
    wire                          axi_awready  [2:0];

    // write data channel
    wire [    AXI_DATA_WIDTH-1:0] axi_wdata    [2:0];
    wire [(AXI_DATA_WIDTH/8)-1:0] axi_wstrb    [2:0];
    wire                          axi_wlast    [2:0];
    wire                          axi_wvalid   [2:0];
    wire                          axi_wready   [2:0];

    // write response channel
    wire [      AXI_ID_WIDTH-1:0] axi_bid      [2:0];
    wire [                   1:0] axi_bresp    [2:0];
    wire                          axi_bvalid   [2:0];
    wire                          axi_bready   [2:0];

    // read address channel
    wire [      AXI_ID_WIDTH-1:0] axi_arid     [2:0];
    wire [    AXI_ADDR_WIDTH-1:0] axi_araddr   [2:0];
    wire [                   7:0] axi_arlen    [2:0];
    wire [                   2:0] axi_arsize   [2:0];
    wire [                   1:0] axi_arburst  [2:0];
    wire                          axi_arvalid  [2:0];
    wire                          axi_arready  [2:0];

    // read data channel
    wire [      AXI_ID_WIDTH-1:0] axi_rid      [2:0];
    wire [    AXI_DATA_WIDTH-1:0] axi_rdata    [2:0];
    wire [                   1:0] axi_rresp    [2:0];
    wire                          axi_rlast    [2:0];
    wire                          axi_rvalid   [2:0];
    wire                          axi_rready   [2:0];


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

    wire [                   2:0] sim_finish;

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
        aclk_wait(1024 * 2);
        $finish;
    end

    axi_crossbar #(
        .AXI_ID_WIDTH   (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
        .AXI_SLAVE_PORT (3),
        .AXI_MASTER_PORT(3)
    ) axi_crossbar (
        .ACLK         (aclk),
        .ARESETN      (aresetn),
        // write address
        .S_AXI_AWID   ({axi_awid[2], axi_awid[1], axi_awid[0]}),
        .S_AXI_AWADDR ({axi_awaddr[2], axi_awaddr[1], axi_awaddr[0]}),
        .S_AXI_AWLEN  ({axi_awlen[2], axi_awlen[1], axi_awlen[0]}),
        .S_AXI_AWSIZE ({axi_awsize[2], axi_awsize[1], axi_awsize[0]}),
        .S_AXI_AWBURST({axi_awburst[2], axi_awburst[1], axi_awburst[0]}),
        .S_AXI_AWVALID({axi_awvalid[2], axi_awvalid[1], axi_awvalid[0]}),
        .S_AXI_AWREADY({axi_awready[2], axi_awready[1], axi_awready[0]}),
        // write data
        .S_AXI_WDATA  ({axi_wdata[2], axi_wdata[1], axi_wdata[0]}),
        .S_AXI_WSTRB  ({axi_wstrb[2], axi_wstrb[1], axi_wstrb[0]}),
        .S_AXI_WLAST  ({axi_wlast[2], axi_wlast[1], axi_wlast[0]}),
        .S_AXI_WVALID ({axi_wvalid[2], axi_wvalid[1], axi_wvalid[0]}),
        .S_AXI_WREADY ({axi_wready[2], axi_wready[1], axi_wready[0]}),
        // write response
        .S_AXI_BID    ({axi_bid[2], axi_bid[1], axi_bid[0]}),
        .S_AXI_BRESP  ({axi_bresp[2], axi_bresp[1], axi_bresp[0]}),
        .S_AXI_BVALID ({axi_bvalid[2], axi_bvalid[1], axi_bvalid[0]}),
        .S_AXI_BREADY ({axi_bready[2], axi_bready[1], axi_bready[0]}),
        // read address
        .S_AXI_ARID   ({axi_arid[2], axi_arid[1], axi_arid[0]}),
        .S_AXI_ARADDR ({axi_araddr[2], axi_araddr[1], axi_araddr[0]}),
        .S_AXI_ARLEN  ({axi_arlen[2], axi_arlen[1], axi_arlen[0]}),
        .S_AXI_ARSIZE ({axi_arsize[2], axi_arsize[1], axi_arsize[0]}),
        .S_AXI_ARBURST({axi_arburst[2], axi_arburst[1], axi_arburst[0]}),
        .S_AXI_ARVALID({axi_arvalid[2], axi_arvalid[1], axi_arvalid[0]}),
        .S_AXI_ARREADY({axi_arready[2], axi_arready[1], axi_arready[0]}),
        // read data
        .S_AXI_RID    ({axi_rid[2], axi_rid[1], axi_rid[0]}),
        .S_AXI_RDATA  ({axi_rdata[2], axi_rdata[1], axi_rdata[0]}),
        .S_AXI_RRESP  ({axi_rresp[2], axi_rresp[1], axi_rresp[0]}),
        .S_AXI_RLAST  ({axi_rlast[2], axi_rlast[1], axi_rlast[0]}),
        .S_AXI_RVALID ({axi_rvalid[2], axi_rvalid[1], axi_rvalid[0]}),
        .S_AXI_RREADY ({axi_rready[2], axi_rready[1], axi_rready[0]}),
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
        for (i = 0; i < 3; i = i + 1) begin : g_master
            axi_master #(
                .AXI_ID_WIDTH  (AXI_ID_WIDTH),
                .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
                .AXI_MASTER_ID (i)
            ) axi_master (
                .aclk       (aclk),
                .aresetn    (aresetn),
                .axi_awid   (axi_awid[i]),
                .axi_awaddr (axi_awaddr[i]),
                .axi_awlen  (axi_awlen[i]),
                .axi_awsize (axi_awsize[i]),
                .axi_awburst(axi_awburst[i]),
                .axi_awvalid(axi_awvalid[i]),
                .axi_awready(axi_awready[i]),
                .axi_wdata  (axi_wdata[i]),
                .axi_wstrb  (axi_wstrb[i]),
                .axi_wlast  (axi_wlast[i]),
                .axi_wvalid (axi_wvalid[i]),
                .axi_wready (axi_wready[i]),
                .axi_bid    (axi_bid[i]),
                .axi_bresp  (axi_bresp[i]),
                .axi_bvalid (axi_bvalid[i]),
                .axi_bready (axi_bready[i]),
                .axi_arid   (axi_arid[i]),
                .axi_araddr (axi_araddr[i]),
                .axi_arlen  (axi_arlen[i]),
                .axi_arsize (axi_arsize[i]),
                .axi_arburst(axi_arburst[i]),
                .axi_arvalid(axi_arvalid[i]),
                .axi_arready(axi_arready[i]),
                .axi_rid    (axi_rid[i]),
                .axi_rdata  (axi_rdata[i]),
                .axi_rresp  (axi_rresp[i]),
                .axi_rlast  (axi_rlast[i]),
                .axi_rvalid (axi_rvalid[i]),
                .axi_rready (axi_rready[i]),
                .sim_finish (sim_finish[i])
            );
        end
    endgenerate

    initial begin
        wait (aresetn == 1);
        wait (sim_finish == 3'b111);
        $display("TEST PASS");
        $finish;
    end
endmodule
