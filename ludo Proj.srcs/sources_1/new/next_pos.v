// next_pos.v
// Combinational next-position logic for one step, using your board linkage rules.
//
// Indices used:
// Outer ring: 0->1->...->18->19->0 (with special branching at 8 and 19 described below)
// Red final: 20,21 -> 22 (home)
// Blue final: 9,10 -> 22 (home)
// Home = 22 (stays)
// Base: red base 23,24 ; blue base 25,26 (handled outside)
module next_pos (
  input  wire [5:0] pos,
  input  wire blue_at_8,
  input  wire red_at_8,
  input  wire blue_at_19,
  input  wire red_at_19,
  output reg  [5:0] next
);
  always @(*) begin
    case (pos)
      6'd22: next = 6'd22; // home stay
      6'd8: begin
        if (blue_at_8) next = 6'd9;
        else if (red_at_8) next = 6'd11;
        else next = 6'd9; // default forward
      end
      6'd19: begin
        if (red_at_19) next = 6'd20;
        else if (blue_at_19) next = 6'd0;
        else next = 6'd0; // default wrap
      end
      6'd20, 6'd21: next = pos + 6'd1; // red final path to 22
      // Blue final path: 9 -> 10 -> 22 (handled by outer mapping since 9 & 10 are sequences)
      default: next = pos + 6'd1;
    endcase
  end
endmodule
