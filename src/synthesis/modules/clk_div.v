module clk_div #(
    parameter DIVISOR = 50_000_000
) (
    input clk,
    input rst_n,
    output reg out
);
    reg [31:0] counter=28'd0;
   
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n)
            counter <= 28'd0;
        else begin
            counter <= counter + 28'd1;
            if(counter >= (DIVISOR-1))
                counter <= 28'd0;
            out <= (counter<DIVISOR/2)? 1'b1 : 1'b0;
        end
        
    end
endmodule