`timescale 1ns / 1ps

module tt_um_qosc(
    input clk,
    input load,                        // Preload signal
    input signed [15:0] re_coeff,
    input signed [15:0] im_coeff,
    input signed [15:0] power,
    input signed [15:0] accu_re_init,  // Initial real accumulator value
    input signed [15:0] accu_im_init,  // Initial imaginary accumulator value
    output reg signed [15:0] accu_re,  // Real part of accumulator
    output reg signed [15:0] accu_im   // Imaginary part of accumulator
);

    // Temporary variables for intermediate calculations
    reg signed [31:0] temp_re, temp_im;
    reg signed [15:0] tmph_re, tmph_im, t0;
    reg signed [31:0] ac3;

    // Always block for synchronous operation
    always @(posedge clk) begin
        if (load) begin
            // Load initial values into accumulators
            accu_re <= accu_re_init;
            accu_im <= accu_im_init;
        end else begin
            // Compute next values for real and imaginary parts
            temp_re = (accu_re * re_coeff) - (accu_im * im_coeff);
            temp_im = (accu_re * im_coeff) + (accu_im * re_coeff);

            // Scale down to fixed-point representation
            tmph_re = temp_re >>> 15;
            tmph_im = temp_im >>> 15;

            // Compute the power adjustment
            ac3 = (power <<< 16) - (tmph_re * tmph_re) - (tmph_im * tmph_im);
            t0 = ac3 >>> 16;

            // Apply power correction
            temp_re = temp_re + (tmph_re * t0);
            temp_im = temp_im + (tmph_im * t0);

            // Update the output accumulators
            accu_re <= temp_re >>> 15;
            accu_im <= temp_im >>> 15;
        end
    end

endmodule
