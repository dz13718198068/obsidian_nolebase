PCF8563简介
PCF8563：低功耗实时时钟芯片
提供：可编程时钟输出，中断输出，低电压检测器
双向IIC总线，最大传输速度400kbit/s
读写操作后地址自动增加

结构框图
![|425](photo/Pasted%20image%2020250515160549.png)
IIC接口：
SDA
SCL

电容振荡器引脚：与无源晶振连接，提供时钟
OSCI
OSCO

DIVIDER：分频器。clock out直接输出 / 分配给功能模块

WATCH DOG：看门狗。异常报警 or 异常复位


功能模块：
control：控制选择芯片工作类型
time：时间。秒，分，时，天，周，月，年
alarm function：闹钟
timer function：定时器

定时器和闹钟可输出中断指令。

寄存器配置：
![|525](photo/Pasted%20image%2020250515162043.png)
寄存器描述：

![|500](photo/Pasted%20image%2020250515163049.png)
甚至可以不配，器件默认配置其实就能使用。
手册后面详细写了具体寄存器怎么配置，以及如何读这些时间（一次性读完）。


BCD码（常见8421码）
![|500](photo/Pasted%20image%2020250515163700.png)

硬件电路
![|500](photo/Pasted%20image%2020250515172639.png)
可以看到中断为用到。

图中看到供电方式为3.3v电源和纽扣电池同时供电。即便断电，纽扣电池依旧可以供电。


程序框架
![|500](photo/Pasted%20image%2020250515174126.png)


PCF8563控制模块：将显示数据传到LCD字符显示模块



手册里：1是读，0是写。这是iic控制的指令
![|500](photo/Pasted%20image%2020250516125511.png)


上电要求：8ms以后再使用。
可以看到时钟周期是2000ns，需分频使用
![|500](photo/Pasted%20image%2020250516125756.png)
![|500](photo/Pasted%20image%2020250516125813.png)

读写时序
![|500](photo/Pasted%20image%2020250516135506.png)

初始化i2c_rh_wl是写模式，初始化完成后i2c_rh_wl变成读模式并且之后所有的操作就都是读模式了
![|450](photo/Pasted%20image%2020250516135945.png)

iic驱动
使用
三段式状态机


第一段
时序赋值
将下一个状态赋值给当前状态
![|500](photo/Pasted%20image%2020250516141131.png)

第二段
组合逻辑
每一个状态具体是怎么跳转的
![|400](photo/Pasted%20image%2020250516141307.png)
第三段
时序
每一个状态中给相应的变量赋值

i2c_exec代表启用iic标志，开始使用iic
![|475](photo/Pasted%20image%2020250516142212.png)

协议开始时对照时序看代码
先写器件地址
![|500](photo/Pasted%20image%2020250516142324.png)
![|500](photo/Pasted%20image%2020250516142315.png)















































