`timescale 1ns / 1ps


module zdyz_switch(
	input	wire                	clk_50m,
	input	wire                	rst_n,
	
	input  	wire  					signal_in,			//422进来的信号
	output  wire					signal_out,			//422发出去的信号
	input   wire 		[1:0]      	sw,  				//拨码开关
	
	output  wire  					signal_out_path0,	//模拟传给100t
	output  wire  					signal_out_path1,	//模拟传给45
	
    input   wire  					signal_in_path0,	//模拟从100t来的信号
	input   wire  					signal_in_path1		//模拟从45来的信号
);



//用于拨码开关打拍消抖
reg [1:0] sw_r1, sw_r2, sw_r3;
always @(posedge clk_50m or negedge rst_n) begin
    if(!rst_n) begin
        sw_r1 <= 2'b00;
        sw_r2 <= 2'b00;
        sw_r3 <= 2'b00;
    end else begin
        sw_r1 <= sw;       // 第一级打拍
        sw_r2 <= sw_r1;    // 第二级打拍
        sw_r3 <= sw_r2;    // 第三级打拍（进一步稳定）
    end
end
// 防抖后的最终开关状态
wire [1:0] sw_stable = sw_r3;


//核心切换逻辑，多路选择器
assign signal_out_path0 = (sw_stable == 2'b01) ? signal_in : 1'bz;
assign signal_out_path1 = (sw_stable == 2'b10) ? signal_in : 1'bz;


assign signal_out = (sw_stable == 2'b01) ? signal_in_path0 :
					(sw_stable == 2'b10) ? signal_in_path1 : 1'bz;

	
	
endmodule
