`timescale 1ns/1ps
//`include "ludo_logic_version2_abdullahs"

module tb;
  reg clk = 0;
  reg rst_n = 0;

  // pulses to LudoFull (no debouncer in TB)
  reg roll_pulse = 0;
  reg red_select_pulse = 0;
  reg blue_select_pulse = 0;
  reg move_confirm_pulse = 0;

  // board_occ and snapshot
  reg [26:0] board_occ = 27'b0;
  reg new_board_snapshot = 0;

  wire [2:0] dice_value;
  wire dice_valid_pulse;
  wire [1:0] red_selected_piece;
  wire [1:0] blue_selected_piece;
  wire expect_sensor_snapshot;
  wire accept_move_via_confirm;
  wire [5:0] r0, r1, b0, b1;
  wire [7:0] dbg;

  // instantiate LudoFull (must match your updated LudoFull port order)
  LudoFull dut (
    .clk(clk),
    .rst_n(rst_n),
    .roll_pulse(roll_pulse),
    .red_select_pulse(red_select_pulse),
    .blue_select_pulse(blue_select_pulse),
    .board_occ(board_occ),
    .new_board_snapshot(new_board_snapshot),
    .dice_value(dice_value),
    .dice_valid_pulse(dice_valid_pulse),
    .red_selected_piece(red_selected_piece),
    .blue_selected_piece(blue_selected_piece),
    .red_piece_pos0(r0),
    .red_piece_pos1(r1),
    .blue_piece_pos0(b0),
    .blue_piece_pos1(b1),
    .seg(), .an(), .debug_leds(dbg),
    .move_confirm_pulse(move_confirm_pulse),
    .expect_sensor_snapshot(expect_sensor_snapshot),
    .accept_move_via_confirm(accept_move_via_confirm)
  );

  // clock
  always #5 clk = ~clk; // 100 MHz

  integer step=0;

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    // reset
    #20; rst_n = 1;
    $display("[%0t] RELEASE RESET", $time);

    // ---------- Turn 1: Red starts automatically per LudoFull design ----------
    // 1) Roll
    #20; pulse(roll_pulse);
    #10;
    $display("[%0t] dice_value=%0d dice_valid=%b", $time, dut.dice_value, dut.dice_valid_pulse);

    // 2) No select (simulate player presses confirm directly) -> auto-select should fire
    #20; // wait a bit
    if (accept_move_via_confirm) begin
      $display("[%0t] Accepting move via confirm (S_SELECT). Sending move_confirm_pulse", $time);
      pulse(move_confirm_pulse);
    end else begin
      $display("[%0t] ERROR: Ludo not accepting confirm now!", $time);
    end
    #50;

    // 3) Wait for Ludo to request sensor snapshot
    wait (expect_sensor_snapshot == 1);
    $display("[%0t] Ludo expects physical snapshot (expect_sensor_snapshot=%b)", $time, expect_sensor_snapshot);

    // 4) Provide board_occ matching expected final logical positions.
    //    We'll query dut moving position: it's internal; approximate: assume red piece 0 moved to pos 0
    //    For this TB we simply set board_occ[0] = 1 and pulse snapshot
    board_occ = 27'b0;
    board_occ[0] = 1'b1;
    #20; pulse(new_board_snapshot); // tell Ludo new sensor snapshot available
    #50;

    // print positions
    $display("[%0t] After snapshot compare: r0=%0d r1=%0d b0=%0d b1=%0d", $time, r0, r1, b0, b1);

    // ---------- Turn 2: Blue's turn ----------
    #100;
    $display("[%0t] Starting turn 2 (Blue)", $time);

    // Roll for Blue
    #10; pulse(roll_pulse);
    #10;
    $display("[%0t] dice_value=%0d", $time, dut.dice_value);

    // Blue selects piece1 (press select twice)
    #10; pulse(blue_select_pulse); #10; pulse(blue_select_pulse);
    $display("[%0t] blue_selected_piece=%0d", $time, blue_selected_piece);

    // Confirm (commit move)
    #20;
    if (accept_move_via_confirm) pulse(move_confirm_pulse);
    else $display("[%0t] Can't confirm now!", $time);

    // Wait for snapshot and provide board_occ reflecting the move target (assume pos 11 for blue exit)
    wait (expect_sensor_snapshot == 1);
    board_occ = 27'b0;
    board_occ[11] = 1'b1;
    #20; pulse(new_board_snapshot);
    #50;

    $display("[%0t] Final positions r0=%0d r1=%0d b0=%0d b1=%0d", $time, r0, r1, b0, b1);

    #200;
    $display("[%0t] TEST COMPLETE", $time);
    $finish;
  end

  // helper task to create a single-cycle pulse
  // helper task to create a single-clock synchronous pulse (aligned to posedge clk)
// synchronous single-clock pulse task (aligned to posedge clk)
// synchronous single-clock pulse task (aligned to posedge clk)
task pulse(output reg sig);
begin
  @(posedge clk);    // wait for rising edge
  sig = 1'b1;        // assert on-clock
  @(posedge clk);    // keep asserted for one full clock cycle
  sig = 1'b0;        // deassert
  #1;                // small delta to avoid races
end
endtask



endmodule
