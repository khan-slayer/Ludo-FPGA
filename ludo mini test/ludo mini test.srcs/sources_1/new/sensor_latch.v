`timescale 1ns / 1ps
// improved_sensor_latch.v
// Debounces sensor + latches state on confirm button edge.
// - Two-flop synchronizer for async sensor input
// - Parameterizable debounce (in clock cycles)
// - Configurable inversion (INVERT_SENSOR = 1 for active-low sensor)
// - Configurable latch edge (LATCH_ON_RISING = 1 -> latch on rising edge of confirm)
module sensor_latch #(
    parameter INVERT_SENSOR = 1,           // 1 = sensor active-low (object -> 0)
    parameter integer DEB_TICKS = 1_000_000, // number of clocks to confirm new level (100MHz -> 10 ms)
    parameter LATCH_ON_RISING = 1
) (
    input  wire clk,
    input  wire reset,        // async reset, active high
    input  wire sensor_in,    // raw sensor input (async)
    input  wire confirm_btn,  // **should be debounced** before connecting here
    output reg  sensor_out    // Latched stable output (1 = object present if INVERT_SENSOR=1)
);

    // --------------- synchronizer ----------------
    reg sync0, sync1;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sync0 <= 1'b1;
            sync1 <= 1'b1;
        end else begin
            sync0 <= sensor_in;
            sync1 <= sync0;
        end
    end

    // --------------- debounce/hysteresis -------------
    reg [31:0] cnt;
    reg stable; // debounced sensor (same polarity as sync1)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cnt <= 0;
            stable <= 1'b1; // assume no-object at reset (high if active-low sensors)
        end else begin
            if (sync1 == stable) begin
                cnt <= 0;
            end else begin
                if (cnt >= DEB_TICKS-1) begin
                    stable <= sync1;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end

    // apply inversion if sensor is active-low
    wire sensor_clean = INVERT_SENSOR ? ~stable : stable;

    // --------------- latch on confirm edge ------------
    reg confirm_prev;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            confirm_prev <= 1'b0;
            sensor_out <= 1'b0;
        end else begin
            confirm_prev <= confirm_btn;
            if (LATCH_ON_RISING) begin
                if (!confirm_prev && confirm_btn) begin
                    sensor_out <= sensor_clean;
                end
            end else begin
                if (confirm_prev && !confirm_btn) begin
                    sensor_out <= sensor_clean;
                end
            end
        end
    end

endmodule
