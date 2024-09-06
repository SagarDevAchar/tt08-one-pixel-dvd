/*
 * tt_um_factory_test.v
 *
 * Test user module
 *
 * Author: Sylvain Munaut <tnt@246tNt.com>
 */

`default_nettype none

module tt_um_micro_one_pixel_dvd_sda (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  reg [4:0] dvd_x;
  reg [3:0] dvd_y;
  reg dir_x;
  reg dir_y;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  assign {R, G, B} = video_active ? (((pix_x[9:5] == dvd_x) && (pix_y[8:5] == dvd_y)) ? ui_in[5:0] : ~ui_in[5:0]) : 6'b00_00_00;
  
  always @(posedge vsync) begin
    if (~rst_n) begin
      dvd_x <= 5'd10;
      dvd_y <= 4'd7;
      dir_x <= 1'd1;
      dir_y <= 1'd1;
    end else begin
      // dvd_x <= dvd_x + 1;
      if (dir_x) begin
        if (dvd_x == 5'd19)
          dir_x <= ~dir_x;
        else
          dvd_x <= dvd_x + 1;
      end else begin
        if (dvd_x == 5'd0)
          dir_x <= ~dir_x;
        else
          dvd_x <= dvd_x - 1;
      end

      if (dir_y) begin
        if (dvd_y == 4'd14)
          dir_y <= ~dir_y;
        else
          dvd_y <= dvd_y + 1;
      end else begin
        if (dvd_y == 4'd0)
          dir_y <= ~dir_y;
        else
          dvd_y <= dvd_y - 1;
      end
    end
  end

  wire _unused = &{pix_x[4:0], pix_y[9], pix_y[4:0]};

endmodule  // tt_um_factory_test
