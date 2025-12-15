`timescale 1ns / 1ps
// =====================================================
// sensor_latch_sim.v  (DEBOUNCE-LESS VERSION FOR TB)
// =====================================================
module sensor_latch_sim #(
    parameter INVERT_SENSOR = 1
) (
    input  wire clk,
    input  wire reset,
    input  wire sensor_in,
    input  wire confirm_btn,
    output reg  sensor_out
);

    // Clean sensor (no debounce, only invert if needed)
    wire sensor_clean = INVERT_SENSOR ? ~sensor_in : sensor_in;

    // Latch on confirm rising edge
    reg confirm_prev;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sensor_out    <= 1'b0;
            confirm_prev  <= 1'b0;
        end else begin
            confirm_prev <= confirm_btn;

            if (!confirm_prev && confirm_btn) begin
                sensor_out <= sensor_clean;
            end
        end
    end
endmodule
