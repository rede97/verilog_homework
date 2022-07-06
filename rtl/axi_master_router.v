module axi_master_router #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Width of S_AXI data bus
    parameter integer AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8,
    // Slave interface number
    parameter integer AXI_SLAVE_PORT = 2,
    // AXI_ID_WIDTH + AXI_ADDR_WIDTH + S_AXI_AWLEN + S_AXI_AWSIZE + S_AXI_AWBURST
    parameter integer AXI_AWCHAN_WIDTH = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2,
    // AXI_DATA_WIDTH + S_AXI_WSTRB + S_AXI_WLAST
    parameter integer AXI_WDCHAN_WIDTH = AXI_DATA_WIDTH + (AXI_DATA_WIDTH / 8) + 1,
    // AXI_ID_WIDTH + S_AXI_BRESP
    parameter integer AXI_WBCHAN_WIDTH = AXI_ID_WIDTH + 2,
    // AXI_ID_WIDTH + AXI_ADDR_WIDTH + S_AXI_ARLEN + S_AXI_ARSIZE + S_AXI_ARBURST
    parameter integer AXI_ARCHAN_WIDTH = AXI_ID_WIDTH + AXI_ADDR_WIDTH + 8 + 3 + 2,
    // AXI_ID_WIDTH + AXI_DATA_WIDTH + S_AXI_RRESP + S_AXI_RLAST
    parameter integer AXI_RDCHAN_WIDTH = AXI_ID_WIDTH + AXI_DATA_WIDTH + 2 + 1
) (
    // Global Clock Signal
    input  wire                                         ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input  wire                                         ARESETN,
    // ==========================================================
    // Slave Write address channel
    // ==========================================================
    input  wire [                   AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
    input  wire [                 AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
    input  wire [                                7 : 0] S_AXI_AWLEN,
    input  wire [                                2 : 0] S_AXI_AWSIZE,
    input  wire [                                1 : 0] S_AXI_AWBURST,
    input  wire                                         S_AXI_AWVALID,
    output wire                                         S_AXI_AWREADY,
    // ==========================================================
    // Slave Write data channel
    // ==========================================================
    input  wire [                 AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
    input  wire [             (AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
    input  wire                                         S_AXI_WLAST,
    input  wire                                         S_AXI_WVALID,
    output wire                                         S_AXI_WREADY,
    // ==========================================================
    // Slave Write response channel
    // ==========================================================
    output wire [                   AXI_ID_WIDTH-1 : 0] S_AXI_BID,
    output wire [                                1 : 0] S_AXI_BRESP,
    output wire                                         S_AXI_BVALID,
    input  wire                                         S_AXI_BREADY,
    // ==========================================================
    // Slave Read address channel
    // ==========================================================
    input  wire [                   AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
    input  wire [                 AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
    input  wire [                                7 : 0] S_AXI_ARLEN,
    input  wire [                                2 : 0] S_AXI_ARSIZE,
    input  wire [                                1 : 0] S_AXI_ARBURST,
    input  wire                                         S_AXI_ARVALID,
    output wire                                         S_AXI_ARREADY,
    // ==========================================================
    // Slave Read data channel
    // ==========================================================
    output wire [                   AXI_ID_WIDTH-1 : 0] S_AXI_RID,
    output wire [                 AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
    output wire [                                1 : 0] S_AXI_RRESP,
    output wire                                         S_AXI_RLAST,
    output wire                                         S_AXI_RVALID,
    input  wire                                         S_AXI_RREADY,
    // ==========================================================
    // Master Write address channel
    // ==========================================================
    output wire [AXI_AWCHAN_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_AWCH_o,
    output wire [                   AXI_SLAVE_PORT-1:0] M_AXI_AWCH_VALID_o,
    input  wire [                   AXI_SLAVE_PORT-1:0] M_AXI_AWCH_READY_i,
    // ==========================================================
    // Master Write data channel
    // ==========================================================
    output wire [AXI_WDCHAN_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_WCH_o,
    output wire [                   AXI_SLAVE_PORT-1:0] M_AXI_WCH_VALID_o,
    input  wire [                   AXI_SLAVE_PORT-1:0] M_AXI_WCH_READY_i,
    // ==========================================================
    // Master Write response channel
    // ==========================================================
    input  wire [AXI_WBCHAN_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_BCH_i,
    input  wire [                   AXI_SLAVE_PORT-1:0] M_AXI_BCH_VALID_i,
    output wire [                   AXI_SLAVE_PORT-1:0] M_AXI_BCH_READY_o,
    // ==========================================================
    // Master Read address channel
    // ==========================================================
    output wire [AXI_ARCHAN_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_ARCH_o,
    output wire [                   AXI_SLAVE_PORT-1:0] M_AXI_ARCH_VALID_o,
    input  wire [                   AXI_SLAVE_PORT-1:0] M_AXI_ARCH_READY_i,
    // ==========================================================
    // Master Read data channel
    // ==========================================================
    input  wire [AXI_RDCHAN_WIDTH*AXI_SLAVE_PORT-1 : 0] M_AXI_RCH_i,
    input  wire [                   AXI_SLAVE_PORT-1:0] M_AXI_RCH_VALID_i,
    output wire [                   AXI_SLAVE_PORT-1:0] M_AXI_RCH_READY_o
);
    // Write channel decoder signals
    wire                          write_channel_ready;
    reg  [      AXI_SLAVE_PORT:0] write_channel_decoder_trgt;
    reg  [                   2:0] write_channel_tranfer_flag;
    wire [      AXI_SLAVE_PORT:0] aw_channel_decoder_trgt;
    wire [      AXI_SLAVE_PORT:0] wd_channel_decoder_trgt;
    wire [      AXI_SLAVE_PORT:0] wb_channel_decoder_trgt;

    // AW-Channel FIFO read signals
    wire [  AXI_AWCHAN_WIDTH-1:0] aw_chan_fifo_dat;
    wire                          aw_chan_fifo_vld;
    wire                          aw_chan_fifo_rdy;

    // WD-Channel FIFO read signals
    wire [  AXI_WDCHAN_WIDTH-1:0] wd_chan_fifo_dat;
    wire                          wd_chan_fifo_vld;
    wire                          wd_chan_fifo_rdy;

    // Read channel decoder signals
    wire                          read_channel_ready;
    reg  [      AXI_SLAVE_PORT:0] read_channel_decoder_trgt;
    reg  [                   1:0] read_channel_transfer_flag;
    wire [      AXI_SLAVE_PORT:0] ar_channel_decoder_trgt;
    wire [      AXI_SLAVE_PORT:0] rd_channel_decoder_trgt;

    // AR-Channel FIFO read signals
    wire [  AXI_ARCHAN_WIDTH-1:0] ar_chan_fifo_dat;
    wire                          ar_chan_fifo_vld;
    wire                          ar_chan_fifo_rdy;

    // Read Address Decoder
    wire [    AXI_ADDR_WIDTH-1:0] slv_read_decode_addr;
    wire [      AXI_SLAVE_PORT:0] slv_read_decode_trgt;
    // Write Address Decoder
    wire [    AXI_ADDR_WIDTH-1:0] slv_write_decode_addr;
    wire [      AXI_SLAVE_PORT:0] slv_write_decode_trgt;

    // Misrouting Write address channel
    wire [AXI_AWCHAN_WIDTH-1 : 0] MR_W_AXI_AWCH;
    wire                          MR_W_AXI_AWCH_VALID;
    wire                          MR_W_AXI_AWCH_READY;
    // Misrouting Write data channel
    wire [AXI_WDCHAN_WIDTH-1 : 0] MR_W_AXI_WCH;
    wire                          MR_W_AXI_WCH_VALID;
    wire                          MR_W_AXI_WCH_READY;
    // Misrouting Write response channel
    wire [AXI_WBCHAN_WIDTH-1 : 0] MR_W_AXI_BCH;
    wire                          MR_W_AXI_BCH_VALID;
    wire                          MR_W_AXI_BCH_READY;

    // Misrouting Read address channel
    wire [AXI_ARCHAN_WIDTH-1 : 0] MR_R_AXI_ARCH;
    wire                          MR_R_AXI_ARCH_VALID;
    wire                          MR_R_AXI_ARCH_READY;
    // Misrouting Read data channel
    wire [AXI_RDCHAN_WIDTH-1 : 0] MR_R_AXI_RCH;
    wire                          MR_R_AXI_RCH_VALID;
    wire                          MR_R_AXI_RCH_READY;


    // Write channel
    assign write_channel_ready = write_channel_tranfer_flag == 0;
    assign aw_channel_decoder_trgt = (write_channel_ready || write_channel_tranfer_flag[0]) ? slv_write_decode_trgt : 'd0;
    assign wd_channel_decoder_trgt = write_channel_tranfer_flag[1] ? write_channel_decoder_trgt:'d0;
    assign wb_channel_decoder_trgt = write_channel_tranfer_flag[2] ? write_channel_decoder_trgt:'d0;
    assign slv_write_decode_addr = aw_chan_fifo_vld ? aw_chan_fifo_dat[AXI_ADDR_WIDTH-1:0] : 'd0;
    // Read channel
    assign read_channel_ready = read_channel_transfer_flag == 0;
    assign ar_channel_decoder_trgt = (read_channel_ready || read_channel_transfer_flag[0]) ? slv_read_decode_trgt : 'd0;
    assign rd_channel_decoder_trgt = read_channel_transfer_flag[1] ? read_channel_decoder_trgt : 'd0;
    assign slv_read_decode_addr = ar_chan_fifo_vld ? ar_chan_fifo_dat[AXI_ADDR_WIDTH-1:0] : 'd0;

    // Update write channel decoder_trgt
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            write_channel_decoder_trgt <= 'd0;
            write_channel_tranfer_flag[2:0] <= 3'b0;
        end else begin
            if (aw_chan_fifo_vld && write_channel_ready) begin
                write_channel_decoder_trgt <= slv_write_decode_trgt;
                write_channel_tranfer_flag[2:0] <= 3'b111;
            end else begin
                if (aw_chan_fifo_rdy) begin
                    write_channel_tranfer_flag[0] <= 'b0;
                end
                if (wd_chan_fifo_rdy && wd_chan_fifo_dat[0]) begin
                    write_channel_tranfer_flag[1] <= 'b0;
                end
                if (S_AXI_BVALID && S_AXI_BREADY) begin
                    write_channel_tranfer_flag[2] <= 'b0;
                end
            end
        end
    end

    // Update read channel decoder_trgt
    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            read_channel_decoder_trgt  <= 'd0;
            read_channel_transfer_flag <= 2'b0;
        end else begin
            if (ar_chan_fifo_vld && read_channel_ready) begin
                read_channel_decoder_trgt  <= slv_read_decode_trgt;
                read_channel_transfer_flag <= 2'b11;
            end else begin
                if (ar_chan_fifo_rdy) begin
                    read_channel_transfer_flag[0] <= 1'b0;
                end
                if (S_AXI_RLAST && S_AXI_RVALID && S_AXI_RREADY) begin
                    read_channel_transfer_flag[1] <= 1'b0;
                end
            end
        end
    end

    // AW-Channel FIFO
    sync_fifo #(
        .DATA_WIDTH(AXI_AWCHAN_WIDTH),
        .DATA_DEPTH(32)
    ) aw_channel_fifo (
        .clk_i(ACLK),
        .rstn_i(ARESETN),
        .wr_rdy_o(S_AXI_AWREADY),
        .wr_vld_i(S_AXI_AWVALID),
        .wr_data_i({S_AXI_AWID, S_AXI_AWLEN, S_AXI_AWSIZE, S_AXI_AWBURST, S_AXI_AWADDR}),
        .rd_rdy_i(aw_chan_fifo_rdy),
        .rd_vld_o(aw_chan_fifo_vld),
        .rd_data_o(aw_chan_fifo_dat),
        .full_o(),
        .empty_o(),
        .elem_cnt_o()
    );

    // WD-Channel FIFO
    sync_fifo #(
        .DATA_WIDTH(AXI_WDCHAN_WIDTH),
        .DATA_DEPTH(32)
    ) wd_channel_fifo (
        .clk_i(ACLK),
        .rstn_i(ARESETN),
        .wr_rdy_o(S_AXI_WREADY),
        .wr_vld_i(S_AXI_WVALID),
        .wr_data_i({S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WLAST}),
        .rd_rdy_i(wd_chan_fifo_rdy),
        .rd_vld_o(wd_chan_fifo_vld),
        .rd_data_o(wd_chan_fifo_dat),
        .full_o(),
        .empty_o(),
        .elem_cnt_o()
    );

    // AR-Channel FIFO
    sync_fifo #(
        .DATA_WIDTH(AXI_ARCHAN_WIDTH),
        .DATA_DEPTH(32)
    ) ar_channel_fifo (
        .clk_i(ACLK),
        .rstn_i(ARESETN),
        .wr_rdy_o(S_AXI_ARREADY),
        .wr_vld_i(S_AXI_ARVALID),
        .wr_data_i({S_AXI_ARID, S_AXI_ARLEN, S_AXI_ARSIZE, S_AXI_ARBURST, S_AXI_ARADDR}),
        .rd_rdy_i(ar_chan_fifo_rdy),
        .rd_vld_o(ar_chan_fifo_vld),
        .rd_data_o(ar_chan_fifo_dat),
        .full_o(),
        .empty_o(),
        .elem_cnt_o()
    );


    // AW-Channel demux
    axis_demux #(
        .DATA_WIDTH(AXI_AWCHAN_WIDTH),
        .PORT_NUM  (AXI_SLAVE_PORT + 1)
    ) axi_aw_demux (
        .demux_ctrl_i(aw_channel_decoder_trgt),
        .s_axi_dat_i (aw_chan_fifo_dat),
        .s_axi_vld_i (aw_chan_fifo_vld),
        .s_axi_rdy_o (aw_chan_fifo_rdy),
        .m_axi_dat_o ({MR_W_AXI_AWCH, M_AXI_AWCH_o}),
        .m_axi_vld_o ({MR_W_AXI_AWCH_VALID, M_AXI_AWCH_VALID_o}),
        .m_axi_rdy_i ({MR_W_AXI_AWCH_READY, M_AXI_AWCH_READY_i})
    );

    // WD-Channel demux
    axis_demux #(
        .DATA_WIDTH(AXI_WDCHAN_WIDTH),
        .PORT_NUM  (AXI_SLAVE_PORT + 1)
    ) axi_wd_demux (
        .demux_ctrl_i(wd_channel_decoder_trgt),
        .s_axi_dat_i (wd_chan_fifo_dat),
        .s_axi_vld_i (wd_chan_fifo_vld),
        .s_axi_rdy_o (wd_chan_fifo_rdy),
        .m_axi_dat_o ({MR_W_AXI_WCH, M_AXI_WCH_o}),
        .m_axi_vld_o ({MR_W_AXI_WCH_VALID, M_AXI_WCH_VALID_o}),
        .m_axi_rdy_i ({MR_W_AXI_WCH_READY, M_AXI_WCH_READY_i})
    );

    // WB-Channel mux
    axis_mux #(
        .DATA_WIDTH(AXI_WBCHAN_WIDTH),
        .PORT_NUM  (AXI_SLAVE_PORT + 1)
    ) axi_wb_mux (
        .mux_ctrl_i (wb_channel_decoder_trgt),
        .s_axi_dat_i({MR_W_AXI_BCH, M_AXI_BCH_i}),
        .s_axi_vld_i({MR_W_AXI_BCH_VALID, M_AXI_BCH_VALID_i}),
        .s_axi_rdy_o({MR_W_AXI_BCH_READY, M_AXI_BCH_READY_o}),
        .m_axi_dat_o({S_AXI_BRESP, S_AXI_BID}),
        .m_axi_vld_o(S_AXI_BVALID),
        .m_axi_rdy_i(S_AXI_BREADY)
    );

    // AR-Channel demux
    axis_demux #(
        .DATA_WIDTH(AXI_ARCHAN_WIDTH),
        .PORT_NUM  (AXI_SLAVE_PORT + 1)
    ) axi_ar_demux (
        .demux_ctrl_i(ar_channel_decoder_trgt),
        .s_axi_dat_i (ar_chan_fifo_dat),
        .s_axi_vld_i (ar_chan_fifo_vld),
        .s_axi_rdy_o (ar_chan_fifo_rdy),
        .m_axi_dat_o ({MR_R_AXI_ARCH, M_AXI_ARCH_o}),
        .m_axi_vld_o ({MR_R_AXI_ARCH_VALID, M_AXI_ARCH_VALID_o}),
        .m_axi_rdy_i ({MR_R_AXI_ARCH_READY, M_AXI_ARCH_READY_i})
    );

    // RD-Channel mux
    axis_mux #(
        .DATA_WIDTH(AXI_RDCHAN_WIDTH),
        .PORT_NUM  (AXI_SLAVE_PORT + 1)
    ) axi_rd_mux (
        .mux_ctrl_i (rd_channel_decoder_trgt),
        .s_axi_dat_i({MR_R_AXI_RCH, M_AXI_RCH_i}),
        .s_axi_vld_i({MR_R_AXI_RCH_VALID, M_AXI_RCH_VALID_i}),
        .s_axi_rdy_o({MR_R_AXI_RCH_READY, M_AXI_RCH_READY_o}),
        .m_axi_dat_o({S_AXI_RDATA, S_AXI_RRESP, S_AXI_RLAST, S_AXI_RID}),
        .m_axi_vld_o(S_AXI_RVALID),
        .m_axi_rdy_i(S_AXI_RREADY)
    );

    axi_w_misrouting #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) write_misrouting_port (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_AWCH_i(MR_W_AXI_AWCH),
        .S_AXI_AWCH_VALID_i(MR_W_AXI_AWCH_VALID),
        .S_AXI_AWCH_READY_o(MR_W_AXI_AWCH_READY),
        .S_AXI_WCH_i(MR_W_AXI_WCH),
        .S_AXI_WCH_VALID_i(MR_W_AXI_WCH_VALID),
        .S_AXI_WCH_READY_o(MR_W_AXI_WCH_READY),
        .S_AXI_BCH_o(MR_W_AXI_BCH),
        .S_AXI_BCH_VALID_o(MR_W_AXI_BCH_VALID),
        .S_AXI_BCH_READY_i(MR_W_AXI_BCH_READY)
    );

    axi_r_misrouting #(
        .AXI_ID_WIDTH  (AXI_ID_WIDTH),
        .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) read_misrouting_port (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXI_ARCH_i(MR_R_AXI_ARCH),
        .S_AXI_ARCH_VALID_i(MR_R_AXI_ARCH_VALID),
        .S_AXI_ARCH_READY_o(MR_R_AXI_ARCH_READY),
        .S_AXI_RCH_o(MR_R_AXI_RCH),
        .S_AXI_RCH_VALID_o(MR_R_AXI_RCH_VALID),
        .S_AXI_RCH_READY_i(MR_R_AXI_RCH_READY)
    );

    axi_addr_decoder #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_PORT_NUM  (AXI_SLAVE_PORT)
    ) axi_write_addr_decoder (
        .addr_i(slv_write_decode_addr),
        .trgt_o(slv_write_decode_trgt)
    );

    axi_addr_decoder #(
        .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
        .AXI_PORT_NUM  (AXI_SLAVE_PORT)
    ) axi_read_addr_decoder (
        .addr_i(slv_read_decode_addr),
        .trgt_o(slv_read_decode_trgt)
    );

endmodule
