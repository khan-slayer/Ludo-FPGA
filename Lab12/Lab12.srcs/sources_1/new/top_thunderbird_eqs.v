// top_thunderbird_eqs.v
// Ports: CLK100MHz (input), BTN_RST (active-low button typical on boards),
//        SW_LEFT, SW_RIGHT (switches) and LED[5:0]

module top_thunderbird_eqs(
    input  wire CLK100MHZ,
    input  wire BTN_RST_N,// board button active-low (example)
    input  wire SW_LEFT,
    input  wire SW_RIGHT,
    output wire [5:0] LED  // {RA,RB,RC,LA,LB,LC}
);

    // creating a synchronous reset T (active-high) from active-low button
    reg [1:0] rst_sync;
    always @(posedge CLK100MHZ) begin
        rst_sync <= {rst_sync[0], BTN_RST_N};
    end
    wire T = ~rst_sync[1]; // T==1 when button pressed (active-high reset)

    // instantiate clock divider to create enable pulses
    wire enable_pulse;
    clk_divider #(.CLK_FREQ_HZ(100_000_000), .TICK_HZ(4)) clkdiv (
        .clk(CLK100MHZ),
        .rst(T),
        .enable_pulse(enable_pulse)
    );

    // instantiate FSM 
    wire RA, RB, RC, LA, LB, LC;
    thunderbird_fsm_eqs fsm (
        .clk(CLK100MHZ),
        .T(T),
        .L(SW_LEFT),
        .R(SW_RIGHT),
        .enable(enable_pulse),
        .RA(RA),
        .RB(RB),
        .RC(RC),
        .LA(LA),
        .LB(LB),
        .LC(LC)
    );

    // map LEDs (order: RA RB RC LA LB LC)
    assign LED = {RA, RB, RC, LA, LB, LC};

endmodule
