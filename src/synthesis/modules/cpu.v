module cpu #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rst_n,
    input [DATA_WIDTH-1 : 0] mem_in,
    input [DATA_WIDTH-1 : 0] in,
    output reg mem_we,
    output reg [ADDR_WIDTH-1 : 0] mem_addr,
    output reg [DATA_WIDTH-1 : 0] mem_data,
    output [DATA_WIDTH-1 : 0] out,
    output [ADDR_WIDTH-1 : 0] pc,
    output [ADDR_WIDTH-1 : 0] sp
);
    // __REGISTERS INIT__

    // Program counter
    reg [ADDR_WIDTH-1:0] pc_in;
    reg pc_ld;
    reg pc_inc;
    register #(ADDR_WIDTH) pc_reg( 
        .clk(clk),
        .rst_n(rst_n),
        .cl(1'b0),
        .ld(pc_ld),
        .in(pc_in),
        .inc(pc_inc),
        .dec(1'b0),
        .sr(1'b0),
        .ir(1'b0),
        .sl(1'b0),
        .il(1'b0),
        .out(pc)
    );
    // Stack pointer
    reg [ADDR_WIDTH-1:0] sp_in;
    reg sp_ld;
    register #(ADDR_WIDTH) sp_reg( 
        .clk(clk),
        .rst_n(rst_n),
        .cl(1'b0),
        .ld(sp_ld),
        .in(sp_in),
        .inc(1'b0),
        .dec(1'b0),
        .sr(1'b0),
        .ir(1'b0),
        .sl(1'b0),
        .il(1'b0),
        .out(sp)
    );
    //reg [15:0] ir_1; // Instruction register - first byte
    //reg [15:0] ir_2; // Instruction register - second byte
    //reg [DATA_WIDTH-1:0] acc; // Accumulator

    // Instruction register - first byte
    reg [DATA_WIDTH-1:0] ir_1_in;
    reg ir_1_ld;
    wire [DATA_WIDTH-1:0] ir_1_out;
    register #(DATA_WIDTH) ir_1_reg( 
        .clk(clk),
        .rst_n(rst_n),
        .cl(1'b0),
        .ld(ir_1_ld),
        .in(ir_1_in),
        .inc(1'b0),
        .dec(1'b0),
        .sr(1'b0),
        .ir(1'b0),
        .sl(1'b0),
        .il(1'b0),
        .out(ir_1_out)
    );

    // Instruction register - second byte
    reg [DATA_WIDTH-1:0] ir_2_in;
    reg ir_2_ld;
    wire [DATA_WIDTH-1:0] ir_2_out;
    register #(DATA_WIDTH) ir_2_reg( 
        .clk(clk),
        .rst_n(rst_n),
        .cl(1'b0),
        .ld(ir_2_ld),
        .in(ir_2_in),
        .inc(1'b0),
        .dec(1'b0),
        .sr(1'b0),
        .ir(1'b0),
        .sl(1'b0),
        .il(1'b0),
        .out(ir_2_out)
    );

    // Accumulator
    reg [DATA_WIDTH-1:0] acc_in;
    reg acc_ld;
    wire [DATA_WIDTH-1:0] acc_out;
    register #(DATA_WIDTH) acc_reg( 
        .clk(clk),
        .rst_n(rst_n),
        .cl(1'b0),
        .ld(acc_ld),
        .in(acc_in),
        .inc(1'b0),
        .dec(1'b0),
        .sr(1'b0),
        .ir(1'b0),
        .sl(1'b0),
        .il(1'b0),
        .out(acc_out)
    );

    // __ALU INIT__
    reg [2:0] alu_op_code;
    reg [DATA_WIDTH-1 : 0] alu_first_operand;
    reg [DATA_WIDTH-1 : 0] alu_second_operand;
    wire [DATA_WIDTH-1 : 0] alu_out;
    alu cpu_alu(
        .oc(alu_op_code),
        .a(alu_first_operand),
        .b(alu_second_operand),
        .f(alu_out)
    );
    
    
    // States
    localparam reset_state = 4'b0000;
    localparam fetch_first_byte_state = 4'b0001;
    localparam fetch_second_byte_state = 4'b0010;
    localparam decode_state = 4'b0011;
    localparam fetch_second_operand_direct_state = 4'b0100;
    localparam fetch_second_operand_indirect_state = 4'b0101;
    localparam fetch_third_operand_direct_state = 4'b0110;
    localparam fetch_third_operand_indirect_state = 4'b0111;
    localparam execute_alu_state = 4'b1000;
    localparam store_from_acc_direct_state = 4'b1001;
    localparam store_from_acc_indirect_state = 4'b1010;
    localparam out_first_operand_state = 4'b1011;
    localparam out_second_operand_state = 4'b1100;
    localparam out_third_operand_state = 4'b1101;
    localparam stop_state = 4'b1110;

    // Helper registers
    reg [3:0] state_reg, state_next;
    reg [1:0] clock_counter_reg, clock_counter_next;
    reg [DATA_WIDTH-1 : 0] out_reg, out_next;
    assign  out = out_reg;
    

    // __MAIN CODE__
    always @(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state_reg <= reset_state;
        end
        else begin
            clock_counter_reg <= clock_counter_next;
            state_reg <= state_next;
            out_reg <= out_next;
        end
    end

    always @(*) begin
        clock_counter_next = clock_counter_reg;
        state_next = state_reg;
        out_next = out_reg;
        pc_ld = 1'b0;
        pc_inc = 1'b0;
        pc_in = {ADDR_WIDTH{1'b0}};
        sp_ld = 1'b0;
        sp_in = {ADDR_WIDTH{1'b0}};
        ir_1_ld = 1'b0;
        ir_1_in = {DATA_WIDTH{1'b0}};
        ir_2_ld = 1'b0;
        ir_2_in = {DATA_WIDTH{1'b0}};
        acc_ld = 1'b0;
        acc_in = {DATA_WIDTH{1'b0}};

        mem_we = 1'b0;
        mem_addr = {ADDR_WIDTH{1'b0}};
        mem_data = {DATA_WIDTH{1'b0}};

        alu_op_code = 3'b000;
        alu_first_operand = {DATA_WIDTH{1'b0}};
        alu_second_operand = {DATA_WIDTH{1'b0}};


        case (state_reg)
            reset_state: begin

                pc_in = 8;
                pc_ld = 1'b1;
                
                sp_in = 6'd63;
                sp_ld = 1'b1;

                ir_1_in = {16{1'b0}};
                ir_1_ld = 1'b1;

                ir_2_in = {16{1'b0}};
                ir_2_ld = 1'b1;

                acc_in = {DATA_WIDTH{1'b0}}; 
                acc_ld = 1'b1;

                clock_counter_next = 1'b0;
                out_next = {DATA_WIDTH{1'b0}};
                state_next = fetch_first_byte_state;
            end
            fetch_first_byte_state:begin
                if(!clock_counter_reg) begin
                    mem_we = 1'b0;
                    mem_addr = pc;

                    pc_inc = 1'b1;
                    clock_counter_next = clock_counter_reg + 2'b01;
                end
                else begin
                    ir_1_in = mem_in;
                    ir_1_ld = 1'b1;

                    clock_counter_next =  2'b00;
                    state_next = decode_state;
                end
            end
            decode_state: begin
                case (ir_1_out[15:12])
                    4'b0000: begin // MOV INSTRUCTION
                        if(ir_1_out[3:0] == 4'b0000) begin
                            mem_we = 1'b0;
                            mem_addr = ir_1_out[6:4];

                            state_next = fetch_second_operand_direct_state;
                        end
                        else if(ir_1_out[3:0] == 4'b1000) begin
                            state_next = fetch_second_byte_state;
                        end

                    end 
                    4'b0001, 4'b0010, 4'b0011, 4'b0100: begin // ADD, SUB, MUL, DIV INSTRUCTION
                        mem_we = 1'b0;
                        mem_addr = ir_1_out[6:4];

                        if(!ir_1_out[7]) begin
                            state_next = fetch_second_operand_direct_state;
                        end
                        else begin
                            state_next = fetch_second_operand_indirect_state;
                        end
                    end
                    4'b0111: begin // IN INSTRUCTION
                        if(!ir_1_out[11]) begin
                            // DIRECT IN
                            mem_we = 1'b1;
                            mem_data = in;
                            mem_addr = ir_1_out[10:8];

                            state_next = fetch_first_byte_state;
                        end
                        else begin
                            // INDIRECT IN
                            if(!clock_counter_reg) begin
                                mem_we = 1'b0;
                                mem_addr = ir_1_out[10:8];

                                clock_counter_next = clock_counter_reg + 2'b01;
                            end
                            else if(clock_counter_reg == 2'b01) begin
                                acc_in = mem_in;
                                acc_ld = 1'b1;

                                clock_counter_next = clock_counter_reg + 2'b01;
                            end
                            else begin
                                mem_we = 1'b1;
                                // lose prosledjivati tek u 3. taktu, napravi temp reg, in stavi u acc, a indirektno adresiranje preko temp
                                mem_data = in;
                                mem_addr = acc_out;

                                clock_counter_next = 2'b00;
                                state_next = fetch_first_byte_state;
                            end
                            
                        end
                    end  
                    4'b1000: begin // OUT INSTRUCTION
                        if(!ir_1_out[11]) begin
                            // DIRECT OUT
                            if(!clock_counter_reg) begin
                                mem_we = 1'b0;
                                mem_addr = ir_1_out[10:8];

                                clock_counter_next = clock_counter_reg + 2'b01;
                            end
                            else begin
                                out_next = mem_in;

                                clock_counter_next = 2'b00;
                                state_next = fetch_first_byte_state;
                            end
                        end
                        else begin
                            // INDIRECT OUT
                            if(!clock_counter_reg) begin
                                mem_we = 1'b0;
                                mem_addr = ir_1_out[10:8];

                                clock_counter_next = clock_counter_reg + 2'b01;
                            end
                            else if(clock_counter_reg == 2'b01) begin
                                acc_in = mem_in;
                                acc_ld = 1'b1;

                                clock_counter_next = clock_counter_reg + 2'b01;
                            end
                            else if (clock_counter_reg == 2'b10)begin
                                mem_we = 1'b0;
                                mem_addr = acc_out;

                                clock_counter_next = clock_counter_reg + 2'b01;
                            end
                            else begin
                                out_next = mem_in;

                                clock_counter_next = 2'b00;
                                state_next = fetch_first_byte_state;
                            end
                        end
                    end 
                    4'b1111: begin // STOP INSTRUCTION

                        state_next = stop_state;
                        
                    end 
                    default: begin // ILLEGAL OP CODE
                        // out_next = 5'b10101;
                    end 
                endcase
            end
            fetch_second_operand_indirect_state: begin
                if(!clock_counter_reg) begin
                    acc_in = mem_in;
                    acc_ld = 1'b1;
                    clock_counter_next = clock_counter_reg + 2'b01;
                end
                else if(clock_counter_reg == 1) begin
                    mem_we = 1'b0;
                    mem_addr = acc_out;
                    clock_counter_next = clock_counter_reg + 2'b01;
                end
                else begin
                    acc_in = mem_in;
                    acc_ld = 1'b1;
                    clock_counter_next = 2'b00;

                    mem_we = 1'b0;
                    mem_addr = ir_1_out[2:0];
                    if(!ir_1_out[3]) begin
                        state_next = fetch_third_operand_direct_state;
                    end
                    else begin
                        state_next = fetch_third_operand_indirect_state;
                    end
                end
                
            end
            fetch_second_operand_direct_state: begin
                acc_in = mem_in;
                acc_ld = 1'b1;

                
                if(ir_1_out[15:12] == 4'b0000) begin 
                    // If op_code == MOV
                    if(!ir_1_out[11]) begin
                        state_next = store_from_acc_direct_state;
                    end
                    else begin
                        state_next = store_from_acc_indirect_state;
                    end
                end
                else begin
                    // If op_code == ADD/SUB/MUL
                    
                    if(!ir_1_out[3]) begin
                        state_next = fetch_third_operand_direct_state;
                    end
                    else begin
                        state_next = fetch_third_operand_indirect_state;
                    end
                end

                
            end
            fetch_third_operand_indirect_state: begin
                if(!clock_counter_reg) begin
                    mem_we = 1'b0;
                    mem_addr = ir_1_out[2:0];

                    clock_counter_next = clock_counter_reg + 2'b01;
                end 
                else begin
                    mem_we = 1'b0;
                    mem_addr = mem_in;

                    clock_counter_next = 2'b00;
                    state_next = execute_alu_state;
                end

            end
            fetch_third_operand_direct_state: begin
                mem_we = 1'b0;
                mem_addr = ir_1_out[2:0];

                state_next = execute_alu_state;
            end
            execute_alu_state: begin
                alu_first_operand = acc_out;
                alu_second_operand = mem_in;

                case (ir_1_out[15:12])
                    4'b0001: begin // ADD INSTRUCTION
                        alu_op_code = 3'b000;
                        acc_in = alu_out;
                        acc_ld = 1'b1;

                        if(!ir_1_out[11]) begin
                            state_next = store_from_acc_direct_state;
                        end
                        else begin
                            state_next = store_from_acc_indirect_state;
                        end
                    end 
                    4'b0010: begin // SUB INSTRUCTION
                        alu_op_code = 3'b001;
                        acc_in = alu_out;
                        acc_ld = 1'b1;

                        if(!ir_1_out[11]) begin
                            state_next = store_from_acc_direct_state;
                        end
                        else begin
                            state_next = store_from_acc_indirect_state;
                        end
                    end 
                    4'b0011: begin // MUL INSTRUCTION
                        alu_op_code = 3'b010;
                        acc_in = alu_out;
                        acc_ld = 1'b1;

                        if(!ir_1_out[11]) begin
                            state_next = store_from_acc_direct_state;
                        end
                        else begin
                            state_next = store_from_acc_indirect_state;
                        end
                    end 
                    4'b0100: begin // DIV INSTRUCTION 
                        // Nothing?
                        state_next = fetch_first_byte_state;
                    end
                    default: begin
                        // ERROR: ILLEGAL OP CODE
                    end
                endcase
            end
            store_from_acc_direct_state: begin
                
                mem_we = 1'b1;
                mem_data = acc_out;
                mem_addr = ir_1_out[10:8];

                state_next = fetch_first_byte_state;
            end
            store_from_acc_indirect_state: begin
                if(!clock_counter_reg) begin
                    mem_we = 1'b0;
                    mem_addr = ir_1_out[10:8];

                    clock_counter_next = clock_counter_reg + 2'b01;
                end
                else begin
                    mem_we = 1'b1;
                    mem_data = acc_out;
                    mem_addr = mem_in;

                    clock_counter_next = 2'b00;
                    state_next = fetch_first_byte_state;
                end
            end
            fetch_second_byte_state: begin
                if(!clock_counter_reg) begin
                    mem_we = 1'b0;
                    mem_addr = pc;

                    pc_inc = 1'b1;

                    clock_counter_next = clock_counter_reg + 2'b01;
                end
                else begin
                    acc_in = mem_in;
                    acc_ld = 1'b1;

                    clock_counter_next = 2'b00;
                    if(!ir_1_out[11]) 
                        state_next = store_from_acc_direct_state;
                    else 
                        state_next = store_from_acc_indirect_state;
                end
            end
            out_first_operand_state: begin
                 if(!ir_1_out[11]) begin
                    // DIRECT OUT
                    if(!clock_counter_reg) begin
                        mem_we = 1'b0;
                        mem_addr = ir_1_out[10:8];

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else begin
                        out_next = mem_in;

                        clock_counter_next = 2'b00;
                        
                        if(ir_1_out[6:4] != 3'b000) begin
                            state_next = out_second_operand_state;
                        end
                        else if(ir_1_out[2:0] != 3'b000) begin
                            state_next = out_third_operand_state;
                        end
                    end
                end
                else begin
                    // INDIRECT OUT
                    if(!clock_counter_reg) begin
                        mem_we = 1'b0;
                        mem_addr = ir_1_out[10:8];

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else if(clock_counter_reg == 2'b01) begin
                        acc_in = mem_in;
                        acc_ld = 1'b1;

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else if (clock_counter_reg == 2'b10)begin
                        mem_we = 1'b0;
                        mem_addr = acc_out;

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else begin
                        out_next = mem_in;

                        clock_counter_next = 2'b00;
                        if(ir_1_out[6:4] != 3'b000) begin
                            state_next = out_second_operand_state;
                        end
                        else if(ir_1_out[2:0] != 3'b000) begin
                            state_next = out_third_operand_state;
                        end
                    end
                end
            end
            out_second_operand_state: begin
                 if(!ir_1_out[7]) begin
                    // DIRECT OUT
                    if(!clock_counter_reg) begin
                        mem_we = 1'b0;
                        mem_addr = ir_1_out[6:4];

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else begin
                        out_next = mem_in;

                        clock_counter_next = 2'b00;
                        if(ir_1_out[2:0] != 3'b000) begin
                            state_next = out_third_operand_state;
                        end
                        else if(ir_1_out[10:8] != 3'b000) begin
                            state_next = out_first_operand_state;
                        end
                    end
                end
                else begin
                    // INDIRECT OUT
                    if(!clock_counter_reg) begin
                        mem_we = 1'b0;
                        mem_addr = ir_1_out[6:4];

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else if(clock_counter_reg == 2'b01) begin
                        acc_in = mem_in;
                        acc_ld = 1'b1;

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else if (clock_counter_reg == 2'b10)begin
                        mem_we = 1'b0;
                        mem_addr = acc_out;

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else begin
                        out_next = mem_in;

                        clock_counter_next = 2'b00;
                        if(ir_1_out[2:0] != 3'b000) begin
                            state_next = out_third_operand_state;
                        end
                        else if(ir_1_out[10:8] != 3'b000) begin
                            state_next = out_first_operand_state;
                        end
                    end
                end
            end
            out_third_operand_state: begin
                 if(!ir_1_out[3]) begin
                    // DIRECT OUT
                    if(!clock_counter_reg) begin
                        mem_we = 1'b0;
                        mem_addr = ir_1_out[2:0];

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else begin
                        out_next = mem_in;

                        clock_counter_next = 2'b00;
                        if(ir_1_out[10:8] != 3'b000) begin
                            state_next = out_first_operand_state;
                        end
                        else if(ir_1_out[6:4] != 3'b000) begin
                            state_next = out_second_operand_state;
                        end
                    end
                end
                else begin
                    // INDIRECT OUT
                    if(!clock_counter_reg) begin
                        mem_we = 1'b0;
                        mem_addr = ir_1_out[2:0];

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else if(clock_counter_reg == 2'b01) begin
                        acc_in = mem_in;
                        acc_ld = 1'b1;

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else if (clock_counter_reg == 2'b10)begin
                        mem_we = 1'b0;
                        mem_addr = acc_out;

                        clock_counter_next = clock_counter_reg + 2'b01;
                    end
                    else begin
                        out_next = mem_in;

                        clock_counter_next = 2'b00;
                        if(ir_1_out[10:8] != 3'b000) begin
                            state_next = out_first_operand_state;
                        end
                        else if(ir_1_out[6:4] != 3'b000) begin
                            state_next = out_second_operand_state;
                        end
                    end
                end
            end
            stop_state: begin
                if(ir_1_out[10:8] != 3'b000) begin
                    state_next = out_first_operand_state;
                end
                else if(ir_1_out[6:4] != 3'b000) begin
                    state_next = out_second_operand_state;
                end
                else if(ir_1_out[2:0] != 3'b000) begin
                    state_next = out_third_operand_state;
                end
            end
            default: begin
                // ERROR: UNKNOWN STATE
            end
        endcase
        
        sp_in = state_reg;              //-------------------------TEMP-------------------------
        sp_ld = 1'b1;                   //-------------------------TEMP-------------------------
    end


endmodule