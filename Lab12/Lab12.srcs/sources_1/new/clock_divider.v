// clk_divider.v
// Parameterizable pulse generator: produces single-cycle enable_pulse at TICK_HZ
module clk_divider #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ     = 4
)(
    input  wire clk,
    input  wire rst,            // synchronous reset (active-high)
    output reg  enable_pulse
);

    localparam integer DIV_MAX = CLK_FREQ_HZ / TICK_HZ;
    localparam integer WIDTH = $clog2(DIV_MAX);

    reg [WIDTH-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= {WIDTH{1'b0}};
            enable_pulse <= 1'b0;
        end else begin
            if (cnt == DIV_MAX-1) begin
                cnt <= 0;
                enable_pulse <= 1'b1;
            end else begin
                cnt <= cnt + 1;
                enable_pulse <= 1'b0;
            end
        end
    end

endmodule
