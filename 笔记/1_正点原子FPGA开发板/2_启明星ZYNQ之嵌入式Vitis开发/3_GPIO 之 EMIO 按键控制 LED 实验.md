**什么是EMIO呢？为什么要用EMIO呢？**
 PS通过扩展的MIO连接外部设备，EMIO使用了PL的I/O资源
 当PS需要扩展超过54个引脚的时候可以使用EMIO，也可以用它来连接PL中实现的IP模块

**下图为GPIO的框图**

 BANK0+BANK1共54个信号通过MIO连接到器件引脚上
 BANK2+BANK3共64个信号通过EMIO连接到PL端
 ![](assets/Pasted%20image%2020250526082646.png)

**EMIO的连接方式：**

 大多数情况下，PS端经由EMIO引出的接口会直接连接到PL端的器件引脚上，通过IO管脚约束来指定所连接的PL引脚位置。该方法可为PS端实现额外的64个输入引脚或64个带有输出使能的输出引脚。
 EMIO还有另一种方式，用于连接PL内实现的功能模块IP核，此时PL端的IP作为PS端的一个外部设备来使用。
![](assets/Pasted%20image%2020250526082654.png)

**任务**

使用开发板上的PL和PS按键控制PS端的LED灯的亮灭，按键按下时点亮，释放后熄灭。

如何使用MIO的输入

参考ug585文档
首先要配置GPIO：把GPIO方向设为输入，即DIRM_0[10]寄存器置零
![](assets/Pasted%20image%2020250526082703.png)
![](assets/Pasted%20image%2020250526082707.png)

**硬件设计**

下图为系统框图
![](assets/Pasted%20image%2020250526082711.png)

打开vivado创建工程
创建Block Design
创建Processsing System模块，下图为vivado工具界面功能介绍
![](assets/Pasted%20image%2020250526082716.png)

**硬件上的注意事项**

HardWare中的PS IP核添加EMIO
![](assets/Pasted%20image%2020250526082720.png)

根据所需端口数量调整EMIO生成的数量，最大为64
![](assets/Pasted%20image%2020250526082727.png)

通过Make External添加端口接口
![](assets/Pasted%20image%2020250526082731.png)
![](assets/Pasted%20image%2020250526082734.png)

I/O port配置：可以在引脚配置中找到该EMIO口的端口，将其与PL中的L20相连，即可用PS通过EMIO与PL该端口通信
![](assets/Pasted%20image%2020250526082737.png)
![](assets/Pasted%20image%2020250526082739.png)
![](assets/Pasted%20image%2020250526082742.png)
![](assets/Pasted%20image%2020250526082744.png)

因为该工程用到了PL资源，所以在相比于MIO那个工程，生成硬件平台Hardware时需要连带Bit文件一起生成
![](assets/Pasted%20image%2020250526082749.png)

vitis：

创建platform
创建工程文件
板级验证

**软件设计**
```C
#include "stdio.h"
#include "xparameters.h"
#include "xgpiops.h"
#define GPIOPS_ID 0 //PS 端 GPIO 器件 ID
#define MIO_LED2 15 //PS_LED2 连接到 MIO0
#define EMIO_KEY 54 //PL_KEY0 连接到 EMIO0

int main() {

printf("EMIO TEST!\n");

XGpioPs gpiops_inst; //PS 端 GPIO 驱动实例
XGpioPs_Config *gpiops_cfg_ptr; //PS 端 GPIO 配置信息

//根据器件 ID 查找配置信息
gpiops_cfg_ptr = XGpioPs_LookupConfig(GPIOPS_ID);
//初始化器件驱动
XGpioPs_CfgInitialize(&gpiops_inst, gpiops_cfg_ptr, gpiops_cfg_ptr->BaseAddr);

//设置 LED 为输出
XGpioPs_SetDirectionPin(&gpiops_inst, MIO_LED2, 1);
//使能 LED 输出
XGpioPs_SetOutputEnablePin(&gpiops_inst, MIO_LED2, 1);
//设置 KEY 为输入
XGpioPs_SetDirectionPin(&gpiops_inst, EMIO_KEY, 0);

//读取按键状态，用于控制 LED 亮灭
while(1) {
XGpioPs_WritePin(&gpiops_inst, MIO_LED2,
                 ~XGpioPs_ReadPin(&gpiops_inst, EMIO_KEY));
}
return 0;

}

```
板级验证：PL按键可控制PS LED亮灭