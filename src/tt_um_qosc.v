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
  wire extclk; 
  wire takt;
  wire [7:0] re_coeff;
  wire [7:0] im_coeff;
  wire [7:0] power;
  wire [7:0] accu_re_init;
  wire [7:0] accu_im_init;
  wire [7:0] accu_re;
  wire [7:0] accu_im;

  assign load = ui_in[0] ~& rst_n;
  assign extclk = ui_in[1];
  assign re_coeff = 8'h7d;    // Example real coefficient
  assign im_coeff = 8'h1b;    // Example imaginary coefficient
  assign power = 8'h40;       // Target power level
  assign accu_re_init = 8'h20;  // Initial accumulator real part
  assign accu_im_init = 8'h0;   // Initial accumulator imaginary part

refclk_sync synchronizer(
    .i_reset_n (rst_n),
    .i_clk (clk),
    .i_refclk (extclk),
    .o_refclk_sync (takt)
);
   
quadrature_oscillator_sync qosc(
    .clk (takt),
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
  assign uo_out  = accu_re;
  assign uio_out = accu_im;
  assign uio_oe  = 8'hff;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:2], uio_in, 1'b0};

endmodule
