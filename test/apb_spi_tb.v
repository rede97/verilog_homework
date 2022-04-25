`define CMD 4'd0
`define ADDR 4'd1
`define LEN 4'd2
`define WDATA 4'd3
`define RDATA 4'd4
`define CTRL 4'd5

module apb_spi_tb;
    reg         pclk;
    reg         rst_n;
    reg         psel;
    reg         penable;
    reg  [ 3:0] paddr;
    reg         pwrite;
    reg  [31:0] pwdata;
    wire [31:0] prdata;
    wire        pready;

    wire        spi_clk;
    reg         spi_sdi;
    wire        spi_sdo;
    wire        spi_cs_n;

    apb_spi_master dut (
        .pclk_i    (pclk),
        .rst_n_i   (rst_n),
        .psel_i    (psel),
        .penable_i (penable),
        .paddr_i   (paddr),
        .pwrite_i  (pwrite),
        .pwdata_i  (pwdata),
        .prdata_o  (prdata),
        .pready_o  (pready),
        // SPI interface
        .spi_clk_o (spi_clk),
        .spi_sdo_o (spi_sdo),
        .spi_cs_n_o(spi_cs_n),
        .spi_sdi_i (spi_sdi)
    );

    initial begin
        pclk = 0;
        forever begin
            #5 pclk = ~pclk;
        end
    end

    task aclk_wait(input integer n);
        begin
            repeat (n) begin
                @(posedge pclk);
            end
            #1;
        end
    endtask

    task apb_clr();
        begin
            psel = 0;
            penable = 0;
            pwrite = 0;
            pwdata = 0;
            paddr = 0;
        end
    endtask

    task apb_read(input [3:0] addr, output [31:0] rdata);
        begin
            aclk_wait(1);
            psel   = 1;
            pwrite = 0;
            paddr  = addr;
            aclk_wait(1);
            penable = 1;
            aclk_wait(1);
            while (!pready) begin
                aclk_wait(1);
            end
            rdata = prdata;
            apb_clr();
            $display("APB read [%d] = 0x%08x", addr, rdata);
        end
    endtask

    task apb_write(input [3:0] addr, input [31:0] wdata);
        begin
            aclk_wait(1);
            psel   = 1;
            pwrite = 1;
            paddr  = addr;
            pwdata = wdata;
            aclk_wait(1);
            penable = 1;
            aclk_wait(1);
            while (!pready) begin
                aclk_wait(1);
            end
            apb_clr();
            $display("APB write [%d] = 0x%08x", addr, wdata);
        end
    endtask

    initial begin
        spi_sdi = 0;
        apb_clr();
        rst_n = 0;
        aclk_wait(5);
        rst_n = 1;

        aclk_wait(1000);
        $finish;
    end

    reg [31:0] tmp_data;
    initial begin
        tmp_data = 0;
        wait (rst_n == 1);
        aclk_wait(1);
        apb_write(`CMD, 'b1010);  // write Read-CMD
        apb_write(`ADDR, 'b1011);  // write ADDR
        apb_write(`LEN, 'b00010000);  // write ADDR
        apb_write(`WDATA, 'ha001);  // write WDATA
        apb_write(`CTRL, 32'h0004_0001);  // write clock divider and tx flag CTRL
        apb_read(`CTRL, tmp_data);
        // polling ctrl registers while peripheral not busy
        while ((tmp_data & 'b11) != 32'h0) begin
            apb_read(`CTRL, tmp_data);
        end
        aclk_wait(10);
        $display("Write finish");

        apb_write(`CMD, 'b1011);  // write Read-CMD
        apb_write(`ADDR, 'b1011);  // write ADDR
        apb_write(`LEN, 'b00010000);  // write ADDR
        apb_write(`WDATA, 'h0000);  // write WDATA
        apb_write(`CTRL, 32'h0004_0003);  // write clock divider and tx/rx flag CTRL
        wait (apb_spi_tb.dut.spi_master.spi_rx_en == 1);
        repeat (16) begin
            @(negedge spi_clk) begin
                spi_sdi = $random % 2;
            end
        end

        apb_read(`CTRL, tmp_data);
        // polling ctrl registers while peripheral not busy
        while ((tmp_data & 'b11) != 32'h0) begin
            apb_read(`CTRL, tmp_data);
        end

        apb_read(`RDATA, tmp_data);
        $display("Read finish, data: 0x%08x", tmp_data);
        aclk_wait(10);

        $finish;
    end

endmodule
