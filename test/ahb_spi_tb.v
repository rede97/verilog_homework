`define CMD 4'd0
`define ADDR 4'd1
`define LEN 4'd2
`define WDATA 4'd3
`define RDATA 4'd4
`define CTRL 4'd5

module ahb_spi_tb;
    reg         aclk;
    reg         rst_n;

    reg  [ 3:0] haddr;
    reg  [31:0] hwdata;
    reg         hwrite;
    reg         hsel;
    wire        hreadyout;
    wire        hreadyin;
    wire [31:0] hrdata;

    wire        psel;
    wire        penable;
    wire [ 3:0] paddr;
    wire        pwrite;
    wire [31:0] pwdata;
    wire [31:0] prdata;
    wire        pready;

    wire        spi_clk;
    reg         spi_sdi;
    wire        spi_sdo;
    wire        spi_cs_n;

    assign hreadin = hreadyout & hsel;

    ahb2apb_bridge #(
        .ADDR_WIDTH(4)
    ) bridge (
        .clk_i   (aclk),
        .rst_n_i (rst_n),
        .haddr_i (haddr),
        .hwdata_i(hwdata),
        .hwrite_i(hwrite),
        .hsel_i  (hsel),
        .hready_i(hreadin),
        .hready_o(hreadyout),
        .hrdata_o(hrdata),

        .psel_o(psel),
        .penable_o(penable),
        .paddr_o(paddr),
        .pwrite_o(pwrite),
        .pwdata_o(pwdata),
        .prdata_i(prdata),
        .pready_i(pready)
    );
    apb_spi_master dut (
        .pclk_i    (aclk),
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
        aclk = 0;
        forever begin
            #5 aclk = ~aclk;
        end
    end

    task aclk_wait(input integer n);
        begin
            repeat (n) begin
                @(posedge aclk);
            end
            #1;
        end
    endtask

    task ahb_clr();
        begin
            haddr  = 0;
            hwdata = 0;
            hwrite = 0;
            hsel   = 0;
        end
    endtask

    task ahb_read(input [3:0] addr, output [31:0] rdata);
        begin
            aclk_wait(1);
            while (!hreadyout) begin
                aclk_wait(1);
            end
            hsel   = 1;
            hwrite = 0;
            haddr  = addr;
            aclk_wait(1);
            haddr = 0;
            while (!hreadyout) begin
                aclk_wait(1);
            end
            rdata = prdata;
            ahb_clr();
            $display("AHB read [%d] = 0x%08x", addr, rdata);
        end
    endtask

    task ahb_write(input [3:0] addr, input [31:0] wdata);
        begin
            aclk_wait(1);
            while (!hreadyout) begin
                aclk_wait(1);
            end
            hsel   = 1;
            hwrite = 1;
            haddr  = addr;
            aclk_wait(1);
            hwrite = 0;
            haddr  = 0;
            hwdata = wdata;
            while (!hreadyout) begin
                aclk_wait(1);
            end
            ahb_clr();
            $display("AHB write [%d] = 0x%08x", addr, wdata);
        end
    endtask

    task ahb_write_read(input [3:0] addr, input [31:0] wdata, output [31:0] rdata);
        begin
            aclk_wait(1);
            while (!hreadyout) begin
                aclk_wait(1);
            end
            hsel   = 1;
            hwrite = 1;
            haddr  = addr;
            aclk_wait(1);
            hwrite = 0;
            haddr  = 0;
            hwdata = wdata;
            while (!hreadyout) begin
                aclk_wait(1);
            end
            $display("AHB write [%d] = 0x%08x", addr, wdata);
            hsel   = 1;
            hwrite = 0;
            haddr  = addr;
            aclk_wait(1);
            haddr = 0;
            while (!hreadyout) begin
                aclk_wait(1);
            end
            rdata = prdata;
            ahb_clr();
            $display("AHB read [%d] = 0x%08x", addr, rdata);
        end
    endtask

    initial begin
        ahb_clr();
        rst_n = 0;
        aclk_wait(5);
        rst_n = 1;
        aclk_wait(1024);
        $display("Some problem");
        $finish;
    end

    reg [31:0] tmp_data;
    initial begin
        tmp_data = 0;
        wait (rst_n == 1);
        aclk_wait(1);

        ahb_write(1, 32'habcd1234);
        aclk_wait(8);
        ahb_read(1, tmp_data);
        aclk_wait(8);
        ahb_write_read(1, 32'h1234abcd, tmp_data);

        aclk_wait(32);
        $finish;
    end

endmodule
