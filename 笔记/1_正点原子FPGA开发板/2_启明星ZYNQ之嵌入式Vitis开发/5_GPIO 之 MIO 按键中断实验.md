**任务**

任务：使用GPIO的MIO口控制LED灯亮灭

硬件连接：MIO bank0上的A7和C8通过510Ω电阻与外设LED相连，阳极连在ZYNQ的IO口，阴极接地，510Ω电阻起到限流作用
![](assets/Pasted%20image%2020250526074001.png)
![](assets/Pasted%20image%2020250526074015.png)

**基础知识**

PS上的GPIO口分为MIO和EMIO：

 MIO与外设相连，ZYNQ7000系列有54个MIO，BANK0上有32个引脚，BANK1上有22个引脚。

 EMIO：BANK2和BANK3，是扩展的MIO
![](assets/Pasted%20image%2020250526074023.png)

MIO的分配可任意分配，但对外设的引脚又有所约束，下图为MIO一览表
![](assets/Pasted%20image%2020250526074029.png)

**点灯**

系统框图

![](assets/Pasted%20image%2020250526074034.png)
该程序需要用到MIO接口，所以需要把PS IP核的GPIO MIO接口打开
![](assets/Pasted%20image%2020250526074346.png)
在vitis里需要打开板级支持包，启用GIPO的驱动程序
![](assets/Pasted%20image%2020250526074038.png)


xgpiops_intr_example 是关于中断方式的示例

xgpiops_polled_example是关于轮询的示列，此处未用到中断，选该选项即可
![](assets/Pasted%20image%2020250526074044.png)


新增文件即为刚添加的例程，该程序里有对MIO的调用，可利用该程序修改接口位置实现连接LED
![](assets/Pasted%20image%2020250526074049.png)


修改.c文件中的引脚号，与板子LED引脚对应
![](assets/Pasted%20image%2020250526074052.png)


上板测试，LED灯闪。

**手写驱动程序**

程序完整版见文末

**头文件**
![](assets/Pasted%20image%2020250526074056.png)


 xparameters.h：包含硬件配置信息，如设备ID、基地址等。

 xstatus.h：定义状态码，如XST_SUCCESS和XST_FAILURE。

 xil_printf.h：提供简单的打印函数print()，用于调试输出。

 xgpiops.h：提供PS部分GPIO的控制函数。

 sleep.h：提供延时函数sleep()。
![](assets/Pasted%20image%2020250526074101.png)


GPIO的设备ID，从xparameters.h中获取
![](assets/Pasted%20image%2020250526074105.png)


XGpioPs是Xilinx提供的GPIO驱动结构体，用于管理GPIO状态和配置
![](assets/Pasted%20image%2020250526074111.png)


XGpioPs_LookupConfig：根据设备ID查找硬件配置信息。
XGpioPs_CfgInitialize：初始化GPIO驱动，传入配置信息和基地址。

如果初始化失败，返回XST_FAILURE。
![](assets/Pasted%20image%2020250526074116.png)

XGpioPs_SetDirectionPin：设置引脚方向，1为输出，0为输入。

XGpioPs_SetOutputEnablePin：使能引脚输出，1为使能。
![](assets/Pasted%20image%2020250526074119.png)
![]() 

XGpioPs_WritePin：向引脚写入数据，0为低电平，1为高电平。

sleep(1)：延时1秒。循环中交替点亮和熄灭两个LED，实现闪烁效果。

MIO的引脚配置见电路原理图
![](assets/Pasted%20image%2020250526074122.png)
![]() 
![](assets/Pasted%20image%2020250526074129.png)
![]() 
![](assets/Pasted%20image%2020250526074132.png)
 

驱动LED完整程序

```C
#include "xparameters.h" //器件参数信息
#include "xstatus.h" //包含 XST_FAILURE 和 XST_SUCCESS 的宏定义
#include "xil_printf.h" //包含 print()函数
#include "xgpiops.h" //包含 PS GPIO 的函数
#include "sleep.h" //包含 sleep()函数
//宏定义 GPIO_DEVICE_ID
#define GPIO_DEVICE_ID XPAR_XGPIOPS_0_BASEADDR
//连接到 MIO 的 LED
#define MIOLED0 1 //连接到 MIO1
#define MIOLED1 15 //连接到 MIO15
XGpioPs Gpio; // GPIO 设备的驱动程序实例

int main()

{
    int Status;
    XGpioPs_Config *ConfigPtr;

    print("MIO Test! \n\r");
    ConfigPtr = XGpioPs_LookupConfig(GPIO_DEVICE_ID);
    Status = XGpioPs_CfgInitialize(&Gpio, ConfigPtr,
                                   ConfigPtr->BaseAddr);

    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

//设置指定引脚的方向：0 输入，1 输出
    XGpioPs_SetDirectionPin(&Gpio, MIOLED0, 1);
    XGpioPs_SetDirectionPin(&Gpio, MIOLED1, 1);

//使能指定引脚输出：0 禁止输出使能，1 使能输出
    XGpioPs_SetOutputEnablePin(&Gpio, MIOLED0, 1);
    XGpioPs_SetOutputEnablePin(&Gpio, MIOLED1, 1);

    while (1)

    {
        XGpioPs_WritePin(&Gpio, MIOLED0, 0x0); //向指定引脚写入数据：0 或 1
        XGpioPs_WritePin(&Gpio, MIOLED1, 0x0);
        sleep(1); //延时 1 秒
        XGpioPs_WritePin(&Gpio, MIOLED0, 0x1);
        XGpioPs_WritePin(&Gpio, MIOLED1, 0x1);
        sleep(1);
    }
    return XST_SUCCESS;

}
```