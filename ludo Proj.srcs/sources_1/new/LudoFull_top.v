// LudoFull.v
// Complete 2-player (Red/Blue) 2-piece Ludo game logic, hardware-friendly.
// - Replace your old 'ludo full.v' with this file (or instantiate it from your top).
`timescale 1ns/1ps

module LudoFull_ignore (
  input  wire        clk,
  input  wire        rst_n,

  // raw push buttons (map to Basys3 PBs in XDC)
  input  wire        roll_btn_raw,     // roll dice (rising edge triggers)
  input  wire        red_sel_btn_raw,  // toggle red selected piece
  input  wire        blue_sel_btn_raw, // toggle blue selected piece

  // raw IR sensors bus (one bit per board position 0..22). Map in XDC.
  input  wire [22:0] sensors_raw,

  // outputs
  output reg  [2:0]  dice_value,        // 1..6
  output reg         dice_valid_pulse,  // single cycle pulse when dice_value updated
  output reg  [1:0]  red_selected_piece,
  output reg  [1:0]  blue_selected_piece,

  // piece positions for UI or display (0..26; 23/24 red base, 25/26 blue base)
  output reg  [5:0]  red_piece_pos0,
  output reg  [5:0]  red_piece_pos1,
  output reg  [5:0]  blue_piece_pos0,
  output reg  [5:0]  blue_piece_pos1,

  // basic debug LEDs (map in XDC)
  output wire [7:0]  debug_leds,

  // optional 7-seg outputs for dice (connect to dice_display)
  output wire [6:0]  seg,
  output wire [7:0]  an
);

  // === helpers ===
  wire roll_db, red_sel_db, blue_sel_db;
  debounce #(.CLK_HZ(100_000_000), .DEBOUNCE_MS(20)) DB_ROLL(.clk(clk), .rst_n(rst_n), .in(roll_btn_raw), .out(roll_db));
  debounce #(.CLK_HZ(100_000_000), .DEBOUNCE_MS(20)) DB_RSEL(.clk(clk), .rst_n(rst_n), .in(red_sel_btn_raw), .out(red_sel_db));
  debounce #(.CLK_HZ(100_000_000), .DEBOUNCE_MS(20)) DB_BSEL(.clk(clk), .rst_n(rst_n), .in(blue_sel_btn_raw), .out(blue_sel_db));

  // edge detection
  reg roll_db_d, red_sel_db_d, blue_sel_db_d;
  wire roll_rise = roll_db & ~roll_db_d;
  wire red_sel_rise = red_sel_db & ~red_sel_db_d;
  wire blue_sel_rise = blue_sel_db & ~blue_sel_db_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      roll_db_d <= 1'b0;
      red_sel_db_d <= 1'b0;
      blue_sel_db_d <= 1'b0;
    end else begin
      roll_db_d <= roll_db;
      red_sel_db_d <= red_sel_db;
      blue_sel_db_d <= blue_sel_db;
    end
  end

  // === piece selection toggles ===
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      red_selected_piece <= 2'd0;
      blue_selected_piece <= 2'd0;
    end else begin
      if (red_sel_rise) red_selected_piece <= (red_selected_piece == 2'd0) ? 2'd1 : 2'd0;
      if (blue_sel_rise) blue_selected_piece <= (blue_selected_piece == 2'd0) ? 2'd1 : 2'd0;
    end
  end

  // === sensor synchronization & latch snapshot ===
  wire [22:0] sensors_sync;
  sync_bits #(.WIDTH(23)) SYNC_SENS(.clk(clk), .rst_n(rst_n), .async_in(sensors_raw), .sync_out(sensors_sync));

  reg [22:0] sensors_latched;
  // snapshot on roll rise (this can be changed to continuous if you need high fidelity)
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) sensors_latched <= 23'd0;
    else if (roll_rise) sensors_latched <= sensors_sync;
  end

  // occupancy flags for special branching (we are using simple presence here; change if you have color sensors)
  wire blue_at_8  = sensors_latched[8];
  wire red_at_8   = sensors_latched[8];
  wire blue_at_19 = sensors_latched[19];
  wire red_at_19  = sensors_latched[19];

  // === RNG (LFSR) for dice ===
  wire [6:0] lfsr_q;
  lfsr7 LFSR(.clk(clk), .rst_n(rst_n), .q(lfsr_q));

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dice_value <= 3'd1;
      dice_valid_pulse <= 1'b0;
    end else begin
      if (roll_rise) begin
        dice_value <= (lfsr_q % 6) + 3'd1;
        dice_valid_pulse <= 1'b1;
      end else dice_valid_pulse <= 1'b0;
    end
  end

  // === initial piece positions (bases) ===
  // red base: 23,24 ; blue base: 25,26
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      red_piece_pos0  <= 6'd23;
      red_piece_pos1  <= 6'd24;
      blue_piece_pos0 <= 6'd25;
      blue_piece_pos1 <= 6'd26;
    end
  end

  // helper function to check if a position is outer ring (0..19) or final/home or base
  function is_outer;
    input [5:0] p;
    begin
      if (p <= 6'd19) is_outer = 1'b1;
      else is_outer = 1'b0;
    end
  endfunction

  // helper to check whether two positions are same square (ignoring base/final semantics as needed)
  function pos_equal;
    input [5:0] a; input [5:0] b;
    begin pos_equal = (a == b); end
  endfunction

  // === turn management & movement FSM ===
  // simple turn FSM with states:
  // IDLE_WAIT_ROLL -> ROLL_DONE -> MOVE_STEP_LOOP -> CHECK_CAPTURE -> NEXT_TURN
  localparam T_IDLE      = 3'd0,
             T_MOVE      = 3'd1,
             T_STEP      = 3'd2,
             T_CAPTURE   = 3'd3,
             T_ENDTURN   = 3'd4,
             T_WIN       = 3'd5;

  reg [2:0] state;
  reg turn_red; // 1 = red's turn; 0 = blue's turn
  reg [2:0] steps_remaining;
  reg [5:0] moving_piece_pos;  // temporary position for step calculation
  reg [1:0] moving_piece_index; // which piece of current player (0 or 1)
  reg move_active;

  // For combinational next_pos
  reg n_blue_at_8, n_red_at_8, n_blue_at_19, n_red_at_19;
  wire [5:0] nextpos_wire;
  next_pos NEXTPOS (
    .pos(moving_piece_pos),
    .blue_at_8(n_blue_at_8),
    .red_at_8(n_red_at_8),
    .blue_at_19(n_blue_at_19),
    .red_at_19(n_red_at_19),
    .next(nextpos_wire)
  );

  // We'll set the occupancy flags derived from current piece positions (logical occupancy)
  always @(*) begin
    // default zero
    n_blue_at_8  = 1'b0;
    n_red_at_8   = 1'b0;
    n_blue_at_19 = 1'b0;
    n_red_at_19  = 1'b0;

    // check if any red pieces occupy pos 8 or 19
    if (red_piece_pos0 == 6'd8 || red_piece_pos1 == 6'd8) n_red_at_8 = 1'b1;
    if (red_piece_pos0 == 6'd19 || red_piece_pos1 == 6'd19) n_red_at_19 = 1'b1;
    if (blue_piece_pos0 == 6'd8 || blue_piece_pos1 == 6'd8) n_blue_at_8 = 1'b1;
    if (blue_piece_pos0 == 6'd19 || blue_piece_pos1 == 6'd19) n_blue_at_19 = 1'b1;
  end

  // helper to access reference to selected piece pos for writing
  // we will update actual piece regs in MOVE_STEP end or capture FSM
  // movement action: on dice_valid_pulse, start movement for selected piece of current player
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= T_IDLE;
      turn_red <= 1'b1; // start with Red by default
      steps_remaining <= 3'd0;
      moving_piece_pos <= 6'd0;
      moving_piece_index <= 2'd0;
      move_active <= 1'b0;
    end else begin
      case (state)
        T_IDLE: begin
          dice_valid_pulse <= dice_valid_pulse; // keep original behavior
          if (dice_valid_pulse) begin
            // determine which player moves (turn_red)
            // pick the selected piece index for that player
            if (turn_red) moving_piece_index <= red_selected_piece;
            else moving_piece_index <= blue_selected_piece;

            // capture steps
            steps_remaining <= dice_value;
            // pick current pos into moving_piece_pos
            if (turn_red) begin
              if (red_selected_piece == 2'd0) moving_piece_pos <= red_piece_pos0;
              else moving_piece_pos <= red_piece_pos1;
            end else begin
              if (blue_selected_piece == 2'd0) moving_piece_pos <= blue_piece_pos0;
              else moving_piece_pos <= blue_piece_pos1;
            end

            move_active <= 1'b1;
            state <= T_STEP;
          end
        end

        T_STEP: begin
          if (move_active && steps_remaining > 0) begin
            // handle base exit on step 1 if piece in base and roll==6
            // Base positions: red 23,24 -> exit to 0 on 6; blue 25,26 -> exit to 11 on 6
            if (steps_remaining == dice_value) begin
              // first step - if piece currently in base and dice==6, place it on start
              if (turn_red) begin
                if ((moving_piece_pos == 6'd23 || moving_piece_pos == 6'd24) && dice_value == 3'd6) begin
                  moving_piece_pos <= 6'd0;
                  steps_remaining <= steps_remaining - 1;
                end else begin
                  // normal step using next_pos
                  moving_piece_pos <= nextpos_wire;
                  steps_remaining <= steps_remaining - 1;
                end
              end else begin
                if ((moving_piece_pos == 6'd25 || moving_piece_pos == 6'd26) && dice_value == 3'd6) begin
                  moving_piece_pos <= 6'd11;
                  steps_remaining <= steps_remaining - 1;
                end else begin
                  moving_piece_pos <= nextpos_wire;
                  steps_remaining <= steps_remaining - 1;
                end
              end
            end else begin
              // subsequent steps: normal next_pos
              moving_piece_pos <= nextpos_wire;
              steps_remaining <= steps_remaining - 1;
            end
          end else begin
            // movement finished (steps_remaining == 0)
            move_active <= 1'b0;
            state <= T_CAPTURE;
          end
        end

        T_CAPTURE: begin
          // apply final moving_piece_pos to the corresponding piece register, and perform capture (if landing on opposing piece on outer squares)
          if (turn_red) begin
            if (moving_piece_index == 2'd0) red_piece_pos0 <= moving_piece_pos;
            else red_piece_pos1 <= moving_piece_pos;

            // capture: if red landed on blue outer square (0..19) where a blue piece resides, send that blue piece to its base
            if (is_outer(moving_piece_pos)) begin
              if (blue_piece_pos0 == moving_piece_pos) begin
                // send blue piece0 to its base (25 if free else 26)
                if (blue_piece_pos1 != 6'd25) blue_piece_pos0 <= 6'd25;
                else blue_piece_pos0 <= 6'd26;
              end
              if (blue_piece_pos1 == moving_piece_pos) begin
                if (blue_piece_pos0 != 6'd25) blue_piece_pos1 <= 6'd25;
                else blue_piece_pos1 <= 6'd26;
              end
            end
          end else begin
            // blue moved
            if (moving_piece_index == 2'd0) blue_piece_pos0 <= moving_piece_pos;
            else blue_piece_pos1 <= moving_piece_pos;

            if (is_outer(moving_piece_pos)) begin
              if (red_piece_pos0 == moving_piece_pos) begin
                if (red_piece_pos1 != 6'd23) red_piece_pos0 <= 6'd23;
                else red_piece_pos0 <= 6'd24;
              end
              if (red_piece_pos1 == moving_piece_pos) begin
                if (red_piece_pos0 != 6'd23) red_piece_pos1 <= 6'd23;
                else red_piece_pos1 <= 6'd24;
              end
            end
          end

          state <= T_ENDTURN;
        end

        T_ENDTURN: begin
          // check for win condition: both pieces at home (22)
          if (red_piece_pos0 == 6'd22 && red_piece_pos1 == 6'd22) begin
            // red wins - hold in win state
            state <= T_WIN;
          end else if (blue_piece_pos0 == 6'd22 && blue_piece_pos1 == 6'd22) begin
            state <= T_WIN;
          end else begin
            // decide next turn: if dice_value == 6, same player plays again; else switch
            if (dice_value != 3'd6) turn_red <= ~turn_red;
            // else keep same player
            state <= T_IDLE;
          end
        end

        T_WIN: begin
          // game over; keep outputs stable
          // optional: you could assert a 'winner' signal here
          state <= T_WIN;
        end

        default: state <= T_IDLE;
      endcase
    end
  end

  // === debug LEDs and dice display instantiation ===
  // debug LED mapping: [0] roll_db, [1] roll_rise, [2] red_sel_db, [3] blue_sel_db, [7:4] lfsr_q[3:0]
  assign debug_leds[0] = roll_db;
  assign debug_leds[1] = roll_rise;
  assign debug_leds[2] = red_sel_db;
  assign debug_leds[3] = blue_sel_db;
  assign debug_leds[7:4] = lfsr_q[3:0];

  // instantiate dice display: show dice_value on 7-seg, flash slightly when dice_valid_pulse asserted
  dice_display DICE_DISP(
    .clk(clk), .rst_n(rst_n), .value(dice_value),
    .strobe(dice_valid_pulse), .seg(seg), .an(an)
  );

endmodule
