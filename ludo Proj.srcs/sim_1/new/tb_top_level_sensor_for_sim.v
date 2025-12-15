`timescale 1ns/1ps

module tb_latch_top_level_sim;

    reg clk;
    reg btnC;
    reg btnU;
    reg [1:0] ja_in;
    wire [1:0] led;

    latch_top_level_sim DUT(
        .clk_100mhz (clk),
        .btnC       (btnC),
        .btnU       (btnU),
        .ja_in      (ja_in),
        .led        (led)
    );

    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulate confirm button press
    task press_confirm;
        begin
            btnU = 1;
            #20;
            btnU = 0;
            #20;
        end
    endtask

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0, tb_latch_top_level_sim);

        // Initial state
        btnC = 0;
        btnU = 0;
        ja_in = 2'b11;   // both sensors idle (active-low)

        // RESET
        #20 btnC = 1;
        #30 btnC = 0;

        // ------------------------------
        // CASE 1: Sensor 0 detects object
        // ------------------------------
        #50 ja_in[0] = 0;   // active-low ? object present
        press_confirm();     // LED0 latches

        // ------------------------------
        // CASE 2: Sensor 1 detects object
        // ------------------------------
        #50 ja_in[1] = 0;
        press_confirm();     // LED1 latches

        // ------------------------------
        // CASE 3: Sensors change again
        // ------------------------------
        #100 ja_in = 2'b11;  // no object
        press_confirm();     // LEDs should latch updated state

        #200;
        
            // ------------------------------
        // CASE 4: Sensors ON, then RESET pressed
        // ------------------------------
        #100;
        $display("=== CASE 4: Sensors ON then RESET ===");
    
        // Sensors active (meaning piece present)
        ja_in = 2'b00;       // both sensors ON (active-low)
        press_confirm();     // latch both LEDs = should become 1
    
        #50;
        // Now apply RESET
        btnC = 1;
        #30;
        btnC = 0;            // release reset
    
        // After reset, LEDs should be cleared to 0
        #50;

        $finish;
        
    end

endmodule
