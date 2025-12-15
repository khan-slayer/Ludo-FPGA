`timescale 1ns / 1ps
module latch_top_level (
    input  wire clk_100mhz,
    input  wire btnC,           // RESET (center)
    input  wire btnU,           // CONFIRM MOVE (up)
    input  wire [1:0] ja_in,    // JA1 = sensor 1, JA2 = sensor 2
    output wire [1:0] led       // LED0 = Square 1, LED1 = Square 2
);

    // === RESET: Synchronize btnC ===
    wire reset;
    reg [1:0] reset_sync;
    always @(posedge clk_100mhz) begin
        reset_sync[0] <= btnC;
        reset_sync[1] <= reset_sync[0];
    end
    assign reset = reset_sync[1];

    // === CONFIRM: Synchronize btnU ===
    wire confirm_btn;
    reg [1:0] confirm_sync;
    always @(posedge clk_100mhz) begin
        confirm_sync[0] <= btnU;
        confirm_sync[1] <= confirm_sync[0];
    end
    assign confirm_btn = confirm_sync[1];

    // === Instantiate 2 latched sensors ===
    sensor_latch #(1) u_sensor1 (
        .clk         (clk_100mhz),
        .reset       (reset),
        .sensor_in   (ja_in[0]),
        .confirm_btn (confirm_btn),
        .sensor_out  (led[0])
    );

    sensor_latch #(1) u_sensor2 (
        .clk         (clk_100mhz),
        .reset       (reset),
        .sensor_in   (ja_in[1]),
        .confirm_btn (confirm_btn),
        .sensor_out  (led[1])
    );

endmodule