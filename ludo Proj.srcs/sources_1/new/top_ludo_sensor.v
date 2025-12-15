// top_ludo_sensor.v
// Pack 27 individual sensor pins into a single wide bus.
// Adjust order to match PCB/XDC mapping if needed.
`timescale 1ns / 1ps
module top_ludo_sensor (
  input  wire s0,  input wire s1,  input wire s2,  input wire s3,  input wire s4,
  input  wire s5,  input wire s6,  input wire s7,  input wire s8,  input wire s9,
  input  wire s10, input wire s11, input wire s12, input wire s13, input wire s14,
  input  wire s15, input wire s16, input wire s17, input wire s18, input wire s19,
  input  wire s20, input wire s21, input wire s22, input wire s23, input wire s24,
  input  wire s25, input wire s26,
  output wire [26:0] sensors_bus
);
  // pack with s26 as MSB down to s0 as LSB (adjust if you prefer a different ordering)
  assign sensors_bus = {s26,s25,s24,s23,s22,s21,s20,s19,s18,s17,s16,s15,s14,s13,s12,s11,s10,s9,s8,s7,s6,s5,s4,s3,s2,s1,s0};
endmodule
