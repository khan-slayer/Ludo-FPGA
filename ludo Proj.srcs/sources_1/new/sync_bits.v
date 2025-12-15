// sync_bits.v
// Multi-bit 2-stage synchronizer. Use to safely bring sensor bus into clock domain.
module sync_bits #(
  parameter WIDTH = 23
)(
  input  wire clk,
  input  wire rst_n,
  input  wire [WIDTH-1:0] async_in,
  output reg  [WIDTH-1:0] sync_out
);
  reg [WIDTH-1:0] s1;
  integer i;
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      s1 <= {WIDTH{1'b0}};
      sync_out <= {WIDTH{1'b0}};
    end else begin
      s1 <= async_in;
      sync_out <= s1;
    end
  end
endmodule
