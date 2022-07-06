module axi_master #(
    parameter integer AXI_ID_WIDTH   = 1,
    parameter integer AXI_DATA_WIDTH = 32,
    parameter integer AXI_ADDR_WIDTH = 32,
    parameter integer AXI_MASTER_ID  = 0
) (
    input wire aclk,
    input wire aresetn,

    // write address channel
    output wire [      AXI_ID_WIDTH-1:0] axi_awid,
    output reg  [    AXI_ADDR_WIDTH-1:0] axi_awaddr,
    output reg  [                   7:0] axi_awlen,
    output reg  [                   2:0] axi_awsize,
    output reg  [                   1:0] axi_awburst,
    output reg                           axi_awvalid,
    input  wire                          axi_awready,
    // write data channel
    output reg  [    AXI_DATA_WIDTH-1:0] axi_wdata,
    output reg  [(AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
    output reg                           axi_wlast,
    output reg                           axi_wvalid,
    input  wire                          axi_wready,
    // write response channel
    input  wire [      AXI_ID_WIDTH-1:0] axi_bid,
    input  wire [                   1:0] axi_bresp,
    input  wire                          axi_bvalid,
    output reg                           axi_bready,
    // read address channel
    output reg  [      AXI_ID_WIDTH-1:0] axi_arid,
    output reg  [    AXI_ADDR_WIDTH-1:0] axi_araddr,
    output reg  [                   7:0] axi_arlen,
    output reg  [                   2:0] axi_arsize,
    output reg  [                   1:0] axi_arburst,
    output reg                           axi_arvalid,
    input  wire                          axi_arready,
    // read data channel
    input  wire [      AXI_ID_WIDTH-1:0] axi_rid,
    input  wire [    AXI_DATA_WIDTH-1:0] axi_rdata,
    input  wire [                   1:0] axi_rresp,
    input  wire                          axi_rlast,
    input  wire                          axi_rvalid,
    output reg                           axi_rready
);
    assign axi_awid = AXI_MASTER_ID;

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
        input [AXI_ADDR_WIDTH-1:0] raddr;
        input [7:0] rlen;
        input [1:0] burst;
        integer addr_cnt;
        begin
            axi_araddr  <= raddr;
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
                            axi_rbuffer[addr_cnt] = axi_rdata;
                            addr_cnt = addr_cnt + 1;
                        end
                    end
                    if (axi_rresp != 2'b00) begin
                        if (axi_rresp == 2'b10) begin
                            $display("[%m]#%t Slave Error: 0x%08x", $time, raddr);
                        end else if (axi_rresp == 2'b11) begin
                            $display("[%m]#%t Decode Error: 0x%08x", $time, raddr);
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
        input [AXI_ADDR_WIDTH-1:0] waddr;
        input [7:0] wlen;
        input [1:0] burst;
        integer addr_cnt;
        begin
            axi_awaddr <= waddr;
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
                            if (axi_bresp == 2'b10) begin
                                $display("[%m]#%t Slave Error: 0x%08x", $time, waddr);
                            end else if (axi_bresp == 2'b11) begin
                                $display("[%m]#%t Decode Error: 0x%08x", $time, waddr);
                            end
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


    localparam integer BURST_FIXED = 2'b00, BURST_INC = 2'b01, BURST_WRAP = 2'b10;

    initial begin
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
    end

    integer idx;
    initial begin
        wait (aresetn == 1);
        repeat (5) @(posedge aclk);
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
        axi_write(32'h9000_0000, 32, BURST_INC);
        axi_wait(4);
        axi_write(32'h1000_0000, 32, BURST_INC);


        $display("[%0d]===Write TESTPASS===", AXI_MASTER_ID);
        axi_read(32'h9000_0000, 8, BURST_INC);
        $display("[%0d]===Read TESTPASS===", AXI_MASTER_ID);
        axi_read(32'h1000_0000, 32, BURST_INC);
        axi_wait(16);
        $finish;
    end

endmodule
