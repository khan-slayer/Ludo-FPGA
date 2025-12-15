module pixel_gen(
    input clk_d, 
    input [9:0] pixel_x, 
    input [9:0] pixel_y, 
    input video_on, 
    output reg [3:0] red = 0, 
    output reg [3:0] green = 0, 
    output reg [3:0] blue = 0
);
parameter size_b = 480;
parameter gridsize = 8;
parameter sqauresize = size_b/ gridsize;
localparam LEFT = (640 - size_b) / 2;
localparam RIGHT = (640 +size_b) / 2;
localparam TOP = (480 - size_b) / 2;
localparam BOTTOM = (480 + size_b) / 2;

always @(posedge clk_d) begin
    if (video_on) begin
        if ((pixel_x == LEFT) || (pixel_x == RIGHT - 1) ||
            (pixel_y == TOP) || (pixel_y == BOTTOM - 1)) begin
            red <= 4'hF;
            green <= 4'hF;
            blue <= 4'hF;
        end
    else if ((pixel_x >= LEFT) && (pixel_x < RIGHT) &&
        (pixel_y >= TOP) && (pixel_y < BOTTOM)) begin
        if ((((pixel_x - LEFT) / sqauresize) % 2) ^
            (((pixel_y - TOP) / sqauresize) % 2)) begin
            red <= 4'hF;
            green <= 4'hF;
            blue <= 4'hF;
        end
        else
            begin
                green <= 4'h0;
                red <= 4'h0;
                blue <= 4'h0;
            end
        end
        else
            begin
                green <= 4'h0;
                red <= 4'h0;
                blue <= 4'h0;
            end
    end
    else
        begin
            red <= 4'h0;
            green <= 4'h0;
            blue <= 4'h0;
        end
    end
endmodule