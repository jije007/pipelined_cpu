`timescale 1ns/1ps

module pipelined_cpu_tb;

    reg clk;
    reg reset;

    // Instantiate the processor
    pipelined_cpu cpu (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        $display("Starting simulation...");
        $dumpfile("pipeline_wave.vcd");
        $dumpvars(0, pipelined_cpu_tb);

        clk = 0;
        reset = 1;

        // Hold reset briefly
        #10 reset = 0;

        // =======================
        // Instruction Memory
        // =======================
        cpu.instr_mem[0] = 16'b000_001_010_011_0000; // ADD R1 = R2 + R3
        cpu.instr_mem[1] = 16'b001_100_001_010_0000; // SUB R4 = R1 - R2
        cpu.instr_mem[2] = 16'b010_101_000_000_1100; // LOAD R5 = MEM[12]

        // =======================
        // Register File Init
        // =======================
        cpu.regfile[2] = 8'd10;  // R2 = 10
        cpu.regfile[3] = 8'd20;  // R3 = 20

        // =======================
        // Data Memory Init
        // =======================
        cpu.data_mem[12] = 8'hF0;  // MEM[12] = 240

        // Wait long enough for all instructions to execute
        #200;

        // =======================
        // Dump Register File
        // =======================
        $display("\n=== Final Register File ===");
        $display("R0 = %d", cpu.regfile[0]);
        $display("R1 = %d", cpu.regfile[1]);
        $display("R2 = %d", cpu.regfile[2]);
        $display("R3 = %d", cpu.regfile[3]);
        $display("R4 = %d", cpu.regfile[4]);
        $display("R5 = %d", cpu.regfile[5]);
        $display("R6 = %d", cpu.regfile[6]);
        $display("R7 = %d", cpu.regfile[7]);

        $finish;
    end

endmodule
