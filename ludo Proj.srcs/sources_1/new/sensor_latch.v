`timescale 1ns / 1ps
// =====================================================
// sensor_latch.v
// Debounces sensor + latches state on button press
// =====================================================
module sensor_latch #(
    parameter INVERT_SENSOR = 1  // 1 = active-low (object = 0)
) (
    input  wire clk,
    input  wire reset,
    input  wire sensor_in,
    input  wire confirm_btn,     // Button press = update
    output reg  sensor_out       // Latched, stable output
);

    // Debounce (same as before)
    reg [19:0] debounce_cnt;
    reg sensor_sync;
    reg sensor_debounced;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sensor_sync      <= 1'b1;
            debounce_cnt     <= 20'b0;
            sensor_debounced <= 1'b1;
        end else begin
            sensor_sync <= sensor_in;

            if (sensor_sync == sensor_debounced) begin
                debounce_cnt <= 20'b0;
            end else begin
                debounce_cnt <= debounce_cnt + 1;
                if (debounce_cnt == 20'hF_FFFF) begin  // ~10 ms
                    sensor_debounced <= sensor_sync;
                end
            end
        end
    end

    // Invert if needed
    wire sensor_clean = INVERT_SENSOR ? ~sensor_debounced : sensor_debounced;

    // === LATCH ON BUTTON PRESS ===
    reg confirm_prev;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sensor_out    <= 1'b0;
            confirm_prev  <= 1'b0;
        end else begin
            confirm_prev <= confirm_btn;

            // Rising edge of confirm_btn ? latch current state
            if (confirm_prev == 1'b0 && confirm_btn == 1'b1) begin
                sensor_out <= sensor_clean;
            end
        end
    end

endmodule