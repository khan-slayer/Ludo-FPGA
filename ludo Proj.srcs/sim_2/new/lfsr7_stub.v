// lfsr7_stub.v - small LFSR-ish counter stub for deterministic dice in TB
module lfsr7 (
  input  wire clk,
  input  wire rst_n,
  output reg [6:0] q
);
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) q <= 7'd1;
    else q <= q + 7'd17; // pseudo-random-ish increment
  end
endmodule
