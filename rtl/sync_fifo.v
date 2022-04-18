module sync_fifo #(
    //common module
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 8,
    parameter CNT_WIDTH  = $clog2(DATA_DEPTH)
) (
    // system and reset
    input wire clk,
    input wire rst_n,
    // write interface
    input wire wr_en_i,
    input wire [DATA_WIDTH-1:0] wr_data_i,
    // read interface
    input wire rd_en_i,
    output reg rd_data_vaild_o,
    output reg [DATA_WIDTH-1:0] rd_data_o,
    // flags
    output wire empty_o,
    output wire full_o,
    output reg [CNT_WIDTH:0] elem_cnt_o
);
    reg [CNT_WIDTH-1:0] wr_ptr;
    reg [CNT_WIDTH-1:0] rd_ptr;
    reg [DATA_WIDTH-1:0] ram[0:DATA_DEPTH-1];
    wire wr_vaild;
    wire rd_vaild;

    assign full_o   = elem_cnt_o == DATA_DEPTH;
    assign empty_o  = elem_cnt_o == 0;

    assign wr_vaild = wr_en_i & (!full_o);
    assign rd_vaild = rd_en_i & (!empty_o);

    // elem_cnt_o
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            elem_cnt_o <= 'b0;
        end else begin
            if (rd_vaild && wr_vaild) begin
                elem_cnt_o <= elem_cnt_o;
            end else if (rd_vaild) begin
                elem_cnt_o <= elem_cnt_o - 1;
            end else if (wr_vaild) begin
                elem_cnt_o <= elem_cnt_o + 1;
            end else begin
                elem_cnt_o <= elem_cnt_o;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data_vaild_o <= 1'b0;
        end else begin
            rd_data_vaild_o <= rd_vaild;
        end
    end

    // rd_data_vaild, rd_data
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data_o <= 'b0;
        end else begin
            if (rd_vaild) begin
                rd_data_o <= ram[rd_ptr];
            end else begin
                rd_data_o <= 'hdeadbeaf;
            end
        end
    end

    // rd_idx
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= 'd0;
        end else begin
            if (rd_vaild) begin
                rd_ptr <= rd_ptr + 1;
            end else begin
                rd_ptr <= rd_ptr;
            end
        end
    end

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DATA_DEPTH; i = i + 1) begin
                ram[i] <= 'd0;
            end
        end else begin
            if (wr_vaild) begin
                ram[wr_ptr] <= wr_data_i;
            end
        end
    end

    // wr_idx
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 'd0;
        end else begin
            if (wr_vaild) begin
                wr_ptr <= wr_ptr + 1;
            end else begin
                wr_ptr <= wr_ptr;
            end
        end
    end

endmodule
