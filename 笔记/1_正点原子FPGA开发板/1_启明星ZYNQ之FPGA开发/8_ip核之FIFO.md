# **一、FIFO基础**
FIFO（First In First Out，先入先出），一种数据缓存器，用来实现数据先入先出的读写方式。FIFO 一般指的是对数据的存储具有先入先出特性的缓存器，常被用于多比特数据跨时钟域的转换、读写数据带宽不同步等场合。根据FIFO工作的时钟域可分为同步FIFO和异步FIFO。

## **IP核简介**

 本质：是由RAM加读写控制逻辑构成的先入先出数据缓冲器
 与RAM区别：FIFO没有外部读写地址线，只能按顺序写入和读出，由其数据地址内部写指针自动加1完成。
 优劣：FIFO使用过程中不会存在像RAM那样的读写冲突。而RAM可由地址线决定读写地址。
 注意事项：先写入的为数据高位，后写入的数据被置于低位；读出的数据也是高位在前，低位在后。

## **FIFO IP核的常见参数：**

 FIFO 的宽度：一次读写操作的数据位宽 N。
 FIFO 的深度：可以存储多少个宽度为 N 位的数据。
 将空标志：almost_empty，即将被读空（相对于empty提前一个周期拉高）。
 空标志：empty，FIFO 已空时由 FIFO 的状态电路送出的一个信号，以阻止 FIFO 的读操作继续从FIFO 中读出数据而造成无效数据的读出。
 将满标志：almost_full，即将被写满（相对于full提前一个周期拉高）。
 满标志：full，FIFO 已满时由 FIFO 的状态电路送出的一个信号，以阻止 FIFO 的写操作继续向 FIFO中写数据而造成溢出。
 写时钟：写 FIFO 时所遵循的时钟，在每个时钟的上升沿触发。
 读时钟：读 FIFO 时所遵循的时钟，在每个时钟的上升沿触发。
 可配置满阈值：影响可配置满信号于何时有效，其可配置范围一般为 3~写深度-3。
 可配置满信号：prog_full，表示 FIFO 中存储的数据量达到可配置满阈值中配置的数值。
 可配置空阈值：影响可配置空信号于何时有效，其可配置范围一般为 2~读深度-3。
 可配置空信号：prog_empty，表示 FIFO 中剩余的数据量已经减少到可配置空阈值中配置的数值。

**下图为vivado软件中FIFO IP核的信号框图，黑色为必要信号，蓝色为可选信号，灰色为边带信号。**
![|620](assets/Pasted%20image%2020250526081050.png)
![|620](assets/Pasted%20image%2020250526081053.png)
# **二、实验设计**

 任务：生成一个异步FIFO

 功能：FIFO为空时，像FIFO中写入数据，写满后停止写操作；当FIFO为满时，从FIFO中读出数据，直到FIFO读空后停止读操作。

**首先创建IP核→IP Catalog→配置选项卡**

**“Basic” 选项卡**

 lnterface Type（接口模式）：
 Native（常规）接口
 AXI Memory Mapped（内存映射）接口：用于与PS端尽心数据交互
 AXI Stream（流）接口：用于高速信号处理场景，如光口通信
 Fifo Implementation（FIFO 实现）：FIFO IP核资源配置

 四种FIFO资源：
 Block RAM（块 RAM）
 Distributed RAM（分布式 RAM）
 Shift Register（移位寄存器）：仅可用于实现同步 FIFO。
 Builtin FIFO（内置 FIFO）

 两种FIFO类型：
 Common Clocks（公共时钟，即同步 FIFO）
 Independent Clocks（独立时钟，即异步 FIFO）
 synchronization Stages（同步阶段）：读写状态信号输出延迟，默认为2
 FIFO Implementation Options（FIFO 实现方案）：

**“Native Ports” 选项卡**

 Read Mode（读取模式），两种模式：
 Standard FIFO（标准 FIFO）：标准模式的数据输出会比读使能延迟一拍。
 First Word Fall Through（首字直通，简称 FWFT 模式，即预读模式）：预读模式的数据与读使能同时输出。
 Data Port Parameters（数据端口参数）：用于设置 FIFO 的读写数据位宽和读写深度，其中写数据位宽可在 1~1024 内任意设置。
 写深度的可支持参数配置我们可以通过下拉来查看，这里我们设置为 256，需要注意的是，虽然我们设置的深度为 256，但实际深度只有 255；
 读数据位宽支持 1：8~8：1之间的偶数比，这里我们保持默认的 1：1 比例，即读数据位宽为 8
 ECC，Output Register and Power Gating Options（ECC、输出寄存器和电源选通选项）
 第一行有四个信号，当我们勾选 ECC（纠错码）后，可以选择 Hard ECC（硬 ECC）或 Soft ECC（软 ECC），并可以勾选 Single Bit Error Injection（注入单 bit 错误）和 Double Bit Error Injection（注入双bit 错误）。
 第二行有两个信号，“ECC Pipeline Reg（ECC 管道寄存器）”和“Dynamic Power Gating（动态功率选通）”都是仅限 UltraScale 系列芯片使用 Builtin FIFO 资源实现 FIFO 时才可进行配置。
 第三行用于配置输出寄存器，勾选“Output Registers（输出寄存器）”后，可以选择添加“Embedded Registers（嵌入式寄存器）”和“Fabric Registers（结构寄存器）”。其作用是可以改善 FIFO的时序，为此付出的代价是每添加一个输出寄存器，输出就会延后一拍。
 Initialization（初始化）
 Reset Pin（复位脚）：选择是否引入复位信号，高电平有效。实际设计中，在 FPGA 配置完成后，写操作开始前，FIFO 必须要进行复位操作，需要注意的是，在进行复位操作时，读写时钟必须是有效的。这里我们保持默认的勾选状态，即启用复位信号。
  Enable Reset Synchronization（启用复位同步）：用于设置异步 FIFO 时是否启用同步复位，需要注意的是官方文档中建议复位信号至少要保持三个时钟周期（以慢时钟为准）的有效，且在复位后至少要经过三十个时钟周期（以慢时钟为准）后，才能对 FIFO 进行写数据操作。这里我们保持默认的勾选状态，即启用同步复位。
 Enable Safety Circuit（启用安全电路）：用于设置 FIFO 是否向外输出 wr_rst_busy（写复位忙信号）和 rd_rst_busy（读复位忙信号），这两个信号皆是高电平表示处于复位状态，低电平表示空闲，我们可以通过这两个信号来判断 FIFO 是否复位完成，防止我们在复位完成前对 FIFO 进行读写操作而导致读写错误，所以我们保持默认的勾选状态，即启用安全电路。需要注意的是官方文档中建议当启用安全电路时，复位信号至少要保持八个时钟周期（以慢时钟为准）的有效，且在复位后至少要经过六十个时钟周期（以慢时钟为准）后，才能对 FIFO 进行写数据操作。
 Reset Type（复位类型）：当选择使用非 Builtin FIFO 资源来实现同步 FIFO 时，可以选择复位类型为Asynchronous Reset（异步复位）或 Synchronous Reset（同步复位），使用异步 FIFO 模式时不需要考虑该配置。
 Full Flags Reset Value（满信号的重置值）：用于设置复位时三个满信号（满信号，将满信号，设置满信号）的状态是高电平还是低电平。这里我们保持默认设置 1 即可。
 Dout Reset Value（输出的数据重置值）：设置复位期间 FIFO 输出总线上的数据值，若未启用，则复位期间输出总线上的值时未知的。切记设置时此值的位宽不可超过读数据的位宽，这里我们保持默认的 0即可。
 Read Latency（读延迟）：输出延迟几拍。标准模式下没有启用输出寄存器，因此延迟1拍。

**“Status Flags” 选项卡**

 Optional Flags（可选标准）：
 Almost Full Flag（将满信号）：写数据个数≥FIFO深度-1时，拉高
 Almost Empty Flag（将空信号）：读数据个数≥FIFO深度-1时，拉高
 Handshaking Options（握手选项）
 Write Port Handshaking（写端口握手）：可使能以下两个信号
  Write Ackongledge（写应答）信号：成功写入数据标志位
 Overflow（满溢出）信号：写入数据无效（溢出）标志位
 Read Port Handshaking（读端口握手）：可使能以下两个信号
 Valid Flag（读有效标志）信号
 Underflow Flag（空溢出）信号
 Programmable Flags（可编程标志）
# **三、模块设计**

![|500](assets/Pasted%20image%2020250526081200.png)
**fifo写模块（代码见文末）**
![|580](assets/Pasted%20image%2020250526081209.png)
![|580](assets/Pasted%20image%2020250526081203.png)
almost_empty打两拍，属于fifo读时钟域，需要打拍来进行同步。
![|390](assets/Pasted%20image%2020250526081215.png)
状态机如图
即将空的时候进入延迟
![](assets/Pasted%20image%2020250526081218.png)
延迟10s以后，等待FIFO IP核内部状态信号更新，进入写操作
![](assets/Pasted%20image%2020250526081221.png)
时钟往FIFO里写入递增数据，almost_full拉高后，进入state0停止写入数据
![](assets/Pasted%20image%2020250526081224.png)
**fifo读模块（完整代码见文末）**
![](assets/Pasted%20image%2020250526081229.png)
fifo_full信号是属于写时钟域的，因此跨时钟收到的信号打两拍进行同步
即将写满，进入延时状态，等待FIFO IP核内部信号稳定
![](assets/Pasted%20image%2020250526081233.png)
延迟结束后进入读状态
![](assets/Pasted%20image%2020250526081237.png)
读状态下fifo_rd_en读使能持续拉高。知道即将读空almost_empty拉高，则关闭读使能fifo_rd_en，进入第一个状态。
**fifo仿真模块（略）**
仿真波形分析
![](assets/Pasted%20image%2020250526081240.png)
仿真波形无误，上板测试
lia信号符合预期![](assets/Pasted%20image%2020250526081243.png)
# **四、代码编写**
## fifo_wr
```verilog
module fifo_wr(
	input 				clk 			, 	// 时钟信号
	input 				rst_n 			, 	// 复位信号
	input 				almost_empty	, 	// FIFO 将空信号
	input 				almost_full 	, 	// FIFO 将满信号
	output reg 			fifo_wr_en 		, 	// FIFO 写使能
	output reg [7:0] 	fifo_wr_data 		// 写入 FIFO 的数据
);

//reg define

reg [1:0] 	state 				; 	//动作状态
reg 		almost_empty_d0 	; 	//almost_empty 延迟一拍
reg 		almost_empty_syn 	; 	//almost_empty 延迟两拍
reg [3:0] 	dly_cnt 			; 	//延迟计数器

//*****************************************************
//** main code
//*****************************************************
//因为 almost_empty 信号是属于 FIFO 读时钟域的
//所以要将其同步到写时钟域中

always@( posedge clk ) begin
	if( !rst_n ) begin
		almost_empty_d0 	<= 1'b0 			;
		almost_empty_syn 	<= 1'b0 			;
	end
	else begin
		almost_empty_d0 	<= almost_empty 	;
		almost_empty_syn 	<= almost_empty_d0 	;
	end
end

//向 FIFO 中写入数据
always @(posedge clk ) begin
	if( !rst_n ) begin
		fifo_wr_en 		<= 1'b0;
		fifo_wr_data 	<= 8'd0;
		state 			<= 2'd0;
		dly_cnt 		<= 4'd0;
	end
	else begin
		case(state)
			2'd0: begin
				if(almost_empty_syn) begin //如果检测到 FIFO 将被读空（下一拍就会空）
					state <= 2'd1; //就进入延时状态
				end
				else
					state <= state;
			end
			2'd1: begin
				if(dly_cnt == 4'd10) begin //延时 10 拍
					//原因是 FIFO IP 核内部状态信号的更新存在延时
					//延迟 10 拍以等待状态信号更新完毕
					dly_cnt 	<= 4'd0;
					state 		<= 2'd2; //开始写操作
					fifo_wr_en 	<= 1'b1; //打开写使能
				end
				else
					dly_cnt <= dly_cnt + 4'd1;
			end
			2'd2: begin
				if(almost_full) begin //等待 FIFO 将被写满（下一拍就会满）
					fifo_wr_en 		<= 1'b0; //关闭写使能
					fifo_wr_data 	<= 8'd0;
					state 			<= 2'd0; //回到第一个状态
				end
				else begin //如果 FIFO 没有被写满
					fifo_wr_en 		<= 1'b1	; //则持续打开写使能
					fifo_wr_data 	<= fifo_wr_data + 1'd1; //且写数据值持续累加
				end
			end
			default : state <= 2'd0;
		endcase
	end
end
endmodule
```
## fifo读模块代码
```verilog
module fifo_rd(
	input 		clk 			, 	// 时钟信号
	input 		rst_n 			, 	// 复位信号
	input [7:0] fifo_dout 		, 	// 从 FIFO 读出的数据
	input 		almost_full 	, 	// FIFO 将满信号
	input 		almost_empty 	, 	// FIFO 将空信号
	output reg 	fifo_rd_en 			// FIFO 读使能
);

//reg define

reg [1:0] 	state 			; //动作状态
reg 		almost_full_d0 	; //almost_full 延迟一拍
reg 		almost_full_syn ; //almost_full 延迟两拍
reg [3:0] 	dly_cnt 		; //延迟计数器
		
//*****************************************************
//** main code
//*****************************************************
//因为 fifo_full 信号是属于 FIFO 写时钟域的
//所以要将其同步到读时钟域中

always@( posedge clk ) begin
	if( !rst_n ) begin
		almost_full_d0 	<= 1'b0 			;
		almost_full_syn <= 1'b0 			;
	end
	else begin
		almost_full_d0 	<= almost_full 		;
		almost_full_syn <= almost_full_d0 	;
	end
end

//读出 FIFO 的数据
always @(posedge clk ) begin
	if(!rst_n) begin
		fifo_rd_en 	<= 1'b0;
		state 		<= 2'd0;
		dly_cnt 	<= 4'd0;
	end
	else begin
		case(state)
			2'd0: begin
				if(almost_full_syn) //如果检测到 FIFO 被写满
					state <= 2'd1; //就进入延时状态
				else
					state <= state;
			end
			2'd1: begin
				if(dly_cnt == 4'd10) begin //延时 10 拍
					//原因是 FIFO IP 核内部状态信号的更新存在延时
					//延迟 10 拍以等待状态信号更新完毕
					dly_cnt <= 4'd0;
					state 	<= 2'd2; //开始读操作
				end
				else
					dly_cnt <= dly_cnt + 4'd1;
			end
			2'd2: begin
				if(almost_empty) begin //等待 FIFO 将被读空（下一拍就会空）
					fifo_rd_en <= 1'b0; //关闭读使能
					state <= 2'd0; //回到第一个状态
				end
				else //如果 FIFO 没有被读空
					fifo_rd_en <= 1'b1; //则持续打开读使能
			end
			default : state <= 2'd0;
		endcase
	end
end

endmodule

```
## top模块代码
```verilog
module ip_fifo(
	input 	sys_clk 	, 			// 时钟信号
	input 	sys_rst_n 				// 复位信号
);

//wire define
wire 		fifo_wr_en 			; 	// FIFO 写使能信号
wire 		fifo_rd_en 			; 	// FIFO 读使能信号
wire [7:0] 	fifo_din 			; 	// 写入到 FIFO 的数据
wire [7:0] 	fifo_dout 			; 	// 从 FIFO 读出的数据
wire 		almost_full 		; 	// FIFO 将满信号
wire 		almost_empty 		; 	// FIFO 将空信号
wire 		fifo_full 			; 	// FIFO 满信号
wire 		fifo_empty 			; 	// FIFO 空信号
wire [7:0] 	fifo_wr_data_count 	; 	// FIFO 写时钟域的数据计数
wire [7:0] 	fifo_rd_data_count 	; 	// FIFO 读时钟域的数据计数

//*****************************************************
//** main code
//*****************************************************
//例化 FIFO IP 核
fifo_generator_0 fifo_generator_0 (
	.wr_clk 		( sys_clk 				), 	// input wire wr_clk
	.rd_clk 		( sys_clk 				), 	// input wire rd_clk
	.wr_en 			( fifo_wr_en 			), 	// input wire wr_en
	.rd_en 			( fifo_rd_en 			), 	// input wire rd_en
	.din 			( fifo_din 				), 	// input wire [7 : 0] din
	.dout 			( fifo_dout 			), 	// output wire [7 : 0] dout
	.almost_full 	( almost_full 			), 	// output wire almost_full
	.almost_empty 	( almost_empty 			), 	// output wire almost_empty
	.full 			( fifo_full 			), 	// output wire full
	.empty 			( fifo_empty 			), 	// output wire empty
	.wr_data_count 	( fifo_wr_data_count 	), 	// output wire [7 : 0] wr_data_count
	.rd_data_count 	( fifo_rd_data_count 	) 	// output wire [7 : 0] rd_data_count
);

//例化写 FIFO 模块
fifo_wr u_fifo_wr(
	.clk 			( sys_clk 		), 	// 写时钟
	.rst_n 			( sys_rst_n 	), 	// 复位信号
	.fifo_wr_en 	( fifo_wr_en 	), 	// fifo 写请求
	.fifo_wr_data	( fifo_din 		), 	// 写入 FIFO 的数据
	.almost_empty 	( almost_empty 	), 	// fifo 将空信号
	.almost_full 	( almost_full 	) 	// fifo 将满信号
);

//例化读 FIFO 模块
fifo_rd u_fifo_rd(
	.clk 			( sys_clk 		), 	// 读时钟
	.rst_n 			( sys_rst_n 	), 	// 复位信号
	.fifo_rd_en 	( fifo_rd_en 	),	// fifo 读请求
	.fifo_dout 		( fifo_dout 	), 	// 从 FIFO 输出的数据
	.almost_empty 	( almost_empty 	), 	// fifo 将空信号
	.almost_full 	( almost_full 	) 	// fifo 将满信号
);

//例化 ILA IP 核
ila_0 ila_0 (
	.clk 	( sys_clk 				), 	// input wire clk
	.probe0 ( fifo_wr_en 			), 	// input wire [0:0] probe0
	.probe1 ( fifo_rd_en 			), 	// input wire [0:0] probe1
	.probe2 ( fifo_din 				), 	// input wire [7:0] probe2
	.probe3 ( fifo_dout 			), 	// input wire [7:0] probe3
	.probe4 ( fifo_empty 			), 	// input wire [0:0] probe4
	.probe5 ( almost_empty 			), 	// input wire [0:0] probe5
	.probe6 ( fifo_full 			), 	// input wire [0:0] probe6
	.probe7 ( almost_full 			), 	// input wire [0:0] probe7
	.probe8 ( fifo_wr_data_count 	), 	// input wire [7:0] probe8
	.probe9	( fifo_rd_data_count 	) 	// input wire [7:0] probe9
);
endmodule
```
## 仿真模块代码
```verilog
`timescale 1ns / 1ps
module tb_ip_fifo( );
// Inputs
reg 	sys_clk		;
reg 	sys_rst_n	;

// Instantiate the Unit Under Test (UUT)
ip_fifo u_ip_fifo (
	.sys_clk 	(sys_clk	),
	.sys_rst_n 	(sys_rst_n	)
);

//Genarate the clk
parameter PERIOD = 20;

always begin
	sys_clk = 1'b0	;
	#(PERIOD/2)		;
	sys_clk = 1'b1	;
	#(PERIOD/2)		;
end

initial begin
	// Initialize Inputs
	sys_rst_n = 0	;
	// Wait 100 ns for global reset to finish
	#100 			;
	sys_rst_n = 1	;
	// Add stimulus here
end

endmodule
```
source结构
其中ila用于板间信号抓取
![|408](assets/Pasted%20image%2020250526081734.png)