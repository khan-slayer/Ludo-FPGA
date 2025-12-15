// dice_random.v
`timescale 1ns/1ps
module dice_random #(
    parameter integer PRESCALE = 2000000  // adjust for visible flicker (100MHz clk)
) (
    input  wire clk,
    input  wire enable,     // when high, generator runs and updates 'out' on accepted samples
    output reg  [2:0] out   // 1..6 encoded
);

    // prescaler to generate a tick at visible rate
    reg [31:0] pres_cnt;
    reg tick;
    always @(posedge clk) begin
        if (!enable) begin
            pres_cnt <= 0;
            tick <= 1'b0;
        end else begin
            if (pres_cnt >= PRESCALE-1) begin
                pres_cnt <= 0;
                tick <= 1'b1;
            end else begin
                pres_cnt <= pres_cnt + 1;
                tick <= 1'b0;
            end
        end
    end

    // LFSR instance
    wire [15:0] lfsr_q;
    reg lfsr_advance;
    lfsr16 lfsr_inst (
        .clk(clk),
        .advance(lfsr_advance),
        .q(lfsr_q)
    );

    // Rejection sampling: on each tick, advance LFSR and examine low 3 bits.
    // If candidate (0..7) < 6, accept and output candidate+1.
    // If candidate >=6, reject and continue on next tick.
    always @(posedge clk) begin
        if (!enable) begin
            out <= 3'd1;          // default showing 1 when idle
            lfsr_advance <= 1'b0;
        end else begin
            if (tick) begin
                // step LFSR and sample (we toggle advance for a cycle)
                lfsr_advance <= 1'b1;
            end else begin
                // clear advance after one cycle (so LFSR changes on tick only)
                if (lfsr_advance) lfsr_advance <= 1'b0;
            end

            // Accept candidate whenever LFSR has advanced this cycle (use sampled bits)
            // Use lfsr_q directly; its low bits reflect last state. To ensure stable sampling,
            // we accept when tick==1 or just after lfsr_advance goes low (safe enough).
            if (tick) begin
                // candidate is lfsr_q[2:0] after the shift; because lfsr_advance is asserted
                // on the same cycle, we will use the new state in the next cycle.
                // For deterministic sampling, accept on the following cycle:
                // So do nothing here and instead sample when lfsr_advance goes low.
            end

            // When lfsr_advance goes from 1 to 0 (i.e., the cycle after we asked for advance),
            // the LFSR has stable new bits; sample them.
            if (lfsr_advance == 1'b1 && tick == 1'b0) begin
                // This branch occurs the clock cycle after tick when advance was set.
                // Sample lfsr_q now (it contains the new value)
                if (lfsr_q[2:0] < 3'd6) begin
                    out <= lfsr_q[2:0] + 3'd1; // map 0..5 -> 1..6
                end
                // else reject; out stays as previous value until next accepted sample
            end
        end
    end

endmodule
