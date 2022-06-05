module ahb_spi_tb;
  reg         aclk;
  reg         rst_n;

  reg  [ 3:0] haddr;
  reg  [31:0] hwdata;
  reg         hwrite;
  reg         hsel;
//   reg  [ 1:0] htrans;
  wire        hreadyout;
  wire        hreadyin;
  wire [31:0] hrdata;
  wire        hresp;

  assign hreadyin = hreadyout & hsel;

  ahb3lite_sram1rw mem (
      .HRESETn(rst_n),
      .HCLK(aclk),
      .HSEL(hsel),
      .HADDR(haddr),
      .HWDATA(hwdata),
      .HRDATA(hrdata),
      .HWRITE(hwrite),
      .HSIZE(3'b010),
      .HBURST(3'b000),
      .HPROT(4'b0000),
      .HTRANS(2'b10),
      .HREADYOUT(hreadyout),
      .HREADY(hreadyin),
      .HRESP(hresp)
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
      rdata = hrdata;
      ahb_clr();
      $display("AHB read [%02d] = 0x%08x", addr, rdata);
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
      $display("AHB write [%02d] = 0x%08x", addr, wdata);
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
      haddr  = addr + 1;
      hwdata = wdata;
      while (!hreadyout) begin
        aclk_wait(1);
      end
      $display("AHB write [%02d] = 0x%08x", addr, wdata);
      aclk_wait(1);
      haddr = 0;
      while (!hreadyout) begin
        aclk_wait(1);
      end
      rdata = hrdata;
      ahb_clr();
      $display("AHB read [%02d] = 0x%08x", addr + 1, rdata);
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
    ahb_write_read(0, 32'hcdef9876, tmp_data);
    aclk_wait(8);
    ahb_read(0, tmp_data);

    aclk_wait(32);
    $finish;
  end

endmodule
