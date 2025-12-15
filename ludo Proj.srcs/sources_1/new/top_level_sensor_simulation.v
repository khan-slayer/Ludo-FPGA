`timescale 1ns / 1ps

module latch_top_level_sim (
    input  wire clk_100mhz,
    input  wire btnC,
    input  wire btnU,
    input  wire [1:0] ja_in,
    output wire [1:0] led
);

    // RESET sync
    reg [1:0] reset_sync;
    always @(posedge clk_100mhz) begin
        reset_sync[0] <= btnC;
        reset_sync[1] <= reset_sync[0];
    end
    wire reset = reset_sync[1];

    // CONFIRM sync
    reg [1:0] confirm_sync;
    always @(posedge clk_100mhz) begin
        confirm_sync[0] <= btnU;
        confirm_sync[1] <= confirm_sync[0];
    end
    wire confirm_btn = confirm_sync[1];

    // Two sensors (sim version)
    sensor_latch_sim #(1) u0 (
        .clk(clk_100mhz),
        .reset(reset),
        .sensor_in(ja_in[0]),
        .confirm_btn(confirm_btn),
        .sensor_out(led[0])
    );

    sensor_latch_sim #(1) u1 (
        .clk(clk_100mhz),
        .reset(reset),
        .sensor_in(ja_in[1]),
        .confirm_btn(confirm_btn),
        .sensor_out(led[1])
    );

endmodule
