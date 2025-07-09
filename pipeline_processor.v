module pipeline_processor(input clk, input reset);

  // Instruction format: opcode[15:12] rs[11:8] rt[7:4] rd[3:0]
  reg [15:0] instruction_memory[0:15];
  reg [7:0] registers[0:15];
  reg [7:0] data_memory[0:255];

  // Pipeline registers
  reg [15:0] IF_ID;
  reg [15:0] ID_EX;
  reg [15:0] EX_WB;
  reg [7:0] EX_result;
  reg [3:0] dest_reg;

  integer pc;

  wire [3:0] opcode, rs, rt, rd;
  assign opcode = IF_ID[15:12];
  assign rs     = IF_ID[11:8];
  assign rt     = IF_ID[7:4];
  assign rd     = IF_ID[3:0];

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pc <= 0;
      IF_ID <= 0;
      ID_EX <= 0;
      EX_WB <= 0;
      EX_result <= 0;
    end else begin
      // IF Stage
      IF_ID <= instruction_memory[pc];
      pc <= pc + 1;

      // ID Stage
      ID_EX <= IF_ID;

      // EX Stage
      case (ID_EX[15:12])
        4'b0001: EX_result <= registers[ID_EX[11:8]] + registers[ID_EX[7:4]]; // ADD
        4'b0010: EX_result <= registers[ID_EX[11:8]] - registers[ID_EX[7:4]]; // SUB
        4'b0011: EX_result <= data_memory[registers[ID_EX[11:8]]];            // LOAD
        default: EX_result <= 0;
      endcase
      dest_reg <= ID_EX[3:0];
      EX_WB <= ID_EX;

      // WB Stage
      if (EX_WB[15:12] != 4'b0000) begin
        registers[dest_reg] <= EX_result;
      end
    end
  end

endmodule
