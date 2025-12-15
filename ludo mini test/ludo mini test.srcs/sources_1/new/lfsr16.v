// lfsr16.v
`timescale 1ns/1ps
module lfsr16 (
    input  wire clk,
    input  wire advance,
    output reg  [15:0] q
);
    // Galois LFSR with taps for x^16 + x^14 + x^13 + x^11 + 1 (poly 0xB400)
    // seed must be non-zero
    initial q = 16'hACE1; // non-zero seed
    always @(posedge clk) begin
        if (advance) begin
            // Galois shift: newbit = xor of selected taps of q[0]
            // Implemented as: if q[0]==1, q = (q >> 1) ^ 16'hB400 else q = q >> 1
            if (q[0])
                q <= (q >> 1) ^ 16'hB400;
            else
                q <= (q >> 1);
        end
    end
endmodule
