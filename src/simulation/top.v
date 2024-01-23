module top;
    
    reg [0:2] oc;
    reg [0:3] a;
    reg [0:3] b;
    wire [0:3] f;

    alu dut(oc, a, b, f);

    reg clk;
    reg rst_n;
    reg cl;
    reg ld;
    reg [3:0] in;
    reg inc;
    reg dec;
    reg sr;
    reg ir;
    reg sl;
    reg il;
    wire [3:0] out;

    register dut2(.clk(clk), .rst_n(rst_n), .cl(cl), .ld(ld), .in(in), .inc(inc), .dec(dec), .sr(sr), .ir(ir), .sl(sl), .il(il), .out(out));

    integer i;
    initial begin
        for(i = 0; i < 2**11; i = i + 1) begin
            {oc, a, b} = i;
            #5;
        end
        $stop;

        clk = 1'b0;
        cl = 1'b0; ld = 1'b0; in = 4'h0; inc = 1'b0; dec = 1'b0; sr = 1'b0; ir = 1'b0; sl = 1'b0; il = 1'b0;
        rst_n = 1'b0;
        #7;
        rst_n = 1'b1;
        repeat(1000) begin
            #10;
            {cl, ld, inc, dec, sr, ir, sl, il, in} = $random % 2**12;
            
        end
        $finish;
        
    end

    always @(oc or a or b) begin
        $strobe("time = %5d, oc = %b, a = %b, b = %b, f = %b",
        $time, oc, a, b, f);
    end

    always @(cl, ld, inc, dec, sr, ir, sl, il, in,out) begin
        $strobe("time = %5d, clear = %b, load = %b, inc = %b, dec = %b, shift_r = %b, inf_r = %b, shift_l = %b, inf_l = %b, in = %b, out = %b",
        $time, cl, ld, inc, dec, sr, ir, sl, il, in, out);
    end

    always #5 clk = ~clk;
endmodule