/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_qosc (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  wire load;
  wire re_coeff [15:0];
  wire im_coeff [15:0];
  wire power [15:0];
  wire accu_re_init [15:0];
  wire accu_im_init [15:0];
  wire accu_re [15:0];
  wire accu_im [15:0];

  assign load = ui_in[0] ~& rst_n;

quadrature_oscillator_sync qosc(
    .clk (clk),
    .load (load),                      // Preload signal
    .re_coeff (re_coeff),
    .im_coeff (im_coeff),
    .power (power),
    .accu_re_init (accu_re_init),      // Initial real accumulator value
    .accu_im_init (accu_im_init),      // Initial imaginary accumulator value
    .accu_re (accu_re),                // Real part of accumulator
    .accu_im (accu_im)                 // Imaginary part of accumulator
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out[7:4]  = accu_re[15:12];
  assign uo_out[3:0]  = accu_im[15:12];
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:1], uio_in, 1'b0};

endmodule
