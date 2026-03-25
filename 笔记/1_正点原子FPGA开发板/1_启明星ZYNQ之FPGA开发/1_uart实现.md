遗留问题：

波特率如何能够配置：parameter
中断如何设计
buffer大小如何配置
如何在线配置波特率
需要缓存怎么解决
满了怎么处理，不满怎么处理
buffer如果不满，传输完了怎么处理：这里last标志，拉高代表最后一次数据传说

**一、基础知识篇**

**1、串行通信基础知识**

并行通信：多条数据线同时传输数据，传输速度快、占用引脚资源多。
串行通信：一条传输线上逐个传输，线路简单占用引脚少，传输速度慢；
同步通信：时钟线+数据线。发送设备与接收设备同时受1个时钟配置
异步通信：仅数据传输线。各自有自己的时钟，用波特率约束传输
串行数据的方向：单工、半双工、全双工
![](photo/Pasted%20image%2020250526081814.png)

常见串行通信接口

UART：
单总线：
SPI：M mast， I input，S slave，O output
I2C：
![](photo/Pasted%20image%2020250526081824.png)

**2、异步串口通信UART基础知识**

什么是UART，universal asynchronous receiver transmitter，
①协议层
协议层：数据格式
![](photo/Pasted%20image%2020250526081830.png)

协议层：传输速率
串口通信常用波特率表示，表示每秒传输二进制数据的位数，单位bps（位/秒），常用波特率9600、19200、38400、57600、115200等
波特率的计算：
1 s = 10e9 ns
1bit所需要占用的时间：10e9 / 115200
50Mhz时钟一个完整的时钟周期为20ns
需要多少个时钟周期传输1bit：10e9 / 115200 / 20 = 434个时钟周期

②物理层
物理层：接口标准
![](photo/Pasted%20image%2020250526081843.png)

**3、RS232接口**

DB9接口
![](photo/Pasted%20image%2020250526081848.png)
RXD、TXD、GND三个接口组成了串口通信

**4、USB接口**
Date+-：一对差分线组成信号线，用于传输数据
ID：用于识别Type型号
![](photo/Pasted%20image%2020250526081853.png)

CH340C芯片可以将USB转串口，后续可用该设备通过串口助手将PC端和FPGA进行通信。

**二、代码设计**

**一、波特率的计算**

**1、什么是波特率**

波特率（bandrate）,指的是串口通信的速率，也就是串口通信时每秒钟可以传输多少个二进制位。比如每秒钟可以传输9600个二进制（传输一个二进制位需要的时间是1/9600秒，也就是104us），波特率就是9600。

串口的通信波特率不能随意设定，而应该再一些值中去选择。一般常见的波特率是9600或者115200（低端的单片机如51常用9600，高端的单片机和嵌入式Coc一般用115200）。为什么波特率不能随便指定？主要是因为：

第一：通信双方必须事先设定相同的波特率这样才能成功通信，如果发送方和接收方按照不同的波特率通信则根本收不到，因此波特率最好是大家熟知的而不是随意指定。

第二：常用的波特率经过了长久的发展，就形成了共识，大家常用的就是9600或者115200。标准波特率：包括2400、4800、9600、19200、38400、57600、115200等标准波特率。

**2、波特率的含义**

波特率表示每秒钟传送的码元bai符号的个数，du是衡量数据传送速率的指标，它用单位时间内载波zhi调制状态改变的次数来表示。  

在信息传输通道中，携带数据信息的信号单元叫码元，每秒钟通过信道传输的码元数称为码元传输速率，简称波特率。波特率是传输通道频宽的指标。

**3、波特率计算举例**

例如7Z010clg400的FPAG芯片，系统时钟频率为50Mhz，若需要配置9600波特率，工程中应将50M/9600=5208个时钟周期传输1个码元，即可实现1s中传输9600个二进制位。

**二、代码设计**

接收端模块
![](photo/Pasted%20image%2020250526081904.png)

接收端代码：见文末
接收端仿真代码：见文末
接收端仿真结果
![](photo/Pasted%20image%2020250526081913.png)

发送端模块
![](photo/Pasted%20image%2020250526081917.png)

发送端代码：见文末
发送端仿真代码：见文末
发送端仿真结果
![](photo/Pasted%20image%2020250526081935.png)

top顶层设计
![](photo/Pasted%20image%2020250526081931.png)

top顶层代码：见文末
top顶层仿真代码：见文末
top仿真结果
![](photo/Pasted%20image%2020250526081943.png)
**三、上板验证流程**

验证流程

仿真时是模拟输入一段串口数据，接收端接收数据后将相同数据通过发送端传回。因此我们首先需要想办法通过PC给uart_rxd这根线传输一段串口数据。前面提到CH340C芯片可以将USB转ttl，因此可以通过串口助手将信号传给fpga。下图为搭载CH340C芯片的usb转串口设备。
![](photo/Pasted%20image%2020250526081947.png)

连接线路，将CH340C的发送端连接fpga接收端，CH340C接收端连接fpga发送端
![](photo/Pasted%20image%2020250526081950.png)

分配fpga的引脚
![](photo/Pasted%20image%2020250526081955.png)

通过查询硬件原理图，将引脚分配给M19和U14
![](photo/Pasted%20image%2020250526081958.png)

上板测试发现发送55后未收到数据
![](photo/Pasted%20image%2020250526082001.png)

此时无论如何测试都无法收到数据，但是通过插拔杜邦线产生的电平波动是可以传回混乱的数据的。此时认为理论上应该正确，排查错误点

**思路：Uart_rx和Uart_tx同时使用，无法准确定位问题出处，若更改代码只保留TX端，通过按键，每按一次按键，向CH340C发送一串固定数据，则可证明FPGA是可以将数据以uart协议传输出去的。如果证明以上猜测，那问题定位可近一步缩减范围。**

按键发送uart代码设计
```verilog

module uart_tx(
input sys_clk,//50M系统时钟
input sys_rst_n,//系统复位
input uart_tx_en,//发送使能信号
output reg uart_txd//串口发送数据线

);

parameter SYS_CLK_FRE=50_000_000;//50M系统时钟
parameter BPS=     9_600;//波特率9600bps，可更改
localparam BPS_CNT=  SYS_CLK_FRE/BPS;//传输一位数据所需要的时钟个数
reg uart_tx_en_d0;//寄存1拍
reg uart_tx_en_d1;//寄存2拍
reg tx_flag;//发送标志位
reg [7:0]  uart_data_reg;//发送数据寄存器
reg [15:0] clk_cnt;//时钟计数器
reg [3:0]  tx_cnt;//发送个数计数器
reg [7:0] uart_data=  8'b01010101;//发送的8位置数据
wire pos_uart_en_txd;//使能信号的上升沿

assign pos_uart_en_txd = uart_tx_en_d0 && (~uart_tx_en_d1);//捕捉使能端的上升沿信号，用来标志输出开始传输

always @(posedge sys_clk or negedge sys_rst_n)begin//开始传输使能信号打两拍，消除亚稳态
if(!sys_rst_n)begin
uart_tx_en_d0<=1'b0;
uart_tx_en_d1<=1'b0;
end
else begin
uart_tx_en_d0<=uart_tx_en;
uart_tx_en_d1<=uart_tx_en_d0;
end
end

always @(posedge sys_clk or negedge sys_rst_n)begin//捕获到使能端的上升沿信号，拉高传输开始标志位，并在第9个数据（终止位）的传输过程正中（数据比较稳定）再将传输开始标志位拉低，标志传输结束
if(!sys_rst_n)begin
tx_flag<=1'b0;
uart_data_reg<=8'd0;
end
else if(pos_uart_en_txd)begin
uart_data_reg<=uart_data;
tx_flag<=1'b1;
end
else if((tx_cnt==4'd9) && (clk_cnt==BPS_CNT/2))begin//在第9个数据（终止位）的传输过程正中（数据比较稳定）再将传输开始标志位拉低，标志传输结束
tx_flag<=1'b0;
uart_data_reg<=8'd0;
end
else begin
uart_data_reg<=uart_data_reg;
tx_flag<=tx_flag;
end
end

always @(posedge sys_clk or negedge sys_rst_n)begin//时钟每计数一个BPS_CNT（传输一位数据所需要的时钟个数），即将数据计数器加1，并清零时钟计数器
if(!sys_rst_n)begin
clk_cnt<=16'd0;
tx_cnt <= 4'd0;
end
else if(tx_flag) begin
if(clk_cnt<BPS_CNT-1)begin
clk_cnt<=clk_cnt+1'b1;
tx_cnt <=tx_cnt;
end
else begin
clk_cnt<=16'd0;
tx_cnt <=tx_cnt+1'b1;
end
end
else begin
clk_cnt<=16'd0;
tx_cnt<= 4'd0;
end
end

always @(posedge sys_clk or negedge sys_rst_n)begin//在每个数据的传输过程正中（数据比较稳定）将数据寄存器的数据赋值给数据线
if(!sys_rst_n)
uart_txd<= 1'b1;
else if(tx_flag)
case(tx_cnt)
4'd0:uart_txd<=1'b0;
4'd1:uart_txd<=uart_data_reg[0];
4'd2:uart_txd<=uart_data_reg[1];
4'd3:uart_txd<=uart_data_reg[2];
4'd4:uart_txd<=uart_data_reg[3];
4'd5:uart_txd<=uart_data_reg[4];
4'd6:uart_txd<=uart_data_reg[5];
4'd7:uart_txd<=uart_data_reg[6];
4'd8:uart_txd<=uart_data_reg[7];
4'd9:uart_txd<=1'b1;
default:;
endcase
else
uart_txd<= 1'b1;
end

endmodule
```
上板测试结果：每按一次按键，串口助手未收到数据。因为布线简单，所以尝试修改杜邦线插线位置后，意外成功
![](photo/Pasted%20image%2020250526082226.png)

**定位原因：杜邦线插错位置导致。”※“标注位置应为硬件原理图接口“1”的位置。**
![](photo/Pasted%20image%2020250526082228.png)

再测试完整的Uart程序后，发现运行无误
![](photo/Pasted%20image%2020250526082232.png)

上板测试完成

**代码部分**

接收端代码
```verilog
`timescale 1ns / 1ps

//时钟频率50Mhz，所需波特率9600bps，50,000,000/9600=5208

module UART_RX(

input sys_clk,//50M系统时钟

input sys_rst_n,//系统复位

input uart_rxd,//接收数据线

output reg uart_rx_done,//数据接收完成标志

output reg [7:0]uart_rx_data//接收到的数据

    );

//常量化参数

parameterBand_BPS=9600;//波特率9600bps，可更改

parameterSYS_CLK_FRE=50_000_000;//50M系统时钟

localparamBand_BPS_CNT=SYS_CLK_FRE/Band_BPS;//传输一位数据所需要的时钟个数:5208。localparam的作用范围仅限于声明该常量的模块内部，不能用于模块与模块之间的参数传递

reg uart_rx_d0;//打1拍，消除亚稳态

reg uart_rx_d1;//打2拍

reg [15:0]clk_cnt;//时钟计数器

reg [3:0]rx_cnt;//接收计数器

reg rx_flag;//接收标志位

reg [7:0]uart_rx_data_reg;//数据寄存

wire neg_uart_rx_data;//数据的下降沿

assignneg_uart_rx_data = uart_rx_d1 & (~uart_rx_d0);  //捕获数据线的下降沿，用来标志数据传输开始

//将数据线打两拍：

//作用1：同步不同时钟域信号，防止亚稳态；

//作用2：用以捕获下降沿

always@(posedge sys_clk or negedge sys_rst_n)begin

if(!sys_rst_n)begin

uart_rx_d0<=1'b0;

uart_rx_d1<=1'b0;

end

else begin

uart_rx_d0<=uart_rxd;//打两拍

uart_rx_d1<=uart_rx_d0;

end

end

//捕获到数据下降沿（起始位0）后，拉高传输开始标志位，并在第9个数据（终止位）的传输过程正中（数据比较稳定）再将传输开始标志位拉低，标志传输结束

always@(posedge sys_clk or negedge sys_rst_n)begin

if(!sys_rst_n)

rx_flag<=1'b0;

else begin

if(neg_uart_rx_data)

rx_flag<=1'b1;

else if((rx_cnt==4'd9)&&(clk_cnt==Band_BPS_CNT/2))//在第9个数据（终止位）的传输过程正中（数据比较稳定）再将传输开始标志位拉低，标志传输结束

rx_flag<=1'b0;

else

rx_flag<=rx_flag;

end

end

//时钟每计数一个Band_BPS_CNT（传输一位数据所需要的时钟个数），即将数据计数器加1，并清零时钟计数器

always@(posedge sys_clk or negedge sys_rst_n)begin

if(!sys_rst_n)begin

rx_cnt<=4'd0;

clk_cnt<=16'd0;

end

else if(rx_flag)begin

if(clk_cnt<Band_BPS_CNT-1'b1)begin

clk_cnt<=clk_cnt+1'b1;

rx_cnt<=rx_cnt;

end

else begin

clk_cnt<=16'd0;

rx_cnt<=rx_cnt+1'b1;

end

end

else begin

rx_cnt<=4'd0;

clk_cnt<=16'd0;

end

end

//在每个数据的传输过程正中（数据比较稳定）将数据线上的数据赋值给数据寄存器

always@(posedge sys_clk or negedge sys_rst_n)begin

if(!sys_rst_n)

uart_rx_data_reg<=8'd0;

else if(rx_flag)

if(clk_cnt==Band_BPS_CNT/2) begin

case(rx_cnt)

4'd1:uart_rx_data_reg[0]<=uart_rxd;

4'd2:uart_rx_data_reg[1]<=uart_rxd;

4'd3:uart_rx_data_reg[2]<=uart_rxd;

4'd4:uart_rx_data_reg[3]<=uart_rxd;

4'd5:uart_rx_data_reg[4]<=uart_rxd;

4'd6:uart_rx_data_reg[5]<=uart_rxd;

4'd7:uart_rx_data_reg[6]<=uart_rxd;

4'd8:uart_rx_data_reg[7]<=uart_rxd;

default:;

endcase

end

else

uart_rx_data_reg<=uart_rx_data_reg;

else

uart_rx_data_reg<=8'd0;

end

//当数据传输到终止位时，拉高传输完成标志位，并将数据输出

always@(posedge sys_clk or negedge sys_rst_n)begin

if(!sys_rst_n)begin

uart_rx_done<=1'b0;

uart_rx_data<=8'd0;

end

else if(rx_cnt==4'd9)begin

uart_rx_done<=1'b1;

uart_rx_data<=uart_rx_data_reg;

end

else begin

uart_rx_done<=1'b0;

uart_rx_data<=8'd0;

end

end

endmodule
```
接收端仿真代码
```verilog
`timescale 1ns/1ns//定义时间刻度

//模块、接口定义

module uart_rx_tb();

reg sys_clk;

reg sys_rst_n;

reg uart_rxd;

wire uart_rx_done;

wire uart_rx_data;

//例化被测试的接收模块

UART_RX #(

.Band_BPS(960000),//波特率9600

.SYS_CLK_FRE(50_000_000)//时钟频率50M

)

tb_UART_RX(

.sys_clk(sys_clk),

.sys_rst_n(sys_rst_n),

.uart_rxd(uart_rxd),

.uart_rx_done(uart_rx_done),

.uart_rx_data(uart_rx_data)

);

localparamCNT=50_000_000/960000*20;//计算出传输每个时钟所需要的时间，乘20ns

initial begin//传输8位数据8'b01010101

//初始时刻定义

sys_clk<=1'b0;

sys_rst_n<=1'b0;

uart_rxd<=1'b1;

#20 //系统开始工作

sys_rst_n<=1'b1;

#(CNT/2)

uart_rxd<=1'b0;//开始传输起始位

#CNT

uart_rxd<=1'b1;//传输最低位，第1位

#CNT

uart_rxd<=1'b0;//传输第2位

#CNT

uart_rxd<=1'b1;//传输第3位

#CNT

uart_rxd<=1'b0;//传输第4位

#CNT

uart_rxd<=1'b1;//传输第5位

#CNT

uart_rxd<=1'b0;//传输第6位

#CNT

uart_rxd<=1'b1;//传输第7位

#CNT

uart_rxd<=1'b0;//传输最高位，第8位

#CNT

uart_rxd<=1'b1;//传输终止位

end

always begin

#10sys_clk=~sys_clk;//时钟20ns,50M

end

endmodule
```
发送端代码
```verilog
module uart_tx(

input sys_clk,//50M系统时钟

input sys_rst_n,//系统复位

input [7:0] uart_data,//发送的8位置数据

inputuart_tx_en,//发送使能信号

output reg uart_txd//串口发送数据线

);

parameter SYS_CLK_FRE=50_000_000;//50M系统时钟

parameter BPS=     9_600;//波特率9600bps，可更改

localparamBPS_CNT=  SYS_CLK_FRE/BPS;//传输一位数据所需要的时钟个数

reguart_tx_en_d0;//寄存1拍

reg uart_tx_en_d1;//寄存2拍

reg tx_flag;//发送标志位

reg [7:0]  uart_data_reg;//发送数据寄存器

reg [15:0] clk_cnt;//时钟计数器

reg [3:0]  tx_cnt;//发送个数计数器

wire pos_uart_en_txd;//使能信号的上升沿

assign pos_uart_en_txd = uart_tx_en_d0 && (~uart_tx_en_d1);//捕捉使能端的上升沿信号，用来标志输出开始传输

always @(posedge sys_clk or negedge sys_rst_n)begin//开始传输使能信号打两拍，消除亚稳态

if(!sys_rst_n)begin

uart_tx_en_d0<=1'b0;

uart_tx_en_d1<=1'b0;

end

else begin

uart_tx_en_d0<=uart_tx_en;

uart_tx_en_d1<=uart_tx_en_d0;

end

end

always @(posedge sys_clk or negedge sys_rst_n)begin//捕获到使能端的上升沿信号，拉高传输开始标志位，并在第9个数据（终止位）的传输过程正中（数据比较稳定）再将传输开始标志位拉低，标志传输结束

if(!sys_rst_n)begin

tx_flag<=1'b0;

uart_data_reg<=8'd0;

end

else if(pos_uart_en_txd)begin

uart_data_reg<=uart_data;

tx_flag<=1'b1;

end

else if((tx_cnt==4'd9) && (clk_cnt==BPS_CNT/2))begin//在第9个数据（终止位）的传输过程正中（数据比较稳定）再将传输开始标志位拉低，标志传输结束

tx_flag<=1'b0;

uart_data_reg<=8'd0;

end

else begin

uart_data_reg<=uart_data_reg;

tx_flag<=tx_flag;

end

end

always @(posedge sys_clk or negedge sys_rst_n)begin//时钟每计数一个BPS_CNT（传输一位数据所需要的时钟个数），即将数据计数器加1，并清零时钟计数器

if(!sys_rst_n)begin

clk_cnt<=16'd0;

tx_cnt <= 4'd0;

end

else if(tx_flag) begin

if(clk_cnt<BPS_CNT-1)begin

clk_cnt<=clk_cnt+1'b1;

tx_cnt <=tx_cnt;

end

else begin

clk_cnt<=16'd0;

tx_cnt <=tx_cnt+1'b1;

end

end

else begin

clk_cnt<=16'd0;

tx_cnt<= 4'd0;

end

end

always @(posedge sys_clk or negedge sys_rst_n)begin//在每个数据的传输过程正中（数据比较稳定）将数据寄存器的数据赋值给数据线

if(!sys_rst_n)

uart_txd<= 1'b1;

else if(tx_flag)

case(tx_cnt)

4'd0:uart_txd<=1'b0;

4'd1:uart_txd<=uart_data_reg[0];

4'd2:uart_txd<=uart_data_reg[1];

4'd3:uart_txd<=uart_data_reg[2];

4'd4:uart_txd<=uart_data_reg[3];

4'd5:uart_txd<=uart_data_reg[4];

4'd6:uart_txd<=uart_data_reg[5];

4'd7:uart_txd<=uart_data_reg[6];

4'd8:uart_txd<=uart_data_reg[7];

4'd9:uart_txd<=1'b1;

default:;

endcase

else

uart_txd<= 1'b1;

end

endmodule
```
发送端仿真代码
```verilog
`timescale 1ns/1ns//定义时间刻度

//模块、接口定义

module tb_uart_tx();

reg sys_clk;

reg sys_rst_n;

reg [7:0]uart_data;

reg uart_tx_en;

wire  uart_txd;

//例化被测试的接收模块

uart_tx #(

.BPS(960000),//波特率9600

.SYS_CLK_FRE(50_000_000)//时钟频率50M

)

u_uart_tx(

.sys_clk(sys_clk),

.sys_rst_n(sys_rst_n),

.uart_data(uart_data),

.uart_tx_en(uart_tx_en),

.uart_txd(uart_txd)

);

localparamCNT =50_000_000/960000*20;//计算出传输每个时钟所需要的时间

initial begin//传输8位数据8'b01010101

sys_clk<=1'b0;//初始时刻定义

sys_rst_n<=1'b0;

uart_tx_en<=1'b0;

uart_data<=8'b01010101;//发送数据 01010101

#20 //系统开始工作

sys_rst_n   <=1'b1;

#(CNT/2)

uart_tx_en<=1'b1;

#20

uart_tx_en<=1'b0;

end

always begin

#10sys_clk =  ~sys_clk;//时钟20ns,50M

end

endmodule
```
top顶层代码
```verilog
module uart_top(

input sys_clk,//系统时钟

input sys_rst_n,//系统复位

input uart_rxd,//接收端口

output uart_txd//发送端口

);

parameterUART_BPS= 9_600;//波特率

parameterCLK_FREQ=50_000_000;//系统频率50M

wireuart_en_w;

wire [7:0] uart_data_w;

uart_tx#(//例化发送模块

.BPS    (UART_BPS),

.SYS_CLK_FRE(CLK_FREQ)

)

u_uart_tx(

.sys_clk(sys_clk),

.sys_rst_n    (sys_rst_n),

.uart_tx_en(uart_en_w),

.uart_data    (uart_data_w),

.uart_txd    (uart_txd)

);

uart_rx #(//例化接收模块

.BPS(UART_BPS),

.SYS_CLK_FRE(CLK_FREQ)

)

u_uart_rx(

.sys_clk(sys_clk),

.sys_rst_n    (sys_rst_n),

.uart_rxd    (uart_rxd),

.uart_rx_done    (uart_en_w),

.uart_rx_data    (uart_data_w)

);

endmodule
```
top顶层仿真代码
```verilog
`timescale 1ns/1ns//定义时间刻度

module tb_uart_top();//模块、接口定义

reg sys_clk;

reg sys_rst_n;

reg uart_rxd;

wire  uart_txd;

uart_top #(//例化被测试的接收模块

.UART_BPS(960000),//波特率9600

.CLK_FREQ(50_000_000)//时钟频率50M

)

u_uart_top(

.sys_clk(sys_clk),

.sys_rst_n(sys_rst_n),

.uart_rxd(uart_rxd),

.uart_txd(uart_txd)

);

localparamCNT=50_000_000/960000*20;//计算出传输每个时钟所需要的时间

initial begin//传输8位数据8'b01010101

sys_clk<=1'b0;//初始时刻定义

sys_rst_n<=1'b0;

uart_rxd<=1'b1;

#20 //系统开始工作

sys_rst_n<=1'b1;

#(CNT/2)

uart_rxd<=1'b0;//开始传输起始位

#CNT

uart_rxd<=1'b1;//传输最低位，第1位

#CNT

uart_rxd<=1'b0;//传输第2位

#CNT

uart_rxd<=1'b1;//传输第3位

#CNT

uart_rxd<=1'b0;//传输第4位

#CNT

uart_rxd<=1'b1;//传输第5位

#CNT

uart_rxd<=1'b0;//传输第6位

#CNT

uart_rxd<=1'b1;//传输第7位

#CNT

uart_rxd<=1'b0;//传输最高位，第8位

#CNT

uart_rxd<=1'b1;//传输终止位

end

always begin

#10sys_clk = ~sys_clk;//时钟20ns,50M

end

endmodule
```