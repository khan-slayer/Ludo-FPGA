`timescale 1ns/1ps
module simple_sensor_test_top (
    input  wire clk,
    input  wire btn_confirm,  // raw confirm pushbutton (separate from roll)
    input  wire sensor_raw,   // raw IR sensor input (module OUT)
    output wire [2:0] led     // LED[0]=sync, LED[1]=stable, LED[2]=latched
);

    // debounce confirm button (use same debounce module you've used)
    wire btn_confirm_db;
    btn_sync_debounce #(.CLK_FREQ_HZ(100_000_000), .DEB_MS(10)) confirm_db (
        .clk(clk),
        .btn(btn_confirm),
        .btn_out(btn_confirm_db)
    );

    // instantiate improved_sensor_latch
    wire sensor_latched;
    // instantiate with INVERT_SENSOR=1 because your IR outputs 0 on detection
    sensor_latch #(
        .INVERT_SENSOR(1),
        .DEB_TICKS(1_000_000), // ~10ms
        .LATCH_ON_RISING(1)
    ) sl (
        .clk(clk),
        .reset(1'b0),
        .sensor_in(sensor_raw),
        .confirm_btn(btn_confirm_db),
        .sensor_out(sensor_latched)
    );

    // also produce the internal debounced/stable and synced signals for LED feedback:
    // To get them we can either expose via additional outputs from the module or
    // reimplement a small local sync+debounce here to show LED0/LED1.
    // I'll implement a small local sync+debounce for test visibility.

    // local sync + tiny debounce for immediate visibility (not the same as latch internals)
    reg sync0, sync1;
    reg [19:0] local_cnt;
    reg stable_local;

    always @(posedge clk) begin
        sync0 <= sensor_raw;
        sync1 <= sync0;
        if (sync1 == stable_local) local_cnt <= 0;
        else begin
            if (local_cnt < 20'd1_000_000) local_cnt <= local_cnt + 1;
            else stable_local <= sync1;
        end
    end

    assign led[0] = sync1;           // LED0 shows raw synchronized bit (1 = no object if active-low)
    assign led[1] = stable_local;    // LED1 shows local debounced bit
    assign led[2] = sensor_latched;  // LED2 shows latched value after pressing confirm

endmodule
