// btn_sync_debounce.v
// Synchronize an asynchronous button, debounce it, and provide a single-cycle pulse on a debounced rising edge.
// Parameters tuned for moderate button bounce; adjust COUNTER_MAX to change debounce time.
// Assumes 'clk' frequency known (e.g. 50 MHz -> set COUNTER_MAX accordingly)
`timescale 1ns / 1ps
module btn_sync_debounce #(
  parameter integer COUNTER_WIDTH = 20  // 2^20 clocks debounce (tunable)
)(
  input  wire clk,
  input  wire reset,      // active-high synchronous reset
  input  wire btn_async,  // raw external button (active high)
  output reg  btn_state,  // debounced steady state
  output reg  btn_pulse   // 1-cycle pulse when debounced rising edge occurs
);

  // 2-stage synchronizer
  reg sync0, sync1;
  always @(posedge clk) begin
    if (reset) begin
      sync0 <= 1'b0;
      sync1 <= 1'b0;
    end else begin
      sync0 <= btn_async;
      sync1 <= sync0;
    end
  end

  // simple majority/counting debounce:
  reg [COUNTER_WIDTH-1:0] cnt;
  reg stable;

  always @(posedge clk) begin
    if (reset) begin
      cnt <= {COUNTER_WIDTH{1'b0}};
      stable <= 1'b0;
      btn_state <= 1'b0;
      btn_pulse <= 1'b0;
    end else begin
      btn_pulse <= 1'b0;
      // if sampled input equals current stable, reset counter
      if (sync1 == stable) begin
        cnt <= {COUNTER_WIDTH{1'b0}};
      end else begin
        // Otherwise increment; when counter saturates we accept the new state
        if (cnt == {COUNTER_WIDTH{1'b1}}) begin
          stable <= sync1;
          btn_state <= sync1;
          // if rising edge (0->1) produce pulse
          if (sync1 == 1'b1) btn_pulse <= 1'b1;
          cnt <= {COUNTER_WIDTH{1'b0}};
        end else begin
          cnt <= cnt + 1'b1;
        end
      end
    end
  end

endmodule
