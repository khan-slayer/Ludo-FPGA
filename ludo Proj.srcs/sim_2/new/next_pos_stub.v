// next_pos_stub.v - simple next = pos + 1 (wrap at 23), handles base->exit mapping
module next_pos (
  input  wire [5:0] pos,
  input  wire blue_at_8,
  input  wire red_at_8,
  input  wire blue_at_19,
  input  wire red_at_19,
  output reg  [5:0] next
);
  always @(*) begin
    if (pos >= 6'd0 && pos <= 6'd22) begin
      if (pos == 6'd22) next = 6'd22; // finish stays
      else next = pos + 6'd1;
    end else begin
      // base positions 23..26: next stays same unless exit handled in FSM externally
      next = pos;
    end
  end
endmodule
