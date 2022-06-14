module axi_crossbar_arbiter #(
    parameter integer AXI_REQUEST_NUM = 3
) (
    input  wire                       ACLK,
    input  wire                       ARESETN,
    input  wire [AXI_REQUEST_NUM-1:0] requests_i,
    output reg  [AXI_REQUEST_NUM-1:0] arbiter_o
);
    wire [AXI_REQUEST_NUM*2-1:0] double_requests;
    wire [AXI_REQUEST_NUM*2-1:0] arbiter_result;
    reg  [  AXI_REQUEST_NUM-1:0] arbiter_priority;

    assign double_requests = {requests_i, requests_i};
    assign arbiter_result  = double_requests & (~(double_requests - arbiter_priority));

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            arbiter_priority <= 'd1;
        end else begin
            arbiter_priority <= {
                arbiter_priority[AXI_REQUEST_NUM-2:0], arbiter_priority[AXI_REQUEST_NUM-1]
            };
        end
    end

    always @(posedge ACLK or negedge ARESETN) begin
        if (!ARESETN) begin
            arbiter_o <= 'd0;
        end else begin
            arbiter_o <= arbiter_result[AXI_REQUEST_NUM*2-1:AXI_REQUEST_NUM] | arbiter_result[AXI_REQUEST_NUM-1:0];
        end
    end

endmodule
