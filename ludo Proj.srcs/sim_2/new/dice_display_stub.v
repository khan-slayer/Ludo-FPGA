// dice_display_stub.v - no-op stub
module dice_display (
  input wire clk, input wire rst_n,
  input wire [2:0] value, input wire strobe,
  output wire [6:0] seg, output wire [7:0] an
);
  assign seg = 7'b0;
  assign an = 8'b0;
endmodule
