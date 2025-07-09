`timescale 1ns/1ps
module testbench;

  reg clk = 0;
  reg reset = 1;

  // Instantiate the design
  pipeline_processor uut(.clk(clk), .reset(reset));

  // Generate clock
  always #5 clk = ~clk;

  initial begin
    // Dump to GTKWave
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);

    // Initialize register and memory
    uut.registers[1] = 10;  // R1 = 10
    uut.registers[2] = 5;   // R2 = 5
    uut.data_memory[10] = 20; // Mem[10] = 20

    // Load instructions
    uut.instruction_memory[0] = 16'b0001_0001_0010_0100; // ADD R1 + R2 -> R4
    uut.instruction_memory[1] = 16'b0010_0001_0010_0101; // SUB R1 - R2 -> R5
    uut.instruction_memory[2] = 16'b0011_0001_0000_0110; // LOAD [R1] -> R6

    #10 reset = 0;  // Release reset

    #100;

    $display("R4 = %d", uut.registers[4]);
    $display("R5 = %d", uut.registers[5]);
    $display("R6 = %d", uut.registers[6]);

    $finish;
  end
endmodule
