module pipelined_cpu(input clk, input reset);

    // Program Counter
    reg [7:0] PC;

    // Memories
    reg [15:0] instr_mem [0:15];  // 16 instructions max
    reg [7:0] data_mem [0:255];   // 256-byte data memory
    reg [7:0] regfile [0:7];      // 8 general-purpose registers R0-R7

    // Pipeline registers
    reg [15:0] IF_ID_instr;

    reg [2:0] ID_EX_op;
    reg [2:0] ID_EX_rd;
    reg [7:0] ID_EX_val1, ID_EX_val2;
    reg [7:0] ID_EX_imm;

    reg [2:0] EX_WB_rd;
    reg [7:0] EX_WB_result;
    reg       EX_WB_write;

    // === Stage 1: Instruction Fetch ===
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 0;
        else
            PC <= PC + 1;

        IF_ID_instr <= instr_mem[PC];
    end

    // === Stage 2: Instruction Decode ===
    wire [2:0] opcode = IF_ID_instr[15:13];
    wire [2:0] rd     = IF_ID_instr[12:10];
    wire [2:0] rs1    = IF_ID_instr[9:7];
    wire [2:0] rs2    = IF_ID_instr[6:4];
    wire [7:0] imm    = IF_ID_instr[7:0]; // for LOAD

    always @(posedge clk) begin
        ID_EX_op   <= opcode;
        ID_EX_rd   <= rd;
        ID_EX_val1 <= regfile[rs1];
        ID_EX_val2 <= regfile[rs2];
        ID_EX_imm  <= imm;
    end

    // === Stage 3: Execute ===
    reg [7:0] alu_result;
    reg       write_enable;

    always @(*) begin
        case (ID_EX_op)
            3'b000: begin // ADD
                alu_result = ID_EX_val1 + ID_EX_val2;
                write_enable = 1;
            end
            3'b001: begin // SUB
                alu_result = ID_EX_val1 - ID_EX_val2;
                write_enable = 1;
            end
            3'b010: begin // LOAD
                alu_result = data_mem[ID_EX_imm];
                write_enable = 1;
            end
            default: begin
                alu_result = 8'd0;
                write_enable = 0;
            end
        endcase
    end

    always @(posedge clk) begin
        EX_WB_result <= alu_result;
        EX_WB_rd     <= ID_EX_rd;
        EX_WB_write  <= write_enable;
    end

    // === Stage 4: Write Back ===
    always @(posedge clk) begin
        if (EX_WB_write)
            regfile[EX_WB_rd] <= EX_WB_result;
    end

endmodule
