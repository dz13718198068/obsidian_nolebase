`timescale 1ns / 1ps

module top(
    input  wire   	clk_50m,   				// 接FPGA 50MHz晶振输入引脚
	input  wire   	rst_n,     				// 接FPGA复位按键（低电平有效）
	input  wire   	sw1,       				// 拨码开关高位（接任意空闲IO，如Bank15的IO）
    input  wire   	sw0,       				// 拨码开关低位（接任意空闲IO，如Bank15的IO）
	input  wire     periph_rx, 				// 接Bank15的422接收引脚
    output wire     periph_tx, 				// 接Bank15的422发送引脚
	// Bank35：FMQL100TAI				
    input  wire 	fmql100_rx,				// 接Bank35的接收引脚
    output wire 	fmql100_tx,				// 接Bank35的发送引脚
    // Bank34：FMQL54S				
    input  wire 	fmql45s_rx,				// 接Bank34的接收引脚
    output wire 	fmql45s_tx				// 接Bank34的发送引脚
    );

wire [1:0] sw = {sw1, sw0};


zdyz_switch u_zdyz_switch(
    .clk_50m          (clk_50m),          // 50MHz时钟（括号内是上层模块的时钟信号）
    .rst_n            (rst_n),            // 低电平复位（括号内是上层模块的复位信号）

    .signal_in        (periph_rx),        // 422进来的信号
    .signal_out       (periph_tx),       // 422发出去的信号
    .sw               (sw),               // 拨码开关

    .signal_out_path0 (fmql100_tx), // 模拟传给100t
    .signal_out_path1 (fmql45s_tx), // 模拟传给45

    .signal_in_path0  (fmql100_rx),  // 模拟从100t来的信号
    .signal_in_path1  (fmql45s_rx)   // 模拟从45来的信号（最后一行无逗号）
);


endmodule
