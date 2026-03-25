
良好的编程规范是一个 FPGA 工程师必备的素质
# 一、Verilog 编程规范
## 1.1 编程规范重要性
## 1.2 工程组织形式
![](assets/Pasted%20image%2020250605201737.png)
- doc：工程相关的文档，包括datasheet（数据手册）、设计方案等
- par：主要存放工程文件和使用到的一些 IP 文件；
- rtl：主要存放工程的 rtl 代码，这是工程的核心，文件名与 module 名称应当一致，建议按照模块的层次分开存放；
- sim：主要存放工程的仿真代码， 复杂的工程里面，仿真也是不可或缺的部分， 可以极大减少调试的工作量。
## 1.3 文件头声明
```verilog
//**********************************Copyright (c)******************************// 
//原子哥在线教学平台： www.yuanzige.com
//技术支持： www.openedv.com/forum.php
//淘宝店铺： https://zhengdianyuanzi.tmall.com
//关注微信公众平台微信号： "正点原子"，免费获取 ZYNQ & FPGA & STM32 & LINUX 资料。//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028|
//All rights reserved 
//--------------------------------------------------------------------------------
// File name: led_twinkle
// Last modified Date: 2019/4/14 10:55:56
// Last Version: V1.0
// Descriptions: LED 灯闪烁
//---------------------------------------------------------------------------------
// Created by: 正点原子
// Created date: 2019/4/14 10:55:56
// Version: V1.0
// Descriptions: The original version
// 
//---------------------------------------------------------------------------------
//*******************************************************************************//
```
## 1.4 输入输出定义
```verilog
module led(
	input 				sys_clk 	, 	//系统时钟
	input 				sys_rst_n	, 	//系统复位，低电平有效
	output reg 	[3:0] 	led 			//4 位 LED 灯
);
```
1. 一行只定义一个信号；
2. 信号全部对齐；
3. 同一组的信号放在一起
## 1.5 parameter 定义
```verilog
//parameter define
parameter WIDTH 	= 25 		;	//板载50M时钟=20ns，0.5s/20ns=25000000，需要25bit
parameter COUNT_MAX = 25_000_000; 	//位宽
```
1. module 中的 parameter 声明，不建议随处乱放；
2. 将 parameter 定义放在紧跟着 module 的输入输出定义之后；
3. parameter 等常量命名全部使用大写。
## 1.6 wire/reg 定义
```verilog
//reg define
reg [WIDTH-1:0] counter 	;
reg [1:0] 		led_ctrl_cnt;

//wire define
wire 			counter_en 	;
```
1. 将 reg 与 wire 的定义放在紧跟着 parameter 之后；
2. 建议具有相同功能的信号集中放在一起；
3. 信号需要对齐， reg 和位宽需要空 2 格，位宽和信号名字至少空四格；
4. 位宽使用降序描述， [6:0]；
5. 时钟使用前缀 clk，复位使用后缀 rst；
6. 不能使用 Verilog 关键字作为信号名字；
7. 一行只定义一个信号。
## 1.7 信号命名
1. 信号命名需要体现其意义，比如 fifo_wr 代表 FIFO 读写使能；
2. 可以使用“ _ ”隔开信号，比如 sys_clk；
3. 内部信号不要使用大写，也不要使用大小写混合，建议全部使用小写；
4. 模块名字使用小写；
5. 低电平有效的信号，使用_n 作为信号后缀；
6. 异步信号，使用_a 作为信号后缀；
7. 纯延迟打拍信号使用_dly 作为后缀。
## 1.8 always 块描述方式
```verilog
//用于产生0.5秒使能信号的计数器
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (sys_rst_n == 1'b0)
		counter <= 1'b0;
	else if (counter_en)
		counter <= 1'b0;
	else
		counter <= counter + 1'b1;
end
```
1. if 需要空四格；
2. 一个 always 需要配一个 begin 和 end；
3. always 前面需要有注释；
4. beign 建议和 always 放在同一行；
5. 一个 always 和下一个 always 空一行即可，不要空多行；
6. 时钟复位触发描述使用 posedge sys_clk 和 negedge sys_rst_n
7. 一个 always 块只包含一个时钟和复位；
8. 时序逻辑使用非阻塞赋值。
## 1.9 assign 块描述方式
```verilog
//计数到最大值时产生高电平使能信号
assign counter_en = (counter == (COUNT_MAX - 1'b1)) ? 1'b1 : 1'b0;
```
1. assign 的逻辑不能太复杂，否则易读性不好；
2. assign 前面需要有注释；
3. 组合逻辑使用阻塞赋值。
## 1.10 空格和 TAB
由于不同的解释器对于 TAB 翻译不一致
所以建议不使用 TAB，全部使用空格。
## 1.11 注释
1. 注释描述需要清晰、简洁；
2. 注释描述不要废话，冗余；
3. 注释描述需要使用“ //”；
4. 注释描述需要对齐；
5. 核心代码和信号定义之间需要增加注释。
## 1.12 模块例化
moudle 模块例化使用 u_xx 表示
```verilog
//例化计时模块
time_count #(
	.MAX_NUM 	(TIME_SHOW	)
)u_time_count(
	.clk 		(sys_clk 	),
	.rst_n 		(sys_rst_n	),
	
	.flag 		(add_flag 	)
);

//例化数码管静态显示模块
seg_led_static u_seg_led_static (
	.clk 		(sys_clk 	),
	.rst_n 		(sys_rst_n	),
	
	.add_flag 	(add_flag 	),
	.sel 		(sel 		),
	.seg_led 	(seg_led 	)
);
```
## 1.13 其他注意事项
1. 代码写的越简单越好， 方便他人阅读和理解；
2. 不使用 repeat 等循环语句；
3. RTL 级别代码里面不使用 initial 语句，仿真代码除外；
4. 避免产生 Latch 锁存器， 比如组合逻辑里面的 if 不带 else 分支、 case 缺少 default 语句；
5. 避免使用太复杂和少见的语法，可能造成语法综合器优化力度较低。