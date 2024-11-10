module registers(
  input reset_n,
  input clk,
  input load,
  input [2:0] address,
  input [7:0] data_in,
  output reg RnotW,
  output reg [7:0] init_re,
  output reg [7:0] init_im,
  output reg [7:0] re_coeff,
  output reg [7:0] im_coeff,
  output reg [7:0] power
);

  always @(posedge clk) begin
    if (! reset_n) begin
      re_coeff <= 8'h7d;    // Example real coefficient
      im_coeff <= 8'h1b;    // Example imaginary coefficient
      power <= 8'h10;       // Target power level
      init_re <= 8'h20;     // Initial accumulator real part
      init_im <= 8'h0;      // Initial accumulator imaginary part
      RnotW <= 0;
    end
    else begin
      RnotW <= (3'b0 == address);
      if (load) begin
        case (address)
          3'o2: init_re <= data_in;
          3'o3: init_im <= data_in;
          3'o4: re_coeff <= data_in;
          3'o5: im_coeff <= data_in;
          3'o6: power <= data_in;
        endcase
      end
    end
  end
endmodule
