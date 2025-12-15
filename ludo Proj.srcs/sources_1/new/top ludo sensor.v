// TopLudoWithSensors.v
`timescale 1ns / 1ps
module TopLudoWithSensors (
  input  wire        clk,
  input  wire        rst_n,            // active-low reset at board level

  // push buttons raw (async)
  input  wire        roll_btn_raw,
  input  wire        red_sel_btn_raw,
  input  wire        blue_sel_btn_raw,
  input  wire        confirm_btn_raw,  // button used to latch sensors

  // 27 sensor pins (rename/mapping per your board)
  input  wire s0,  input wire s1,  input wire s2,  input wire s3,  input wire s4,
  input  wire s5,  input wire s6,  input wire s7,  input wire s8,  input wire s9,
  input  wire s10, input wire s11, input wire s12, input wire s13, input wire s14,
  input  wire s15, input wire s16, input wire s17, input wire s18, input wire s19,
  input  wire s20, input wire s21, input wire s22, input wire s23, input wire s24,
  input  wire s25, input wire s26,

  // outputs to drive (example)
  output wire [6:0] seg,
  output wire [3:0] an,
  output wire [7:0] debug_leds
);

     // --- dice signals (LFSR-based) ---
  wire [2:0] dice_live;
  reg  [2:0] dice_latched = 3'd1;
  reg  roll_state_prev = 1'b0;


  // Convert active-low top reset to internal active-high reset
  wire reset = ~rst_n;

  // Pack sensors
  wire [26:0] sensors_bus;
  top_ludo_sensor SENSOR_PACK (
    .s0(s0),  .s1(s1),  .s2(s2),  .s3(s3),  .s4(s4),
    .s5(s5),  .s6(s6),  .s7(s7),  .s8(s8),  .s9(s9),
    .s10(s10),.s11(s11),.s12(s12),.s13(s13),.s14(s14),
    .s15(s15),.s16(s16),.s17(s17),.s18(s18),.s19(s19),
    .s20(s20),.s21(s21),.s22(s22),.s23(s23),.s24(s24),
    .s25(s25),.s26(s26),
    .sensors_bus(sensors_bus)
  );

  // Button sync + debounce (one instance per button)
  wire roll_state,  roll_pulse;
  wire red_state,   red_pulse;
  wire blue_state,  blue_pulse;
  wire confirm_state, confirm_pulse;

  btn_sync_debounce #(.COUNTER_WIDTH(16)) BTN_ROLL (
    .clk(clk), .reset(reset), .btn_async(roll_btn_raw),
    .btn_state(roll_state), .btn_pulse(roll_pulse)
  );
  btn_sync_debounce #(.COUNTER_WIDTH(16)) BTN_RED (
    .clk(clk), .reset(reset), .btn_async(red_sel_btn_raw),
    .btn_state(red_state), .btn_pulse(red_pulse)
  );
  btn_sync_debounce #(.COUNTER_WIDTH(16)) BTN_BLUE (
    .clk(clk), .reset(reset), .btn_async(blue_sel_btn_raw),
    .btn_state(blue_state), .btn_pulse(blue_pulse)
  );
  btn_sync_debounce #(.COUNTER_WIDTH(16)) BTN_CONFIRM (
    .clk(clk), .reset(reset), .btn_async(confirm_btn_raw),
    .btn_state(confirm_state), .btn_pulse(confirm_pulse)
  );
  
    // LFSR-based dice generator (hold to spin, release to latch)
  dice_random #(.PRESCALE(2000000)) DICE_INST (
    .clk(clk),
    .enable(roll_state),   // use debounced level (hold to spin)
    .out(dice_live)
  );

  // Latch dice on falling edge of debounced roll_state (release)
  always @(posedge clk) begin
    roll_state_prev <= roll_state;
    if (roll_state_prev && !roll_state) begin
      dice_latched <= dice_live;
    end
  end

   
     // 7-seg display shows dice_latched
  sevenseg_decoder segdec (
    .value(dice_latched),
    .seg(seg)
  );
  // only enable digit 0 (Basys3 anodes are active low)
  assign an = 4'b1110;

   
  // Board aggregator: latch sensors on confirm_pulse (safest: pass debounced level; aggregator will resync)
  wire [26:0] board_occ;
  wire        latched_valid;
  BoardOccAggregator #(.NUM_SENSORS(27), .INVERT_SENSOR(1)) AGG (
    .clk(clk), .reset(reset),
    .sensors_in(sensors_bus),
    .confirm_btn(confirm_state), // debounced level passed in; aggregator still resyncs internally
    .board_occ(board_occ),
    .latched_valid(latched_valid)
  );

    LudoFull GAME (
    .clk(clk),
    .rst_n(rst_n),
    .roll_pulse(roll_pulse),
    .red_select_pulse(red_pulse),
    .blue_select_pulse(blue_pulse),
    .board_occ(board_occ),
    .new_board_snapshot(latched_valid),
    .dice_in(dice_latched),      // <--- pass the latched dice here
    .seg(seg),
    .an(an),
    .debug_leds(debug_leds)
  );

endmodule
