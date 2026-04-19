/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_boothmul4 (
// Internal registers
reg signed [7:0] A;
reg signed [7:0] Q;
reg signed [7:0] M;
reg Q_1;
reg [3:0] count;
reg signed [15:0] product;
reg done;

// Reset is active LOW (rst_n)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        A <= 0;
        Q <= 0;
        M <= 0;
        Q_1 <= 0;
        count <= 0;
        product <= 0;
        done <= 0;
    end 
    else begin
        // Load inputs from ui_in (example mapping)
        // ui_in[3:0] = M (multiplicand lower bits)
        // ui_in[7:4] = Q (multiplier lower bits)

        if (ena) begin
            if (count == 0) begin
                A <= 0;
                M <= { {4{ui_in[3]}}, ui_in[3:0] }; // sign extend 4-bit
                Q <= { {4{ui_in[7]}}, ui_in[7:4] };
                Q_1 <= 0;
                count <= 4;   // 4-bit Booth
                done <= 0;
            end 
            else begin
                // Booth logic
                case ({Q[0], Q_1})
                    2'b01: A <= A + M;
                    2'b10: A <= A - M;
                    default: A <= A;
                endcase

                // Shift right
                {A, Q, Q_1} <= {A[7], A, Q};

                count <= count - 1;

                if (count == 1) begin
                    product <= {A, Q};
                    done <= 1;
                end
            end
        end
    end
end

// Output mapping
assign uo_out = product[7:0];   // lower 8 bits output
assign uio_out = product[15:8]; // upper 8 bits
assign uio_oe = 8'b11111111;    // enable outputs
