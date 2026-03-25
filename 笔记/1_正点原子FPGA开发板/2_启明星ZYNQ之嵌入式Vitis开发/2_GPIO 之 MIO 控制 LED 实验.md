![|350](assets/Pasted%20image%2020250517190255.png)
54 个 MIO + 64 个 EMIO


MIO 一览表
![](assets/Pasted%20image%2020250517190501.png)
![](assets/Pasted%20image%2020250517191300.png)
![](assets/Pasted%20image%2020250518085611.png)
左边的一列是寄存器，上半部分是关于中断的

- DATA_RO：数据只读寄存器。通过该寄存器能够观察器件引脚上的值。如果 GPIO 信号配置为输出，则通常会反映输出上驱动的值，写入此寄存器将被忽略。
- DATA：数据寄存器。该寄存器控制 GPIO 信号配置为输出时要输出的值。该寄存器的所有 32 位都是一次写入的。读取该寄存器返回写入 DATA 或 MASK_DATA_ {LSW， MSW}的先前值，它不会返回器件引脚上的当前值。
- MASK_DATA_LSW 和 MASK_DATA_MSW ：数据掩码寄存器，该寄存器使软件能够有选择地一次更改所需的的输出值。可以写入最多 16 位的任意组合， MASK_DATA_LSW 控制 Bank 的低 16 位， MASK_DATA_MSW 控制高 16 位。未写入的那些位保持不变并保持其先前的值。读取该寄存器返回写入DATA 或 MASK_DATA_ {LSW， MSW}的先前值;它不会返回器件引脚上的当前值。该寄存器避免了对未更改位的读-修改-写序列的需要。
- DIRM 是方向模式寄存器，用于控制 I/O 引脚是用作输入还是输出。当 DIRM [x] == 0 时，输出驱动器被禁用，该引脚作为输入引脚使用。
- OEN 是使能输出寄存器。将 I/O 配置为输出时，该寄存器控制是否启用输出。禁用输出时，引脚为 3态。当 OEN [x] == 0 时，输出被禁用。

详细参考 ug585 手册的 Appx.B:Register Details 中的 General Purpose I/O (gpio)一节
程序中操作 MIO 时直接调用 Xilinx 官方提供的函数即可

MIO 信号对 PL 部分是透明的，所以对 MIO 的操作是纯 PS 的操作
每个 GPIO都可独立动态编程为输入、输出或中断检测
MIO7 和 8 只能做为输出 IO 使用



任务：使用 GPIO 通过 MIO 控制 PS 端 LED 的亮灭


系统框图：
![|500](assets/Pasted%20image%2020250518090222.png)


step1：创建 Vivado 工程
step2：使用 IP Integrator 创建 Processing System
基于最小系统进行修改
![|408](assets/Pasted%20image%2020250518090609.png)
启明星开发板上的 Bank1 即原理图中的 BANK501 为 1.8V
打开GPIO_MIO接口
![|600](assets/Pasted%20image%2020250518090743.png)
将使用到的5 个 GPIO_MIO 连接到外设 LED 和 KEY 上。
这些 GPIO_MIO 当作 GPIO 使用来驱动外设 LED 和 KEY。
这些引脚都是PS端的，不需要在 PL 中进行引脚位置约束
![|500](assets/Pasted%20image%2020250518090948.png)

step3：生成顶层 HDL

![|625](assets/Pasted%20image%2020250518091121.png)
![|475](assets/Pasted%20image%2020250518091215.png)
创建顶层 HDL Wrapper
![](assets/Pasted%20image%2020250518091244.png)
未用到 PL 部分，所以无需生成 Bitstream 文件
导出硬件
![](assets/Pasted%20image%2020250518091336.png)

软件设计
创建工程，选择Empty Application模板
可以看到 SDK 创建了一个 gpio_mio 目录和 gpio_mio_bsp 目录
打开 gpio_mio_bsp 目录下的system.mss 文件，找到 ps7_gpio_0
![|650](assets/Pasted%20image%2020250518091752.png)
导入示例
![|650](assets/Pasted%20image%2020250518091916.png)
- xgpiops_intr_example.c 包含有关如何直接使用 XGpiops 驱动程序的示例。此示例显示了中断模式下驱动程序的用法，并使用 GPIO 的中断功能检测按钮事件，根据输入控制 LED 输出
- xgpiops_polled_example.c同样包含有关如何直接使用 XGpiops 驱动程序的示例。此示例提供了用于读取/写入各个引脚的 API 的用法
将模板172行output_pin改成0下载到开发板即可看到led闪烁
![|500](assets/Pasted%20image%2020250518092357.png)
根据模板继续更改代码
在Empty Application模板中添加main.c文件
![|500](assets/Pasted%20image%2020250518092738.png)
![|500](assets/Pasted%20image%2020250518092845.png)

```C
#include "xparameters.h" //器件参数信息
#include "xstatus.h" //包含 XST_FAILURE 和 XST_SUCCESS 的宏定义
#include "xil_printf.h" //包含 print()函数
#include "xgpiops.h" //包含 PS GPIO 的函数声明
#include "sleep.h" //包含 sleep()函数

//宏定义 GPIO_DEVICE_ID
#define GPIO_DEVICE_ID XPAR_XGPIOPS_0_DEVICE_ID
//连接到 MIO 的 LED
#define MIOLED0 7 //连接到 MIO7
#define MIOLED1 8 //连接到 MIO8
#define MIOLED2 0 //连接到 MIO0

XGpioPs Gpio; // GPIO 设备的驱动程序实例

int main() {
	int Status;
	XGpioPs_Config *ConfigPtr;

	print("MIO Test! \n\r");
	ConfigPtr = XGpioPs_LookupConfig(GPIO_DEVICE_ID);
	Status = XGpioPs_CfgInitialize(&Gpio, ConfigPtr,
	                               ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
//设置指定引脚的方向： 0 输入， 1 输出
	XGpioPs_SetDirectionPin(&Gpio, MIOLED0, 1);
	XGpioPs_SetDirectionPin(&Gpio, MIOLED1, 1);
	XGpioPs_SetDirectionPin(&Gpio, MIOLED2, 1);
//使能指定引脚输出： 0 禁止输出使能， 1 使能输出
	XGpioPs_SetOutputEnablePin(&Gpio, MIOLED0, 1);
	XGpioPs_SetOutputEnablePin(&Gpio, MIOLED1, 1);
	XGpioPs_SetOutputEnablePin(&Gpio, MIOLED2, 1);

	while (1) {
		XGpioPs_WritePin(&Gpio, MIOLED0, 0x0); //向指定引脚写入数据： 0 或 1
		XGpioPs_WritePin(&Gpio, MIOLED1, 0x0);
		XGpioPs_WritePin(&Gpio, MIOLED2, 0x0);
		sleep(1); //延时 1 秒
		XGpioPs_WritePin(&Gpio, MIOLED0, 0x1);
		XGpioPs_WritePin(&Gpio, MIOLED1, 0x1);
		XGpioPs_WritePin(&Gpio, MIOLED2, 0x1);
		sleep(1);
	}
	return XST_SUCCESS;
}
```

GPIO_DEVICE_ID是GPIO器件号0
MIOLED0其值为 7，因为其连接到 PS 的 MIO7

获取 GPIO 的 ID 和基址信息并初始化其配置，以及判断是否初始化成功
```kotlin
	ConfigPtr = XGpioPs_LookupConfig(GPIO_DEVICE_ID);
	Status = XGpioPs_CfgInitialize(&Gpio, ConfigPtr,
	                               ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
```
XGpioPs_SetDirectionPin是设置 GPIO 的方向（输入还是输出）函数
XGpioPs_SetOutputEnablePin是使能输出函数
```scss
//设置指定引脚的方向： 0 输入， 1 输出
	XGpioPs_SetDirectionPin(&Gpio, MIOLED0, 1);
	XGpioPs_SetDirectionPin(&Gpio, MIOLED1, 1);
	XGpioPs_SetDirectionPin(&Gpio, MIOLED2, 1);
//使能指定引脚输出： 0 禁止输出使能， 1 使能输出
	XGpioPs_SetOutputEnablePin(&Gpio, MIOLED0, 1);
	XGpioPs_SetOutputEnablePin(&Gpio, MIOLED1, 1);
	XGpioPs_SetOutputEnablePin(&Gpio, MIOLED2, 1);
```
XGpioPs_WritePin是向指定 GPIO 引脚写入数据的函数
```scss
XGpioPs_WritePin(&Gpio, MIOLED0, 0x0); //向指定引脚写入数据： 0 或 1
```

编译工程。
保存 main.c 文件，我们打开 Binaries 目录，看到已经有 elf 文件，说明工程已经编译过了
![|275](assets/Pasted%20image%2020250518095743.png)
手动编译操作
![|300](assets/Pasted%20image%2020250518095836.png)

使用run configurations下载
![|575](assets/Pasted%20image%2020250518100120.png)
一定要选对elf文件和硬件平台
![|650](assets/Pasted%20image%2020250518100325.png)
该操作会让程序在DDR3中运行

灯闪实验完成













