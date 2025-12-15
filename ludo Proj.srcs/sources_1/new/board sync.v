`timescale 1ns / 1ps
 
module BoardSync(
    input wire clk,
    input wire reset,
    // From Ludo game module
    input wire [26:0] board_next,
    // From IR sensor module (real board occupancy)
    input wire [26:0] board_occ,
    // Outputs
    output reg sync,           // 1 if board_next == board_occ
    output wire [26:0] board_display  // = board_next (for VGA when sync=1)
);
 
    // Pass-through for VGA display
    assign board_display = board_next;
    // Synchronous comparison
    always @(posedge clk) begin
        if (reset) begin
            sync <= 1'b0;
        end else begin
            sync <= (board_next == board_occ);
        end
    end
 
endmodule