创建一个带有AXI接口的IP核，该IP核通过AXI协议实现PS和PL的数据通信
AXI 协议是一种高性能、高带宽、低延迟的片内总线
![|600](assets/Pasted%20image%2020250519110011.png)
创建新IP核
![|250](assets/Pasted%20image%2020250519110119.png)
开发板型号在使用ip时会重新指定，所以此处Part默认即可
![|575](assets/Pasted%20image%2020250519110518.png)
创建封装
选择封装 IP 或者创建一个带 AXI4 接口的 IP 核
我们这里选择创建一个带 AXI 接口的 IP核
选中“Creat a new AXI4 peripheral”
![|600](assets/Pasted%20image%2020250519111854.png)
![|600](assets/Pasted%20image%2020250519111939.png)
对 AXI 接口进行设置
- Name（名称）：S0_AXI。
- Interface Tpye（接口类型）：三种接口类型，Lite、Full、Stream
	1. AXI4-Lite 接口是简化版的 AXI4 接口， 用于较少数据量的存储映射通信； 
	2. AXI4-Full 接口是高性能存储映射接口，用于较多数据量的存储映射通信； 
	3. AXI4-Stream 用于高速数据流传输，非存储映射接口。
- Interface Mode（接口模式）：接口模式有 Slave（从机）和 Master（主机）两种模式可选， AXI 协议是主机和从机通过“握手”的方式建立连接，这里选择默认的 Slave 接口模式。
- Data Width（数据宽度）：数据位宽保持默认，即 32 位位宽。
- Memory Size（存储器大小）： 在 AXI4-Lite 接口模式下，该选项不可设置。
- Number of Registers（寄存器数量）：用于配置 PL LED 呼吸灯寄存器的数量，这里保持默认。
![|550](assets/Pasted%20image%2020250519113246.png)
保持默认，即将 IP 添加至 IP 库中
![|575](assets/Pasted%20image%2020250519113330.png)
在IP catalog中成功添加了AXI IP
![|525](assets/Pasted%20image%2020250519113531.png)
右键编辑IP核，即打开IP的工程
![|600](assets/Pasted%20image%2020250519113621.png)
添加所需代码，IP核里都标注好了user应该在哪里写代码
![|375](assets/Pasted%20image%2020250519114400.png)
![|475](assets/Pasted%20image%2020250519114616.png)
增加IP核例化端口
![|500](assets/Pasted%20image%2020250519113951.png)
breath_led_ip_v1_0_S0_AXI 模块实现了 AXI4 协议下的读写寄存器的功能，
我们只需要对该模块稍作修改，
即可实现控制 PL LED 呼吸灯的功能。
向寄存器中写入数据和读出数据的部分代码如下
![|425](assets/Pasted%20image%2020250519114420.png)
![|525](assets/Pasted%20image%2020250519114148.png)
![|500](assets/Pasted%20image%2020250519114200.png)
在创建和封装 IP 核向导中，我们总共定义了 4 个寄存器，
代码中的 slv_reg0 至 slv_reg3 是寄存器地址0 至寄存器地址 3 对应的数据，
通过例化呼吸灯模块，将寄存器地址对应的数据和呼吸灯模块的控制端口相连接，
即可实现对呼吸灯的控制
再次添加代码：
![|575](assets/Pasted%20image%2020250519114547.png)
例化 breath_led.v文件
![|600](assets/Pasted%20image%2020250519114834.png)
代码中的 slv_reg0 和 slv_reg1 是寄存器地址 0 和寄存器地址 1 对应的数据，
通过
寄存器地址 0 对应的数据来控制呼吸灯的使能（sw_ctrl），
寄存器地址 1 对应数据的最高位控制呼吸灯频率的设置有效信号（set_en），
寄存器地址 1 对应数据的低 10 位控制呼吸灯频率的步长（set_freq_step）。

保存后，缺少子模块，把之前做过的.v移植过来即可
![|375](assets/Pasted%20image%2020250519115206.png)
添加创建源文件
![|350](assets/Pasted%20image%2020250519115353.png)
写个呼吸灯的代码接口对好了就ok了
![|375](assets/Pasted%20image%2020250519120143.png)
代码无误后综合编译
![|375](assets/Pasted%20image%2020250519120340.png)
设置 IP 封装，将界面切换至 Package IP，
如果不小心关闭的话，可以通过 IP-XACT界面下的 component.xml 重新打开，
![|700](assets/Pasted%20image%2020250519120451.png)
Categories 选项下的“ +”按钮可用来修改 IP 的分类（此处不改）
![|400](assets/Pasted%20image%2020250519120559.png)
Compatibility，修改该 IP 核支持的器件
![|575](assets/Pasted%20image%2020250519120645.png)
Life-cycle 表明该 IP 核当前的产品生命周期，选择“ Pre-Production”
![|300](assets/Pasted%20image%2020250519120732.png)


Merge Changes三板斧，点就行
![|625](assets/Pasted%20image%2020250519120906.png)
![|650](assets/Pasted%20image%2020250519120946.png)
![|650](assets/Pasted%20image%2020250519121119.png)
![|650](assets/Pasted%20image%2020250519121148.png)

这是对代码中parameter参数的设定
![|550](assets/Pasted%20image%2020250519121253.png)
![|375](assets/Pasted%20image%2020250519121410.png)
参数拖动到page0里
![|450](assets/Pasted%20image%2020250519121541.png)
更新总结界面
![|625](assets/Pasted%20image%2020250519121615.png)
封装完成


Vivado软件会自动生成.c 和.h 文件，方便在 SDK 软件中对 IP 核进行操作
![|700](assets/Pasted%20image%2020250519121754.png)

创建工程，把自定义ip核添加到此工程ip库中
![|575](assets/Pasted%20image%2020250519122216.png)
![|600](assets/Pasted%20image%2020250519122255.png)
![|450](assets/Pasted%20image%2020250519122338.png)
![|525](assets/Pasted%20image%2020250519122433.png)



创建 Processing System
保留 FCLK_CLK0、 FCLK_RESET0_N 和M_AXI_GP0_ACLK 接口，
添加 UART 控制器（ MIO14 和 MIO15）
修改 DDR3 的存储器类型型号，
![|425](assets/Pasted%20image%2020250519122759.png)
添加Breath LED IP核
![|400](assets/Pasted%20image%2020250519122845.png)
查看可配置参数，与设定一致
![|575](assets/Pasted%20image%2020250519122913.png)
“Run Connection Automation”来自动连线
![|675](assets/Pasted%20image%2020250519123009.png)
增加LED引脚并改名
![|525](assets/Pasted%20image%2020250519123040.png)
最终原理图
![|675](assets/Pasted%20image%2020250519123124.png)
生成顶层 HDL 模块
添加xdc
![|650](assets/Pasted%20image%2020250519145522.png)
生成硬件，导出硬件Include bitstream
打开SDK，创建空例程，新建main函数
Xilinx → Program FPGA → Program
Run As → Lunch on Hardware
Led呼吸并切换频率

















```C
/*
 * main.c
 *
 *  Created on: 2025年5月19日
 *      Author: 13172
 */
#include "stdio.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "breath_led_ip.h"
#include "xil_io.h"
#include "sleep.h"

#define LED_IP_BASEADDR XPAR_BREATH_LED_IP_0_S0_AXI_BASEADDR //LED IP 基地址
#define LED_IP_REG0 BREATH_LED_IP_S0_AXI_SLV_REG0_OFFSET //LED IP 寄存器地址 0
#define LED_IP_REG1 BREATH_LED_IP_S0_AXI_SLV_REG1_OFFSET //LED IP 寄存器地址 1

//main 函数
int main() {
	int freq_flag; //定义频率状态，用于循环改变呼吸灯的呼吸频率
	int led_state; //定义 LED 灯的状态

	xil_printf("LED User IP Test!\n");
	while(1) {
//根据 freq_flag 的标志位,切换呼吸灯的频率
		if(freq_flag == 0) {
			BREATH_LED_IP_mWriteReg(LED_IP_BASEADDR,LED_IP_REG1,0x800000ef);
			freq_flag = 1;
		} else {
			BREATH_LED_IP_mWriteReg(LED_IP_BASEADDR,LED_IP_REG1,0x8000002f);
			freq_flag = 0;
		}
//获取 LED 当前开关状态 1:打开 0:关闭
		led_state = BREATH_LED_IP_mReadReg(LED_IP_BASEADDR,LED_IP_REG0);
//如果开关关闭,打开呼吸灯
		if(led_state == 0) {
			BREATH_LED_IP_mWriteReg (LED_IP_BASEADDR, LED_IP_REG0, 1);
			xil_printf("Breath LED ON\n");
		}
		sleep(5);
//获取 LED 当前开关状态 1:打开 0:关闭
		led_state = BREATH_LED_IP_mReadReg(LED_IP_BASEADDR,LED_IP_REG0);
//如果开关打开,关闭呼吸灯
		if(led_state == 1) {
			BREATH_LED_IP_mWriteReg (LED_IP_BASEADDR, LED_IP_REG0, 0);
			xil_printf("Breath LED OFF\n");
		}
		sleep(1);
	}
}
```











































































