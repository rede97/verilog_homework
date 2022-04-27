`define CMD 4'd0
`define ADDR 4'd1
`define LEN 4'd2
`define WDATA 4'd3
`define RDATA 4'd4
`define CTRL 4'd5

module apb_spi_rf (
    input  wire        pclk_i,
    input  wire        rst_n_i,
    input  wire        psel_i,
    input  wire        penable_i,
    input  wire [ 3:0] paddr_i,
    input  wire        pwrite_i,
    input  wire [31:0] pwdata_i,
    output wire [31:0] prdata_o,
    output wire        pready_o,
    output wire        spi_clk_div_vld_o,
    output wire [15:0] spi_clk_div_o,
    input  wire        eot_i,                 // end of transmit/receive
    output wire [31:0] stream_data_tx_o,      // tx data stream input
    output wire        stream_data_tx_vld_o,  // tx data stream valid
    input  wire        stream_data_tx_rdy_i,  // tx data stream teady
    input  wire [31:0] stream_data_rx_i,      // rx data stream output
    input  wire        stream_data_rx_vld_i,  // rx data stream valid
    output wire        stream_data_rx_rdy_o   // rx data stream ready
);

    reg  [31:0] regs             [0:5];
    reg  [31:0] reg_data_out;
    wire [31:0] reg_ctrl_next;
    wire [ 3:0] cmd;
    wire [ 3:0] addr;
    wire [ 7:0] len;
    wire [15:0] wdata;
    wire        rd_en;
    wire        wr_en;
    wire        reg_ctrl_tx_flag;
    wire        reg_ctrl_rx_flag;
    // pready is 1
    assign pready_o             = 1'b1;

    // write enable
    assign wr_en                = psel_i & penable_i & pwrite_i;
    // read enable
    assign rd_en                = psel_i & penable_i & (~pwrite_i);

    // stream tx and rx is controled by CTRL-reg
    assign stream_data_tx_vld_o = regs[`CTRL][0];
    assign stream_data_rx_rdy_o = regs[`CTRL][1];

    // CTRL-reg next
    assign spi_clk_div_vld_o    = 1'b1;
    assign spi_clk_div_o        = regs[`CTRL][31:16];
    assign reg_ctrl_tx_flag     = eot_i ? 1'b0 : regs[`CTRL][0];  // Tx flag of CTRL-reg
    assign reg_ctrl_rx_flag     = eot_i ? 1'b0 : regs[`CTRL][1];  // Rx flag of CTRL-reg
    assign reg_ctrl_next        = {spi_clk_div_o, 14'd0, reg_ctrl_rx_flag, reg_ctrl_tx_flag};

    // output of stream data tx
    assign cmd                  = regs[`CMD][3:0];
    assign addr                 = regs[`ADDR][3:0];
    assign len                  = regs[`LEN][7:0];
    assign wdata                = regs[`WDATA][15:0];
    assign stream_data_tx_o     = {cmd, addr, len, wdata};

    // Read data from APB-registers
    assign prdata_o             = reg_data_out;

    // update APB-registers
    always @(posedge pclk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            regs[`CMD]   <= 32'h0;
            regs[`ADDR]  <= 32'h0;
            regs[`LEN]   <= 32'h0;
            regs[`WDATA] <= 32'h0;
            regs[`CTRL]  <= 32'h0;
        end else begin
            if (wr_en) begin
                case (paddr_i)
                    `CMD: begin
                        regs[`CMD] <= pwdata_i;
                    end
                    `ADDR: begin
                        regs[`ADDR] <= pwdata_i;
                    end
                    `LEN: begin
                        regs[`LEN] <= pwdata_i;
                    end
                    `WDATA: begin
                        regs[`WDATA] <= pwdata_i;
                    end
                    `CTRL: begin
                        regs[`CTRL] <= {
                            pwdata_i[31:16] < 4 ? 16'd4 : pwdata_i[31:16], pwdata_i[15:0]
                        };
                    end
                    default: begin
                        regs[`CMD]   <= regs[`CMD];
                        regs[`ADDR]  <= regs[`ADDR];
                        regs[`LEN]   <= regs[`LEN];
                        regs[`WDATA] <= regs[`WDATA];
                        regs[`CTRL]  <= reg_ctrl_next;
                    end
                endcase
            end else begin
                regs[`CMD]   <= regs[`CMD];
                regs[`ADDR]  <= regs[`ADDR];
                regs[`LEN]   <= regs[`LEN];
                regs[`WDATA] <= regs[`WDATA];
                regs[`CTRL]  <= reg_ctrl_next;
            end
        end
    end

    // update RDATA-reg of APB registers from SPI
    always @(posedge pclk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            regs[`RDATA] <= 32'h0;
        end else begin
            if (stream_data_rx_vld_i) begin
                regs[`RDATA] <= stream_data_rx_i;
            end
        end
    end

    always @(posedge pclk_i or negedge rst_n_i) begin
        if (!rst_n_i) begin
            reg_data_out <= 32'h0;
        end else begin
            case (paddr_i)
                `CMD: begin
                    reg_data_out <= regs[`CMD];
                end
                `ADDR: begin
                    reg_data_out <= regs[`ADDR];
                end
                `LEN: begin
                    reg_data_out <= regs[`LEN];
                end
                `WDATA: begin
                    reg_data_out <= regs[`WDATA];
                end
                `RDATA: begin
                    reg_data_out <= regs[`RDATA];
                end
                `CTRL: begin
                    reg_data_out <= regs[`CTRL];
                end
                default: begin
                    reg_data_out <= 32'h0;
                end
            endcase
        end
    end


endmodule
