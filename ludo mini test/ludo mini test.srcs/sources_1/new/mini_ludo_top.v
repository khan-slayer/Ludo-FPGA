// mini_ludo_top.v
// 6-sensor top: uses sensor latches (snapshot-only-on-confirm), random LFSR dice,
// 7-seg display, and LEDs to indicate occupancy & move-out on dice==6.
//
// Assumptions:
// - You have an improved_sensor_latch (or sensor_latch) module available with:
//     .clk, .reset, .sensor_in, .confirm_btn, .sensor_out
//   and you instantiate it with INVERT_SENSOR=1 (since your IR gives 0 when object present).
// - You have dice_random.v, lfsr16.v, sevenseg_decoder.v, btn_sync_debounce.v included
// - sensor_raw[5:0] are raw sensor inputs (from IR modules or shift165 reader, active-low on detection)

`timescale 1ns/1ps
module mini_ludo_top (
    input  wire        clk,           // 100 MHz
    input  wire        btn_roll,      // roll button (debounced inside)
    input  wire        btn_confirm,   // confirm button (debounced inside) - global snapshot
    input  wire [5:0]  sensor_raw,    // raw sensor inputs (active-low on detection)
    output wire [7:0]  led,           // LD0..LD7
    output wire [6:0]  seg,           // 7-seg a..g (seg[0]=a ... seg[6]=g)
    output wire [3:0]  an             // anodes
);

    // debounce both buttons (use the same debounce module you have)
    wire btn_roll_db, btn_confirm_db;
    btn_sync_debounce #(.CLK_FREQ_HZ(100_000_000), .DEB_MS(5)) roll_db (
        .clk(clk), .btn(btn_roll), .btn_out(btn_roll_db)
    );
    btn_sync_debounce #(.CLK_FREQ_HZ(100_000_000), .DEB_MS(10)) confirm_db (
        .clk(clk), .btn(btn_confirm), .btn_out(btn_confirm_db)
    );

    // --- sensor latches (6) ---
    wire [5:0] sensor_latched;
    genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : LATCHES
            // Use your existing module name; if you use the improved version, change name accordingly
            // Instantiation below assumes a module named 'sensor_latch' with parameter INVERT_SENSOR
            sensor_latch #(
                .INVERT_SENSOR(1) // your IR gives 0 on detection -> invert to 1 = present
            ) sl (
                .clk(clk),
                .reset(1'b0),
                .sensor_in(sensor_raw[i]),
                .confirm_btn(btn_confirm_db),
                .sensor_out(sensor_latched[i])
            );
        end
    endgenerate

    // --- map sensor_latched into the game logic (same mapping you used in mini-test) ---
    wire base1_present = sensor_latched[0] | sensor_latched[1]; // two sensors for base1
    wire base2_present = sensor_latched[2] | sensor_latched[3]; // two sensors for base2
    wire start1_present = sensor_latched[4];
    wire start2_present = sensor_latched[5];

    // --- Random dice generator (LFSR + rejection sampling) ---
    wire [2:0] dice_live;
    dice_random #(.PRESCALE(2000000)) dr (
        .clk(clk),
        .enable(btn_roll_db), // while you hold roll, generator spins
        .out(dice_live)
    );

    // latch dice on release (falling edge of debounced roll button)
    reg btn_roll_db_prev = 1'b0;
    always @(posedge clk) btn_roll_db_prev <= btn_roll_db;

    reg [2:0] dice_latched = 3'd1;
    always @(posedge clk) begin
        if (btn_roll_db_prev && !btn_roll_db) begin
            dice_latched <= dice_live;
        end
    end

    // --- seven segment display (shows latched dice) ---
    sevenseg_decoder segdec (
        .value(dice_latched),
        .seg(seg)
    );
    assign an = 4'b1110; // enable digit 0 only (active-low anodes on Basys3)

    // --- LED logic ---
    // LED assignment convention we used in tests:
    // led[0] - base1 move-out (lights if dice==6 and base1_present)
    // led[1] - base2 move-out (lights if dice==6 and base2_present)
    // led[2] - base1 occupied (sensor_latched[0] or [1])
    // led[3] - base2 occupied (sensor_latched[2] or [3])
    // led[4] - start1 occupied (sensor_latched[4])
    // led[5] - start2 occupied (sensor_latched[5])
    // led[6], led[7] - reserved/debug
    reg [7:0] leds_reg = 8'b0;
    always @(posedge clk) begin
        leds_reg <= 8'b0; // clear each cycle then assert indicators
        if (base1_present) leds_reg[2] <= 1'b1;
        if (base2_present) leds_reg[3] <= 1'b1;
        if (start1_present) leds_reg[4] <= 1'b1;
        if (start2_present) leds_reg[5] <= 1'b1;

        if (dice_latched == 3'd6) begin
            if (base1_present) leds_reg[0] <= 1'b1;
            if (base2_present) leds_reg[1] <= 1'b1;
        end
    end
    assign led = leds_reg;

endmodule
