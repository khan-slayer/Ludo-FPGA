`timescale 1ns/1ps
module tb_thunderbird_fsm;

    // Clock + DUT inputs
    reg clk;
    reg T;        // synchronous active-high reset (your naming)
    reg L;
    reg R;
    reg enable;   // we will hold enable=1 during tests (easy, robust)

    // DUT outputs
    wire RA, RB, RC, LA, LB, LC;

    // Instantiate DUT (use your provided module)
    thunderbird_fsm_eqs dut (
        .clk(clk),
        .T(T),
        .L(L),
        .R(R),
        .enable(enable),
        .RA(RA),
        .RB(RB),
        .RC(RC),
        .LA(LA),
        .LB(LB),
        .LC(LC)
    );

    // 100 MHz style clock generator (10 ns period)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // VCD dump and header
    initial begin
        $dumpfile("tb_thunderbird_fsm_fixed.vcd");
        $dumpvars(0, tb_thunderbird_fsm_fixed);
        $display("\nTime(ns) : T L R | enable |  A B C  | RA RB RC | LA LB LC");
        $display("----------------------------------------------------------");
    end

    // Print state + outputs on every rising edge
    always @(posedge clk) begin
        // Accessing DUT internal A,B,C via hierarchical path (works in most simulators / Vivado)
        $display("%8t :  %b %b %b |   %b    |   %b %b %b  |  %b  %b  %b  |  %b  %b  %b",
                 $time, T, L, R, enable,
                 dut.A, dut.B, dut.C,
                 RA, RB, RC,
                 LA, LB, LC);
    end

    // Test sequence
    initial begin
        // initialize
        T = 1; L = 0; R = 0; enable = 0;
        #50;               // let a few clocks pass with reset asserted

        // release reset
        T = 0;
        #20;

        // ---------------- Test 1: Single Left sequence ----------------
        $display("\n--- Test 1: Single Left sequence ---");
        L = 1; R = 0; enable = 1;   // hold enable so FSM steps every clock
        #80;                        // ~8 clock cycles -> enough to see full sequence
        enable = 0; L = 0;
        #30;

        // ---------------- Test 2: Hold Left to repeat ----------------
        $display("\n--- Test 2: Hold Left to repeat pattern ---");
        L = 1; R = 0; enable = 1;
        #160;                       // longer so the pattern repeats at least once
        enable = 0; L = 0;
        #30;

        // ---------------- Test 3: Single Right sequence ----------------
        $display("\n--- Test 3: Single Right sequence ---");
        R = 1; L = 0; enable = 1;
        #80;
        enable = 0; R = 0;
        #30;

        // ------------- Test 4: Both pressed (Left priority) ------------
        $display("\n--- Test 4: Both pressed (Left priority) ---");
        L = 1; R = 1; enable = 1;
        #160;
        enable = 0; L = 0; R = 0;
        #30;

        // ------------- Test 5: Reset asserted mid-sequence ------------
        $display("\n--- Test 5: Reset asserted mid-sequence ---");
        L = 1; R = 0; enable = 1;
        #30;       // step into the left sequence
        T = 1;     // assert reset while enabled
        #30;
        T = 0;     // release reset
        enable = 0; L = 0;
        #40;

        $display("\n--- TESTS COMPLETE ---");
        #50;
        $finish;
    end

endmodule
