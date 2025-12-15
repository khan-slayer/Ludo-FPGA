// thunderbird_fsm_eqs.v
//   clk   - system clock
//   T     - synchronous active-high reset (user's notation for reset)
//   L,R   - left and right start signals (buttons/switches)
//   enable - step pulse; FSM updates state only when enable==1
// Outputs: RA,RB,RC, LA,LB,LC (LED signals)

module thunderbird_fsm_eqs(
    input  wire clk,
    input  wire T,        // synchronous reset (active-high)
    input  wire L,
    input  wire R,
    input  wire enable,

    output reg RA,
    output reg RB,
    output reg RC,
    output reg LA,
    output reg LB,
    output reg LC
);

    // state bits A B C (current)
    reg A, B, C;

    // next-state signals (computed from given equations)
    wire AN, BN, CN;


    // AN = AB'T' + B'C'T' R L'
    assign AN = (A & (~B) & (~T)) 
              | ((~B) & (~C) & (~T) & R & (~L));

    // BN = B' C T' + A' B C' T'
    assign BN = ((~B) & C & (~T))
              | ((~A) & B & (~C) & (~T));

    // CN = A' C T' L + A B C' T' + A B' C' T'
    assign CN = ((~A) & (~C) & (~T) & L)
              | ((~A) & B & (~C) & (~T))
              | (A & (~B) & (~C) & (~T));

    // State register (synchronous reset). Advance only when enable==1.
    // On T==1 => go to S_IDLE = 3'b000 (A=B=C=0)    
    always @(posedge clk) begin
        if (T) begin
            A <= 1'b0;
            B <= 1'b0;
            C <= 1'b0;
        end else begin
            if (enable) begin
                A <= AN;
                B <= BN;
                C <= CN;
            end
        end
    end

    // --------
    // Output equations (Moore outputs depend only on current A,B,C)
    // Using the exact output equations given by the user:
    //
    // RA = AB' + AC'
    // RB = AB'C +  ABC'
    // RC = ABC'
    //
    // LA = A'C + A'B
    // LB = A'B
    // LC = A'BC
    // --------
    always @(*) begin
        // default zeros
        {RA, RB, RC, LA, LB, LC} = 6'b000000;

        // Right outputs
        RA = (A & (~B)) | (A & (~C));
        RB = (A & (~B) & C) | (A & B & (~C));
        RC = (A & B & (~C));

        // Left outputs
        LA = ((~A) & C) | ((~A) & B);
        LB = ((~A) & B);
        LC = ((~A) & B & C);
    end

endmodule
