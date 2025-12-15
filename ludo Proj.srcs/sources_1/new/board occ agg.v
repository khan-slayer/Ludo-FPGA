// BoardOccAggregator.v
`timescale 1ns / 1ps
module BoardOccAggregator #(
  parameter integer NUM_SENSORS = 27,
  parameter INVERT_SENSOR = 1  // 1 = sensors active-low (object blocks -> 0)
)(
  input  wire                     clk,
  input  wire                     reset,       // active-high synchronous reset
  input  wire [NUM_SENSORS-1:0]   sensors_in,  // raw sensor bus (sampled each clk)
  input  wire                     confirm_btn, // raw/synchronized button pulse is OK (we re-sync inside)
  output reg  [NUM_SENSORS-1:0]   board_occ,   // latched snapshot of board occupancy
  output reg                      latched_valid // one clk pulse when board_occ updated
);

  // 2-stage synchronizer for confirm
  reg confirm0, confirm1;
  always @(posedge clk) begin
    if (reset) begin
      confirm0 <= 1'b0;
      confirm1 <= 1'b0;
    end else begin
      confirm0 <= confirm_btn;
      confirm1 <= confirm0;
    end
  end

  // detect rising edge
  reg confirm1_d;
  always @(posedge clk) begin
    if (reset) confirm1_d <= 1'b0;
    else        confirm1_d <= confirm1;
  end
  wire confirm_posedge = confirm1 & ~confirm1_d;

  // sample sensors into a register (avoid reading many async inputs at the exact latch time)
  reg [NUM_SENSORS-1:0] sensors_sample;
  always @(posedge clk) begin
    if (reset) sensors_sample <= {NUM_SENSORS{1'b0}};
    else       sensors_sample <= sensors_in;
  end

  // produce latched sensor vector on posedge of confirm
  reg [NUM_SENSORS-1:0] sensor_latched;
  always @(posedge clk) begin
    if (reset) begin
      sensor_latched <= {NUM_SENSORS{1'b0}};
      board_occ <= {NUM_SENSORS{1'b0}};
      latched_valid <= 1'b0;
    end else begin
      latched_valid <= 1'b0;
      if (confirm_posedge) begin
        if (INVERT_SENSOR)
          sensor_latched <= ~sensors_sample;
        else
          sensor_latched <= sensors_sample;
        latched_valid <= 1'b1;
      end
      // present stable board_occ (synced to clk)
      board_occ <= sensor_latched;
    end
  end

endmodule
