module register#(
    parameter DATA_WIDTH = 16
)(
    input clk,
    input rst_n,
    input cl,
    input ld,
    input [DATA_WIDTH-1:0] in,
    input inc,
    input dec,
    input sr,
    input ir,
    input sl,
    input il,
    output [DATA_WIDTH-1:0] out
);
    reg [DATA_WIDTH-1:0] out_reg, out_next;
    assign out = out_reg;
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            out_reg <= {DATA_WIDTH{1'b0}};
        else
            out_reg <= out_next;
    end

    always @(*) begin
        out_next = out_reg;
        if(cl == 1'b1)
            out_next = {DATA_WIDTH{1'b0}};
        else if(ld== 1'b1)
            out_next = in;
        else if(inc== 1'b1)
            out_next = out_reg + 1'b1;
        else if(dec== 1'b1)
            out_next = out_reg - 1'b1;
        else if(sr== 1'b1)
            out_next = (out_reg >> 1) | {ir, {DATA_WIDTH-1{1'b0}}};
        else if(sl== 1'b1)
            out_next = (out_reg << 1) | {{DATA_WIDTH-1{1'b0}}, il};
    end
endmodule
