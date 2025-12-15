// btn_sync_debounce.v
`timescale 1ns/1ps
module btn_sync_debounce #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer DEB_MS = 20
) (
    input  wire clk,
    input  wire btn,
    output reg  btn_out
);
    // 20 ms debounce counter
    localparam integer CNT_MAX = (CLK_FREQ_HZ/1000)*DEB_MS;
    reg [31:0] cnt;
    reg btn_sync0, btn_sync1, btn_stable;

    always @(posedge clk) begin
        btn_sync0 <= btn;
        btn_sync1 <= btn_sync0;
        if (btn_sync1 == btn_stable) begin
            cnt <= 0;
        end else begin
            if (cnt < CNT_MAX) cnt <= cnt + 1;
            else begin
                btn_stable <= btn_sync1;
            end
        end
        btn_out <= btn_stable;
    end
endmodule
