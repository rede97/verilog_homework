module axi_slave_router #(
    // Width of ID for for write address, write data, read address and read data
    parameter integer AXI_ID_WIDTH = 1,
    // Width of S_AXI data bus
    parameter integer AXI_DATA_WIDTH = 32,
    // Width of S_AXI address bus
    parameter integer AXI_ADDR_WIDTH = 8,
    // Master interface number
    parameter integer AXI_MASTER_PORT = 2,
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
    input  wire                                          ACLK,
    // Global Reset Signal. This Signal is Active LOW
    input  wire                                          ARESETN,
    // ==========================================================
    // Master Write address channel
    // ==========================================================
    output wire [                    AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
    output wire [                  AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
    output wire [                                 7 : 0] M_AXI_AWLEN,
    output wire [                                 2 : 0] M_AXI_AWSIZE,
    output wire [                                 1 : 0] M_AXI_AWBURST,
    output wire                                          M_AXI_AWVALID,
    input  wire                                          M_AXI_AWREADY,
    // ==========================================================
    // Master Write data channel
    // ==========================================================
    output wire [                  AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
    output wire [              (AXI_DATA_WIDTH/8)-1 : 0] M_AXI_WSTRB,
    output wire                                          M_AXI_WLAST,
    output wire                                          M_AXI_WVALID,
    input  wire                                          M_AXI_WREADY,
    // ==========================================================
    // Master Write response channel
    // ==========================================================
    input  wire [                    AXI_ID_WIDTH-1 : 0] M_AXI_BID,
    input  wire [                                 1 : 0] M_AXI_BRESP,
    input  wire                                          M_AXI_BVALID,
    output wire                                          M_AXI_BREADY,
    // ==========================================================
    // Master Read address channel
    // ==========================================================
    output wire [                    AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
    output wire [                  AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
    output wire [                                 7 : 0] M_AXI_ARLEN,
    output wire [                                 2 : 0] M_AXI_ARSIZE,
    output wire [                                 1 : 0] M_AXI_ARBURST,
    output wire                                          M_AXI_ARVALID,
    input  wire                                          M_AXI_ARREADY,
    // ==========================================================
    // Master Read data channel
    // ==========================================================
    input  wire [                    AXI_ID_WIDTH-1 : 0] M_AXI_RID,
    input  wire [                  AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
    input  wire [                                 1 : 0] M_AXI_RRESP,
    input  wire                                          M_AXI_RLAST,
    input  wire                                          M_AXI_RVALID,
    output wire                                          M_AXI_RREADY,
    // ==========================================================
    // Slave Write address channel
    // ==========================================================
    input  wire [AXI_AWCHAN_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_AWCH_i,
    input  wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_AWCH_VALID_i,
    output wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_AWCH_READY_o,
    // ==========================================================
    // Slave Write data channel
    // ==========================================================
    input  wire [AXI_WDCHAN_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_WCH_i,
    input  wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_WCH_VALID_i,
    output wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_WCH_READY_o,
    // ==========================================================
    // Slave Write response channel
    // ==========================================================
    output wire [AXI_WBCHAN_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_BCH_o,
    output wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_BCH_VALID_o,
    input  wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_BCH_READY_i,
    // ==========================================================
    // Slave Read address channel
    // ==========================================================
    input  wire [AXI_ARCHAN_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_ARCH_i,
    input  wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_ARCH_VALID_i,
    output wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_ARCH_READY_o,
    // ==========================================================
    // Slave Read data channel
    // ==========================================================
    output wire [AXI_RDCHAN_WIDTH*AXI_MASTER_PORT-1 : 0] S_AXI_RCH_o,
    output wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_RCH_VALID_o,
    input  wire [                 AXI_MASTER_PORT-1 : 0] S_AXI_RCH_READY_i
);
    // Write channel arbiter
    wire                        write_channel_ready;
    wire [ AXI_MASTER_PORT-1:0] mst_write_arbiter_gnt;
    wire [ AXI_MASTER_PORT-1:0] aw_chan_arbiter_gnt;
    wire [ AXI_MASTER_PORT-1:0] wd_chan_arbiter_gnt;
    reg  [ AXI_MASTER_PORT-1:0] write_channel_arbiter_gnt;
    reg  [                 1:0] write_channel_transfer_flag;

    // Read channel arboter
    wire [ AXI_MASTER_PORT-1:0] read_channel_arbiter_gnt;
    wire [ AXI_MASTER_PORT-1:0] ar_chan_arboter_gnt;

    // WB-Channel fifo read signal
    wire [AXI_WBCHAN_WIDTH-1:0] wb_chan_fifo_dat;
    wire                        wb_chan_fifo_vld;
    wire                        wb_chan_fifo_rdy;

    // RD-Channel fifo read signal
    wire [AXI_RDCHAN_WIDTH-1:0] rd_chan_fifo_dat;
    wire                        rd_chan_fifo_vld;
    wire                        rd_chan_fifo_rdy;

    // Master read resp decoder
    wire [    AXI_ID_WIDTH-1:0] mst_read_resp_decode_id;
    wire [ AXI_MASTER_PORT-1:0] mst_read_resp_decode_trgt;
    // Master write resp decoder
    wire [    AXI_ID_WIDTH-1:0] mst_write_resp_decode_id;
    wire [ AXI_MASTER_PORT-1:0] mst_write_resp_decode_trgt;

    assign write_channel_ready = write_channel_transfer_flag == 0;
    assign aw_chan_arbiter_gnt = write_channel_ready ? mst_write_arbiter_gnt :
                                (write_channel_transfer_flag[0]) ? write_channel_arbiter_gnt : 'd0;
    assign wd_chan_arbiter_gnt = (write_channel_transfer_flag[1]) ? write_channel_arbiter_gnt : 'd0;

    assign mst_write_resp_decode_id = wb_chan_fifo_dat[AXI_ID_WIDTH-1:0];

    assign ar_chan_arboter_gnt = read_channel_arbiter_gnt;
    assign mst_read_resp_decode_id = rd_chan_fifo_dat[AXI_ID_WIDTH-1:0];

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            write_channel_arbiter_gnt   <= 'd0;
            write_channel_transfer_flag <= 2'b0;
        end else begin
            if (S_AXI_AWCH_VALID_i && write_channel_ready) begin
                write_channel_arbiter_gnt   <= mst_write_arbiter_gnt;
                write_channel_transfer_flag <= 2'b11;
            end else begin
                if (M_AXI_AWREADY) begin
                    write_channel_transfer_flag[0] <= 1'b0;
                end
                if (M_AXI_WLAST && M_AXI_WREADY) begin
                    write_channel_transfer_flag[1] <= 1'b0;
                end
            end
        end
    end

    axi_crossbar_arbiter #(
        .AXI_REQUEST_NUM(AXI_MASTER_PORT)
    ) axi_aw_arbiter (
        .ACLK      (ACLK),
        .ARESETN   (ARESETN),
        .requests_i(S_AXI_AWCH_VALID_i),
        .arbiter_o (mst_write_arbiter_gnt)
    );

    axi_crossbar_arbiter #(
        .AXI_REQUEST_NUM(AXI_MASTER_PORT)
    ) axi_ar_arbiter (
        .ACLK      (ACLK),
        .ARESETN   (ARESETN),
        .requests_i(S_AXI_ARCH_VALID_i),
        .arbiter_o (read_channel_arbiter_gnt)
    );

    // AW-Channel mux
    axis_mux #(
        .DATA_WIDTH(AXI_AWCHAN_WIDTH),
        .PORT_NUM  (AXI_MASTER_PORT)
    ) axi_aw_mux (
        .mux_ctrl_i (aw_chan_arbiter_gnt),
        .s_axi_dat_i(S_AXI_AWCH_i),
        .s_axi_vld_i(S_AXI_AWCH_VALID_i),
        .s_axi_rdy_o(S_AXI_AWCH_READY_o),
        .m_axi_dat_o({M_AXI_AWID, M_AXI_AWLEN, M_AXI_AWSIZE, M_AXI_AWBURST, M_AXI_AWADDR}),
        .m_axi_vld_o(M_AXI_AWVALID),
        .m_axi_rdy_i(M_AXI_AWREADY)
    );

    // WD-Channel mux
    axis_mux #(
        .DATA_WIDTH(AXI_WDCHAN_WIDTH),
        .PORT_NUM  (AXI_MASTER_PORT)
    ) axi_wd_mux (
        .mux_ctrl_i (wd_chan_arbiter_gnt),
        .s_axi_dat_i(S_AXI_WCH_i),
        .s_axi_vld_i(S_AXI_WCH_VALID_i),
        .s_axi_rdy_o(S_AXI_WCH_READY_o),
        .m_axi_dat_o({M_AXI_WDATA, M_AXI_WSTRB, M_AXI_WLAST}),
        .m_axi_vld_o(M_AXI_WVALID),
        .m_axi_rdy_i(M_AXI_WREADY)
    );

    // WB-Channel demux
    axis_demux #(
        .DATA_WIDTH(AXI_WBCHAN_WIDTH),
        .PORT_NUM  (AXI_MASTER_PORT)
    ) axi_wb_demux (
        .demux_ctrl_i(mst_write_resp_decode_trgt),
        .s_axi_dat_i (wb_chan_fifo_dat),
        .s_axi_vld_i (wb_chan_fifo_vld),
        .s_axi_rdy_o (wb_chan_fifo_rdy),
        .m_axi_dat_o (S_AXI_BCH_o),
        .m_axi_vld_o (S_AXI_BCH_VALID_o),
        .m_axi_rdy_i (S_AXI_BCH_READY_i)
    );

    // AR-Channel mux
    axis_mux #(
        .DATA_WIDTH(AXI_ARCHAN_WIDTH),
        .PORT_NUM  (AXI_MASTER_PORT)
    ) axi_ar_mux (
        .mux_ctrl_i (ar_chan_arboter_gnt),
        .s_axi_dat_i(S_AXI_ARCH_i),
        .s_axi_vld_i(S_AXI_ARCH_VALID_i),
        .s_axi_rdy_o(S_AXI_ARCH_READY_o),
        .m_axi_dat_o({M_AXI_ARID, M_AXI_ARLEN, M_AXI_ARSIZE, M_AXI_ARBURST, M_AXI_ARADDR}),
        .m_axi_vld_o(M_AXI_ARVALID),
        .m_axi_rdy_i(M_AXI_ARREADY)
    );

    // RD-Channel demux
    axis_demux #(
        .DATA_WIDTH(AXI_RDCHAN_WIDTH),
        .PORT_NUM  (AXI_MASTER_PORT)
    ) axi_rd_demux (
        .demux_ctrl_i(mst_read_resp_decode_trgt),
        .s_axi_dat_i (rd_chan_fifo_dat),
        .s_axi_vld_i (rd_chan_fifo_vld),
        .s_axi_rdy_o (rd_chan_fifo_rdy),
        .m_axi_dat_o (S_AXI_RCH_o),
        .m_axi_vld_o (S_AXI_RCH_VALID_o),
        .m_axi_rdy_i (S_AXI_RCH_READY_i)
    );

    // WB-Channel FIFO
    sync_fifo #(
        .DATA_WIDTH(AXI_WBCHAN_WIDTH),
        .DATA_DEPTH(32)
    ) wb_channel_fifo (
        .clk_i     (ACLK),
        .rstn_i    (ARESETN),
        .wr_rdy_o  (M_AXI_BREADY),
        .wr_vld_i  (M_AXI_BVALID),
        .wr_data_i ({M_AXI_BRESP, M_AXI_BID}),
        .rd_rdy_i  (wb_chan_fifo_rdy),
        .rd_vld_o  (wb_chan_fifo_vld),
        .rd_data_o (wb_chan_fifo_dat),
        .full_o    (),
        .empty_o   (),
        .elem_cnt_o()
    );

    sync_fifo #(
        .DATA_WIDTH(AXI_RDCHAN_WIDTH),
        .DATA_DEPTH(32)
    ) rd_channel_fifo (
        .clk_i     (ACLK),
        .rstn_i    (ARESETN),
        .wr_rdy_o  (M_AXI_RREADY),
        .wr_vld_i  (M_AXI_RVALID),
        .wr_data_i ({M_AXI_RDATA, M_AXI_RRESP, M_AXI_RLAST, M_AXI_RID}),
        .rd_rdy_i  (rd_chan_fifo_rdy),
        .rd_vld_o  (rd_chan_fifo_vld),
        .rd_data_o (rd_chan_fifo_dat),
        .full_o    (),
        .empty_o   (),
        .elem_cnt_o()
    );

    axi_id_decoder #(
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_PORT_NUM(AXI_MASTER_PORT)
    ) master_write_id (
        .id_i (mst_write_resp_decode_id),
        .gnt_o(mst_write_resp_decode_trgt)
    );

    axi_id_decoder #(
        .AXI_ID_WIDTH(AXI_ID_WIDTH),
        .AXI_PORT_NUM(AXI_MASTER_PORT)
    ) master_read_id (
        .id_i (mst_read_resp_decode_id),
        .gnt_o(mst_read_resp_decode_trgt)
    );

endmodule
