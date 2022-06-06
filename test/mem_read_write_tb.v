module mem_read_write_tb;
    wire        sram_clk;
    reg         hclk;
    reg         hresetn;

    reg  [ 7:0] haddr;
    reg  [31:0] hwdata;
    reg         hwrite;
    reg         hsel;
    //   reg  [ 1:0] htrans;
    wire        hreadyout;
    wire        hreadyin;
    wire [31:0] hrdata;
    wire        hresp;

    assign hreadyin = hreadyout & hsel;
    assign sram_clk = ~hclk;

    sramc_top u_sramc_top(                 //2.通过接口例化连接DUT顶层文件；结合1、2两步骤建立DUT与TB之间的连接
        .hclk(hclk),
        .sram_clk(sram_clk),
        .hresetn(hresetn),  //给DUT
        .hsel(hsel),  //给DUT
        .hwrite(hwrite),  //给DUT
        .htrans(2'b10),  //给DUT
        .hsize(3'b010),  //给DUT
        .hready(hreadyin),  //给DUT
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

    initial begin
        hclk = 0;
        forever begin
            #5 hclk = ~hclk;
        end
    end

    task hclk_wait(input integer n);
        begin
            repeat (n) begin
                @(posedge hclk);
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

    task ahb_read(input [7:0] addr, output [31:0] rdata);
        begin
            hclk_wait(1);
            while (!hreadyout) begin
                hclk_wait(1);
            end
            hsel   = 1;
            hwrite = 0;
            haddr  = addr;
            hclk_wait(1);
            haddr = 0;
            while (!hreadyout) begin
                hclk_wait(1);
            end
            rdata = hrdata;
            ahb_clr();
            $display("AHB read [%02d] = 0x%08x", addr, rdata);
        end
    endtask

    task ahb_write(input [7:0] addr, input [31:0] wdata);
        begin
            hclk_wait(1);
            while (!hreadyout) begin
                hclk_wait(1);
            end
            hsel   = 1;
            hwrite = 1;
            haddr  = addr;
            hclk_wait(1);
            hwrite = 0;
            haddr  = 0;
            hwdata = wdata;
            hclk_wait(1);
            while (!hreadyout) begin
                hclk_wait(1);
            end
            ahb_clr();
            $display("AHB write [%02d] = 0x%08x", addr, wdata);
        end
    endtask

    task ahb_write_read(input [3:0] addr, input [31:0] wdata, output [31:0] rdata);
        begin
            hclk_wait(1);
            while (!hreadyout) begin
                hclk_wait(1);
            end
            hsel   = 1;
            hwrite = 1;
            haddr  = addr;
            hclk_wait(1);
            hwrite = 0;
            haddr  = addr + 4;
            hwdata = wdata;
            hclk_wait(1);
            while (!hreadyout) begin
                hclk_wait(1);
            end
            $display("AHB write [%02d] = 0x%08x", addr, wdata);
            haddr = 0;
            hclk_wait(1);
            while (!hreadyout) begin
                hclk_wait(1);
            end
            rdata = hrdata;
            ahb_clr();
            $display("AHB read [%02d] = 0x%08x", addr + 4, rdata);
        end
    endtask

    initial begin
        $dumpfile("mem_read_write_tb.vcd");  //生成的vcd文件名称
        $dumpvars(0, mem_read_write_tb);  //tb模块名称
        $timeformat(-9, 2, "ns", 4);
    end

    initial begin
        ahb_clr();
        hresetn = 0;
        hclk_wait(5);
        hresetn = 1;
        hclk_wait(1024);
        $display("Some problem");
        $finish;
    end

    reg [31:0] tmp_data;
    initial begin
        tmp_data = 0;
        wait (hresetn == 1);
        hclk_wait(1);

        ahb_write(4, 32'habcd1234);
        hclk_wait(8);
        ahb_write_read(0, 32'hcdef9876, tmp_data);
        hclk_wait(8);
        ahb_read(0, tmp_data);

        hclk_wait(32);
        $finish;
    end

endmodule
