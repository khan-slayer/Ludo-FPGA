// sevenseg_decoder.v
// value 0..6 -> 7-seg pattern (a..g). Assumes active LOW segments (0 lights).
`timescale 1ns/1ps
module sevenseg_decoder (
    input  wire [2:0] value, // 1..6 expected
    output reg  [6:0] seg    // a,b,c,d,e,f,g
);
    always @(*) begin
        // default blank (all off -> all 1 for active-low)
        seg = 7'b1111111;
        case (value)
            3'd1: seg = 7'b1111001; // 1
            3'd2: seg = 7'b0100100; // 2
            3'd3: seg = 7'b0110000; // 3
            3'd4: seg = 7'b0011001; // 4
            3'd5: seg = 7'b0010010; // 5
            3'd6: seg = 7'b0000010; // 6
            default: seg = 7'b1111111;
        endcase
    end
endmodule
