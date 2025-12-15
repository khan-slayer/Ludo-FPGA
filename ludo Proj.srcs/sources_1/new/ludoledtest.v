`timescale 1ns/1ps
module LudoLedTest(
    input  wire       clk,
    input  wire       reset,
 
    // From Ludo game
    input  wire [26:0] board_next,
    // From IR-sensor module (you already have it)
    input  wire [26:0] board_occ,
 
    // 16-bit LED output (connect to FPGA pins)
    output wire [15:0] led
);
 
    // -------------------------------------------------
    // 1. Synchronisation
    // -------------------------------------------------
    wire sync;
    wire [26:0] board_display;
 
    BoardSync sync_inst (
        .clk          (clk),
        .reset        (reset),
        .board_next   (board_next),
        .board_occ    (board_occ),
        .sync         (sync),
        .board_display(board_display)
    );
 
    
 
    assign led = {
        board_display[26], board_display[25],
        board_display[24], board_display[23],
        board_display[22],
        board_display[0],  board_display[1],
        board_display[2],  board_display[3],
        board_display[4],  board_display[5],
        board_display[11], board_display[12],
        board_display[13], board_display[14],
        board_display[15]
    };
 
    // -------------------------------------------------
    // 3. Optional visual cue when sync is lost
    // -------------------------------------------------
    // Blink the MSB LED (LED[15]) fast when not synced.
    // This is completely optional - delete if you don't want it.
//    reg [23:0] blink_cnt;
//    reg        blink_led;
 
//    always @(posedge clk) begin
//        if (reset) begin
//            blink_cnt <= 0;
//            blink_led <= 0;
//        end else begin
//            blink_cnt <= blink_cnt + 1'b1;
//            if (blink_cnt == 0) blink_led <= ~blink_led;
//        end
//    end
 
//    // Override LED[15] only when sync==0
//    assign led[15] = sync ? board_display[26] : blink_led;
 
endmodule