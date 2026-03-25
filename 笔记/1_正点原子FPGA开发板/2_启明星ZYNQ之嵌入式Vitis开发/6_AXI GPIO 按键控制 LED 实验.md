AXI GPIO

---
文档查询

block design中添加AXI GPIO IP核
![|381](photo/Pasted%20image%2020250518125220.png)
IP核的双击打开后的左上角有相关手册
![|425](photo/Pasted%20image%2020250518125401.png)
![|475](photo/Pasted%20image%2020250518130748.png)
为AXI接口提供了一个通用的输入输出接口
这是一个32bit的soft ip软核ip
用于与AXI4 lite接口进行连接

什么是软核IP?
![|350](photo/Pasted%20image%2020250518132037.png)
PS里的硬核GPIO是实实在在的有硬件电路的
而AXI-GPIO在芯片里是没有现成电路的
需要在PL端用逻辑搭一个GPIO硬件电路
这种事软核IP

为什么叫AXI-GPIO？
在PL端搭建的GPIO通过AXI接口与PS连用

PS-PL接口分为功能性接口和配置接口
![|450](photo/Pasted%20image%2020250518132320.png)
功能接口AXI互联又分为ACP、HP和GP接口
![|425](photo/Pasted%20image%2020250518132458.png)
AXI-GPIO使用的是AXI-GP接口



实验任务：用AXI-GP接口，在PL中搭建AXI-GPIO软核，使用中断机制(来自PL的中断)，实现PL按键控制PS的LED


系统框图
![|475](photo/Pasted%20image%2020250518125130.png)
==AXI 互联 IP==（ AXI Interconnect）用于连接==AXI存储器映射==（ memory-mapped）的主器件和从器件。
通用中断控制器（ GIC） 用于管理来自 PS 或者 PL 的中断， 并把这些中断发送到 CPU。
![|500](photo/Pasted%20image%2020250518134003.png)
![|500](photo/Pasted%20image%2020250518134105.png)

---
硬件设计
添加ZYNQ_PS端IP。本次实验默认的这些接口都需要
![|400](photo/Pasted%20image%2020250518134616.png)
M_AXI_GP0：
M_AXI_GP0_ACLK：AXI时钟信号
FCLK_CLK0：PS端输出给PL的时钟信号
FCLK_RESET0_N：PS输出给PL的复位信号

进入配置：
配UART 0
![|500](photo/Pasted%20image%2020250518135021.png)
配DDR3
![|500](photo/Pasted%20image%2020250518135105.png)
配MIO（PS端的LED）（硬核）
![|500](photo/Pasted%20image%2020250518135419.png)
配置ZYNQ PS完成

添加AXI-GPIO IP核并配置
配置选项在pg114文档中有介绍
![|250](photo/Pasted%20image%2020250518140358.png)
提供了一个通用输入输出接口到AXI4-Lite接口
可配置成单通道or双通道，每个通道可分别配置
AXI-GPIO可通过使能or去使能三台缓冲器进行动态配置（三态缓冲器决定IO是输出or输入）
当transition在输入引脚发生的时候可产生中断（transition：转换，电平状态改变）

![|475](photo/Pasted%20image%2020250518140640.png)

AXI-GPIO模块框图
IP端口介绍：
![|400](photo/Pasted%20image%2020250518141616.png)
![|500](photo/Pasted%20image%2020250518143642.png)
![|500](photo/Pasted%20image%2020250518143814.png)
![|500](photo/Pasted%20image%2020250518144757.png)
![|500](photo/Pasted%20image%2020250518145310.png)
IP寄存器空间介绍
![|500](photo/Pasted%20image%2020250518145715.png)
![|500](photo/Pasted%20image%2020250518145920.png)
![|500](photo/Pasted%20image%2020250518150114.png)
中断功能
![|500](photo/Pasted%20image%2020250518150228.png)
编程顺序：

使能中断
![|500](photo/Pasted%20image%2020250518150851.png)
不使用中断功能，配成输入
![|500](photo/Pasted%20image%2020250518151046.png)
配成输出
![|500](photo/Pasted%20image%2020250518151146.png)

---
IP核配置：
![|475](photo/Pasted%20image%2020250518151955.png)
模块自动连接+模块间自动连接
![|400](photo/Pasted%20image%2020250518152617.png)
![|400](photo/Pasted%20image%2020250518152658.png)
工具帮我们自动添加了两个IP核
![|675](photo/Pasted%20image%2020250518153108.png)
- AXI Interconnect IP 核用于将一个（ 或多个） AXI 存储器映射的主器件连接到一个（ 或多个） 存储器映射的从器件。 在这里我们解释一下这个术语——==互联==（ Interconnect）： 互联实际上是一个==开关==，它==管理并指挥所连接的 AXI 接口之间的通信==。 图中橙色高亮的两组信号线表明， 在这个设计中， AXI 互联实现了由主器件（ ZYNQ7 PS）到从器件（ AXI GPIO）==一对一==的连接。它也可实现==一对多==、==多对一==以及==多对多==的 AXI 接口连接。
![|725](photo/Pasted%20image%2020250518153741.png)
- Processor System Reset IP 核==为整个处理器系统提供复位信号==。它会==处理==输入端的==各种复位条件==，并在==输出==端产生相应的==复位信号==。 在本次实验中， Processor System Reset 接收 ZYNQ7 PS 输出的异步复位信号FCLK_RESET0_N， 然后产生一个同步到 PL 时钟源 FCLK_CLK0 的复位信号 peripheral_aresetn，用于复位PL 端的各外设模块

时钟信号:
![](photo/Pasted%20image%2020250518153835.png)
![|500](photo/Pasted%20image%2020250518154146.png)
PL 端所有外设模块的时钟接口都连接到了 ZYNQ7 PS 输出的时钟信号FCLK_CLK0 上(50Hz)
该时钟同样连接到了 PS 端 M_AXI_GP0_ACLK 端口，作为 AXI GP 接口的全局时钟信号

ZYNQ7 PS 模块中也要打开中断功能，打开从PL到PS的中断信号
![|500](photo/Pasted%20image%2020250518154347.png)
ZYNQ7 PS 模块的中断接口 IRQ_F2P 没有自动连接， 需要手动连接
![|650](photo/Pasted%20image%2020250518154527.png)
将连接到PL端的端口改名，方便PL端使用
![|500](photo/Pasted%20image%2020250518154645.png)
封装之后看代码发现系统会自动帮我们创建三态缓冲器
![|325](photo/Pasted%20image%2020250518155249.png)
![|625](photo/Pasted%20image%2020250518155232.png)
分配引脚，PL按键
![|500](photo/Pasted%20image%2020250518155516.png)
生成bit流
导出到SDK

---
软件部分
新建空例程后板级支持包里支持axi-gpio
![|575](photo/Pasted%20image%2020250518160121.png)
导入中断模式示例
![|550](photo/Pasted%20image%2020250518163756.png)
按照示例编写代码


AXI-GPIO中断号
AXI-GPIO实际是PL到PS的中断
一共16个中断ID
只使用了1个，中断号就是61
![|425](photo/Pasted%20image%2020250518180048.png)
ZYNQ_PS配置也能看到中断号
![|450](photo/Pasted%20image%2020250518180220.png)
中断类型：高有效
![|475](photo/Pasted%20image%2020250518195555.png)
![|475](photo/Pasted%20image%2020250518195714.png)
按下亮，释放灭
按一次按键中断两次（按下+释放）：是因为电平变化检测到中断
现象与预期不符
看编程顺序，还需要读一下状态
![|500](photo/Pasted%20image%2020250518202526.png)
加个读判断就可以了，虽然还是两次中断，但是led改变状态




```C
#include "xparameters.h"
#include "xgpiops.h"			//ps端的gpio
#include "xgpio.h"				//axi的gpio
#include "xscugic.h"
#include "xil_exception.h"
#include "xplatform_info.h"
#include <xil_printf.h>
#include "sleep.h"

//以下常量映射到xparameters.h文件
#define GPIO_DEVICE_ID      XPAR_XGPIOPS_0_DEVICE_ID      	//PS  GPIO  器件ID
#define INTC_DEVICE_ID      XPAR_SCUGIC_SINGLE_DEVICE_ID  	//中断控制器 器件ID
#define AXI_GPIO_ID			XPAR_GPIO_0_DEVICE_ID			//AXI GPIO  器件ID

//AXI GPIO中断号61
#define AXI_GPIO_INTERRUPT_ID	XPAR_FABRIC_AXI_GPIO_0_IP2INTC_IRPT_INTR	//AXI GPIO 中断ID

//核心板上PS端LED
#define MIO0_LED  			0
//AXI GPIO 通道1
#define GPIO_CHANNEL1		1

//定义了两个指针类型变量
XGpioPs_Config *ConfigPtr;     	//PS GPIO	配置信息
XScuGic_Config *IntcConfig;     //中断控制器	配置信息

XGpioPs Gpio;   				//PS  GPIO		驱动实例
XScuGic Intc;   				//通用中断控制器	驱动实例
XGpio 	AXI_Gpio;				//AXI GPIO      驱动实例

void setup_interrupt_system(XScuGic *gic_ins_ptr, XGpio *AXI_Gpio, u16 AXI_GpioIntrId);	//设置中断系统
void intr_handler();			//定义中断处理函数

u32 key_press = 0 ;  			//KEY按键按下的标志
u32 key_val   = 0 ;    			//LED初始值为0

int main()
{
    xil_printf("\nAXI Gpio interrupt test \r\n");

    //*****查找PS GPIO配置，并初始化*******************************************************************
    ConfigPtr = XGpioPs_LookupConfig(GPIO_DEVICE_ID);    			//根据器件ID查找配置信息
    XGpioPs_CfgInitialize(&Gpio, ConfigPtr, ConfigPtr->BaseAddr);	//初始化Gpio driver

    //*****对AXI GPIO初始化***************************************************************************
    XGpio_Initialize(&AXI_Gpio, AXI_GPIO_ID);						//查找配置信息+初始化

    //*****设置PS GPIO为输出并打开输出使能*************************************************************
    XGpioPs_SetDirectionPin(&Gpio, MIO0_LED, 1);					//设置PS端LED方向为输出
    XGpioPs_SetOutputEnablePin(&Gpio, MIO0_LED, 1);					//使能设置LED所连接的MIO引脚输出

    //将key_val值写入MIO0_LED
    XGpioPs_WritePin(&Gpio, MIO0_LED, key_val);

    //*****对AXI GPIO进行配置**************************************************************************
    XGpio_SetDataDirection(&AXI_Gpio, GPIO_CHANNEL1, 0x00000001);	//端口IO设置为输入

    //*****设置中断系统************************************************************************************
    setup_interrupt_system(&Intc, &AXI_Gpio, AXI_GPIO_INTERRUPT_ID);    //建立中断,出现错误则打印信息并退出

    //*****判断按键是否按下*********************************************************************************
    while (1) {
        if (key_press) {
        	//判断当前按键的状态，如果是按键按下，就改变LED状态
        	if(XGpio_DiscreteRead(&AXI_Gpio, GPIO_CHANNEL1) == 0)
        		key_val = ~key_val;

            key_press = 0;

            XGpio_InterruptClear(&AXI_Gpio, 0x00000001);	//清除之前的中断

            XGpioPs_WritePin(&Gpio, MIO0_LED, key_val);		//将key_val值写入MIO0_LED

            usleep(20000);									//延时消抖

            XGpio_InterruptEnable(&AXI_Gpio, 0x00000001);	//重新打开通道1中断使能
        }
    }
    return 0;
}


//建立中断系统
//  @param   中断控制器 驱动实例
//  @param   AXI GPIO  驱动实例
//  @param   AXIGPIO   中断ID
void setup_interrupt_system(XScuGic *gic_ins_ptr, XGpio *AXI_Gpio, u16 AXI_GpioIntrId)
{
    //查找GIC中断控制器配置信息，并初始化中断控制器驱动
    IntcConfig = XScuGic_LookupConfig(INTC_DEVICE_ID);
    XScuGic_CfgInitialize(gic_ins_ptr, IntcConfig, IntcConfig->CpuBaseAddress);

    //初始化arm处理器异常句柄
    Xil_ExceptionEnable();
    //来给IRQ异常注册处理程序
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
            (Xil_ExceptionHandler) XScuGic_InterruptHandler, gic_ins_ptr);
    //使能处理器中断
    Xil_ExceptionEnableMask(XIL_EXCEPTION_IRQ);

    //关联中断处理函数
    XScuGic_Connect(gic_ins_ptr, AXI_GPIO_INTERRUPT_ID,
    		(Xil_ExceptionHandler) intr_handler,
			(void *)AXI_Gpio);

    //使能AXI Gpio器件的中断
    XScuGic_Enable(gic_ins_ptr, AXI_GPIO_INTERRUPT_ID);

    //0xA0，指定中断源优先级；0x01中断类型为高有效，电平敏感类型
	XScuGic_SetPriorityTriggerType(gic_ins_ptr, AXI_GPIO_ID, 0xA0, 0x01);

    //打开AXI GPIO IP的中断使能
    XGpio_InterruptGlobalEnable(AXI_Gpio);				//打开全局中断使能
    XGpio_InterruptEnable(AXI_Gpio, 0x00000001);		//打开通道中的信号对应的中断使能
}

//中断处理函数
void intr_handler()
{
	printf("interrupt detected!\n\r");
    key_press = 1;

    //关闭通道1中断使能信号
    XGpio_InterruptDisable(&AXI_Gpio, 0x00000001);
}

```











