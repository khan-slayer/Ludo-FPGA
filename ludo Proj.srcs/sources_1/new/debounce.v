// debounce.v
// Debounce + 2-stage synchronizer for a single input
module debounce #(
  parameter integer CLK_HZ = 100_000_000,
  parameter integer DEBOUNCE_MS = 20
)(
  input  wire clk,
  input  wire rst_n,
  input  wire in,       // raw asynchronous input (button)
  output reg  out       // debounced synchronized output
);
  localparam integer TICKS = (CLK_HZ/1000) * DEBOUNCE_MS;
  localparam integer CNT_WIDTH = $clog2(TICKS+1);

  reg in_sync0, in_sync1;
  reg [CNT_WIDTH-1:0] cnt;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      in_sync0 <= 1'b0;
      in_sync1 <= 1'b0;
      cnt <= 0;
      out <= 1'b0;
    end else begin
      // 2-stage synchronization
      in_sync0 <= in;
      in_sync1 <= in_sync0;

      if (in_sync1 == out) begin
        cnt <= 0;
      end else begin
        if (cnt >= TICKS) begin
          out <= in_sync1;
          cnt <= 0;
        end else begin
          cnt <= cnt + 1'b1;
        end
      end
    end
  end
endmodule
