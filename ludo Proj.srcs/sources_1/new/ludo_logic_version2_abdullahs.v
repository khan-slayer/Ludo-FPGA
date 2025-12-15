// ludo_logic_version2_abdullahs.v
`timescale 1ns / 1ps
// =====================================================
// LudoFull
// 2-player (Red/Blue) Ludo game logic for 2 pieces each.
// Consumes board_occ[26:0] - authoritative latched snapshot from BoardOccAggregator.
//
// This file exposes:
//  - move_confirm_pulse (input) : a single-cycle pulse to commit the logical move (from top).
//  - expect_sensor_snapshot (output) : high while waiting for physical confirm/snapshot.
//  - accept_move_via_confirm (output) : high while in SELECT and the top may route confirm to Ludo.
// =====================================================

module LudoFull (
  input  wire        clk,
  input  wire        rst_n,               // active-low reset

  // Single-cycle pulses (provided by top-level debounce/sync)
  input  wire        roll_pulse,          // 1-clock pulse to roll dice
  input  wire        red_select_pulse,    // 1-clock pulse to toggle red selected piece (0/1)
  input  wire        blue_select_pulse,   // 1-clock pulse to toggle blue selected piece (0/1)
  input  wire        move_confirm_pulse,  // 1-clock pulse to commit logical move (from Confirm routed by top)

  // Aggregated occupancy vector (27 bits) latched by BoardOccAggregator
  input  wire [26:0] board_occ,           // board_occ[i] == 1 => sensor i detected piece
  input  wire        new_board_snapshot,  // 1-cycle pulse when aggregator updated board_occ (optional)
  input wire [2:0] dice_in, // external latched dice (1..6)

  // Outputs
  output reg  [2:0]  dice_value,          // 1..6
  output reg         dice_valid_pulse,    // single-cycle pulse when dice_value updated

  output reg  [1:0]  red_selected_piece,
  output reg  [1:0]  blue_selected_piece,

  // Piece positions for display/UI (0..26: 0..22 board, 23-24 red base, 25-26 blue base)
  output reg  [5:0]  red_piece_pos0,
  output reg  [5:0]  red_piece_pos1,
  output reg  [5:0]  blue_piece_pos0,
  output reg  [5:0]  blue_piece_pos1,

  // 7-seg for dice (optional)
  output wire [6:0]  seg,
  output wire [7:0]  an,

  // debug leds (map in XDC)
  output wire [7:0]  debug_leds,

  // NEW control/status outputs for top-level routing & display
  output wire        expect_sensor_snapshot, // high while waiting for sensor snapshot
  output wire        accept_move_via_confirm // high while in SELECT and ready to accept confirm
);

  // -------------------------------------------------
  // Local signals and simple stubs/instantiations
  // -------------------------------------------------
  // LFSR stub expected in simulation; if you have a real one, keep that
  wire [15:0] lfsr_q;
  lfsr16 LFSR (.clk(clk), .rst_n(rst_n), .q(lfsr_q));

  // -------------------------------------------------
  // Selection toggles
  // -------------------------------------------------
  // We'll track whether a player actively toggled selection this turn:
  reg selection_made;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      red_selected_piece <= 2'd0;
      blue_selected_piece <= 2'd0;
      selection_made <= 1'b0;
    end else begin
      // if in SELECT state, toggles will set selection_made; otherwise ignore
      // We'll gate when to allow toggles later in FSM.
      // For now we update selection on any select pulse, the FSM will decide validity.
      if (red_select_pulse) begin
        red_selected_piece <= (red_selected_piece == 2'd0) ? 2'd1 : 2'd0;
        selection_made <= 1'b1;
      end
      if (blue_select_pulse) begin
        blue_selected_piece <= (blue_selected_piece == 2'd0) ? 2'd1 : 2'd0;
        selection_made <= 1'b1;
      end
    end
  end

  // -------------------------------------------------
  // Dice generation (cheap mapping from lfsr to 1..6)
  // -------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dice_value <= 3'd1;
      dice_valid_pulse <= 1'b0;
    end else begin
      dice_valid_pulse <= 1'b0;
      if (roll_pulse) begin
        // cheap mapping: use low 3 bits, map 0->6
        if (lfsr_q[2:0] == 3'd0) dice_value <= 3'd6;
        else dice_value <= lfsr_q[2:0];
        dice_valid_pulse <= 1'b1;
      end
    end
  end

  // -------------------------------------------------
  // Piece positions initial state: both pieces start in base
  // red: 23,24 ; blue: 25,26
  // -------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      red_piece_pos0  <= 6'd23;
      red_piece_pos1  <= 6'd24;
      blue_piece_pos0 <= 6'd25;
      blue_piece_pos1 <= 6'd26;
    end
  end

  // -------------------------------------------------
  // Helper occupancy checks (logical, from registers)
  // -------------------------------------------------
  wire red_piece0_can_move;
  wire red_piece1_can_move;
  wire blue_piece0_can_move;
  wire blue_piece1_can_move;

  assign red_piece0_can_move  = !(red_piece_pos0 == 6'd22) && !((red_piece_pos0 == 6'd23 || red_piece_pos0 == 6'd24) && (dice_value != 3'd6));
  assign red_piece1_can_move  = !(red_piece_pos1 == 6'd22) && !((red_piece_pos1 == 6'd23 || red_piece_pos1 == 6'd24) && (dice_value != 3'd6));
  assign blue_piece0_can_move = !(blue_piece_pos0 == 6'd22) && !((blue_piece_pos0 == 6'd25 || blue_piece_pos0 == 6'd26) && (dice_value != 3'd6));
  assign blue_piece1_can_move = !(blue_piece_pos1 == 6'd22) && !((blue_piece_pos1 == 6'd25 || blue_piece_pos1 == 6'd26) && (dice_value != 3'd6));

  // -------------------------------------------------
  // next_pos combinational (instantiated)
  // -------------------------------------------------
  reg n_blue_at_8, n_red_at_8, n_blue_at_19, n_red_at_19;
  wire [5:0] next_pos_out;
  always @(*) begin
    n_blue_at_8  = (blue_piece_pos0 == 6'd8) || (blue_piece_pos1 == 6'd8);
    n_red_at_8   = (red_piece_pos0 == 6'd8)  || (red_piece_pos1 == 6'd8);
    n_blue_at_19 = (blue_piece_pos0 == 6'd19) || (blue_piece_pos1 == 6'd19);
    n_red_at_19  = (red_piece_pos0 == 6'd19)  || (red_piece_pos1 == 6'd19);
  end

  next_pos nexpos_inst (
    .pos(), // will pass moving_pos dynamically in FSM
    .blue_at_8(n_blue_at_8),
    .red_at_8(n_red_at_8),
    .blue_at_19(n_blue_at_19),
    .red_at_19(n_red_at_19),
    .next(next_pos_out)
  );

  // -------------------------------------------------
  // FSM states including SELECT and VERIFY_PHYSICAL
  // -------------------------------------------------
  localparam S_IDLE         = 3'd0;
  localparam S_SELECT       = 3'd1;
  localparam S_MOVE         = 3'd2;
  localparam S_VERIFY_PHYS  = 3'd3; // wait for physical sensor snapshot & compare
  localparam S_CAPTURE      = 3'd4;
  localparam S_ENDTURN      = 3'd5;
  localparam S_WIN          = 3'd6;

  reg [2:0] state;
  reg turn_red; // 1 => red's turn, 0 => blue's turn
  reg [2:0] steps_remaining;
  reg [5:0] moving_pos;
  reg [1:0] moving_index;

  // Expose simple status outputs (wires)
  assign accept_move_via_confirm = (state == S_SELECT);
  assign expect_sensor_snapshot = (state == S_VERIFY_PHYS);

  // Keep a small register to store expected final position for verification
  reg [5:0] expected_final_pos;

  // For using next_pos in FSM, we will call the combinational function by writing moving_pos into a temporary
  // But since next_pos_inst is wired to nothing, we'll instead compute simple next in-line for stepping.
  function [5:0] compute_next;
    input [5:0] pos_in;
    begin
      if (pos_in >= 6'd0 && pos_in <= 6'd22) begin
        if (pos_in == 6'd22) compute_next = 6'd22;
        else compute_next = pos_in + 6'd1;
      end else begin
        compute_next = pos_in;
      end
    end
  endfunction

  integer i;
  // Clear selection_made on new turn/entering SELECT
  reg selection_made_local;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      turn_red <= 1'b1; // red starts
      steps_remaining <= 3'd0;
      moving_pos <= 6'd0;
      moving_index <= 2'd0;
      selection_made_local <= 1'b0;
      expected_final_pos <= 6'd0;
    end else begin
      case (state)
        S_IDLE: begin
          // Wait for a roll to happen (dice_valid_pulse produced when roll_pulse arrives)
          if (dice_valid_pulse) begin
            // go to selection phase so player can choose piece (or confirm immediately)
            state <= S_SELECT;
            selection_made_local <= 1'b0; // clear per-turn selection flag
          end
        end

        S_SELECT: begin
          // Accept select pulses only for the current player
          if (turn_red && red_select_pulse) begin
            red_selected_piece <= (red_selected_piece == 2'd0) ? 2'd1 : 2'd0;
            selection_made_local <= 1'b1;
          end
          if (!turn_red && blue_select_pulse) begin
            blue_selected_piece <= (blue_selected_piece == 2'd0) ? 2'd1 : 2'd0;
            selection_made_local <= 1'b1;
          end

          // If move_confirm_pulse arrives, commit the logical move (or auto-select then commit)
          if (move_confirm_pulse) begin
            // pick piece to move
            if (turn_red) begin
              if (selection_made_local) moving_index <= red_selected_piece;
              else begin
                if (red_piece0_can_move && !red_piece1_can_move) moving_index <= 2'd0;
                else if (!red_piece0_can_move && red_piece1_can_move) moving_index <= 2'd1;
                else moving_index <= 2'd0; // default
              end
              moving_pos <= ( (selection_made_local ? ((red_selected_piece==2'd0) ? red_piece_pos0 : red_piece_pos1) : ((moving_index==2'd0) ? red_piece_pos0 : red_piece_pos1)) );
            end else begin
              if (selection_made_local) moving_index <= blue_selected_piece;
              else begin
                if (blue_piece0_can_move && !blue_piece1_can_move) moving_index <= 2'd0;
                else if (!blue_piece0_can_move && blue_piece1_can_move) moving_index <= 2'd1;
                else moving_index <= 2'd0;
              end
              moving_pos <= ( (selection_made_local ? ((blue_selected_piece==2'd0) ? blue_piece_pos0 : blue_piece_pos1) : ((moving_index==2'd0) ? blue_piece_pos0 : blue_piece_pos1)) );
            end

            steps_remaining <= dice_value;
            state <= S_MOVE;
          end
        end // S_SELECT

        S_MOVE: begin
          if (steps_remaining > 0) begin
            // perform one step
            // special-case base exit: if starting in base and it's the first step and dice_value==6
            if (steps_remaining == dice_value) begin
              // first step
              if (turn_red) begin
                if ((moving_pos == 6'd23 || moving_pos == 6'd24) && dice_value == 3'd6) begin
                  moving_pos <= 6'd0; // red exit
                end else begin
                  moving_pos <= compute_next(moving_pos);
                end
              end else begin
                if ((moving_pos == 6'd25 || moving_pos == 6'd26) && dice_value == 3'd6) begin
                  moving_pos <= 6'd11; // blue exit
                end else begin
                  moving_pos <= compute_next(moving_pos);
                end
              end
            end else begin
              moving_pos <= compute_next(moving_pos);
            end
            steps_remaining <= steps_remaining - 1;
          end else begin
            // finished moving -> record into expected_final_pos and wait for physical verification
            expected_final_pos <= moving_pos;
            state <= S_VERIFY_PHYS;
          end
        end // S_MOVE

        S_VERIFY_PHYS: begin
          // Wait for new_board_snapshot to be pulsed by aggregator (top routes confirm)
          // new_board_snapshot is a 1-clock pulse; when it arrives, verify board_occ[expected_final_pos]==1
          if (new_board_snapshot) begin
            // simple verification: check the moving square sensor is set
            if (board_occ[expected_final_pos]) begin
              // accept move: update piece register
              if (turn_red) begin
                if (moving_index == 2'd0) red_piece_pos0 <= expected_final_pos;
                else red_piece_pos1 <= expected_final_pos;
              end else begin
                if (moving_index == 2'd0) blue_piece_pos0 <= expected_final_pos;
                else blue_piece_pos1 <= expected_final_pos;
              end
              state <= S_CAPTURE;
            end else begin
              // mismatch: for now, reject and go back to SELECT so user can reposition and confirm again
              // Could alternatively auto-correct state; here we ask user to re-place piece
              state <= S_SELECT;
            end
          end
        end // S_VERIFY_PHYS

        S_CAPTURE: begin
          // perform capture if any opponent piece is on the same outer square (0..19)
          if (turn_red) begin
            if (expected_final_pos <= 6'd19) begin
              if (blue_piece_pos0 == expected_final_pos) blue_piece_pos0 <= 6'd25;
              if (blue_piece_pos1 == expected_final_pos) blue_piece_pos1 <= 6'd25;
            end
          end else begin
            if (expected_final_pos <= 6'd19) begin
              if (red_piece_pos0 == expected_final_pos) red_piece_pos0 <= 6'd23;
              if (red_piece_pos1 == expected_final_pos) red_piece_pos1 <= 6'd23;
            end
          end
          state <= S_ENDTURN;
        end

        S_ENDTURN: begin
          // win detection (simple)
          if (red_piece_pos0 == 6'd22 && red_piece_pos1 == 6'd22) begin
            state <= S_WIN;
          end else if (blue_piece_pos0 == 6'd22 && blue_piece_pos1 == 6'd22) begin
            state <= S_WIN;
          end else begin
            // switch turn unless dice==6
            if (dice_value != 3'd6) turn_red <= ~turn_red;
            // clear selection flag for next player
            selection_made_local <= 1'b0;
            state <= S_IDLE;
          end
        end

        S_WIN: begin
          state <= S_WIN; // hold
        end

        default: state <= S_IDLE;
      endcase
    end
  end

  // -------------------------------------------------
  // debug leds mapping
  // -------------------------------------------------
  // Map a few useful signals
  assign debug_leds[0] = roll_pulse;
  assign debug_leds[1] = dice_valid_pulse;
  assign debug_leds[2] = red_select_pulse;
  assign debug_leds[3] = blue_select_pulse;
  assign debug_leds[7:4] = 4'b0;


endmodule
