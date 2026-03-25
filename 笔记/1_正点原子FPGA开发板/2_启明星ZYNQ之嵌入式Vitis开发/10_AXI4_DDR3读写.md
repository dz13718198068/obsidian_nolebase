通过自定义一个AXI4接口的IP核，通过AXI_HP接口对PS端DDR3进行读写测试
系统框图
![|625](assets/Pasted%20image%2020250518205332.png)
DDR3test就是[17_自定义带AXI接口IP核](17_自定义带AXI接口IP核.md)创建的IP核

---
### ZYNQ_PS配置

使能HP接口
![|550](assets/Pasted%20image%2020250518224246.png)
打开时钟复位信号
![|550](assets/Pasted%20image%2020250518224333.png)
配置使能时钟，为==HP接口和自定义AXI4 IP核提供时钟==
![|550](assets/Pasted%20image%2020250520102031.png)

---
### 添加自定义AXI IP核

将ip核工程文件拷贝到此工程路径
![|625](assets/Pasted%20image%2020250520102510.png)
添加IP到ip库
![|625](assets/Pasted%20image%2020250520102742.png)
添加ip核到block design（适配型号一定要包含，要不找不到），自动连接
![|625](assets/Pasted%20image%2020250520103039.png)
![](assets/Pasted%20image%2020250520112138.png)
将信号引出到外部
![|500](assets/Pasted%20image%2020250520103301.png)
![](assets/Pasted%20image%2020250520103424.png)
![](assets/Pasted%20image%2020250520103433.png)
DDR3的地址是0x0000_0000-0x1FFF_FFFF
![](assets/Pasted%20image%2020250520103615.png)
因此block design中的基地址也需要更改
![|700](assets/Pasted%20image%2020250520103822.png)
生成顶层
![](assets/Pasted%20image%2020250520111350.png)
这个报错是因为没有配置axi_user的接口为0，看上图，配0就行
生成顶层完成后给3个引脚进行管脚分配
生成bit流，导出到SDK

输入字符c开始读DDDR，从其实地址开始读数据，每次读4个字节数据，直到读到4096（读1024次）
![|425](assets/Pasted%20image%2020250520114233.png)
run configurations以后输入c读ddr，发现与预期不符
预期是按下按键fpga才会往ddr里输入数据
但是运行程序后直接读出来数据了（未写过的DDR理应是随机值）
![|200](assets/Pasted%20image%2020250520114711.png)
==原因：axi4的init-axi-txn默认是高电平触发，而按键默认也是高电平，按键需取反==
加个取反逻辑ip核
![|450](assets/Pasted%20image%2020250520115030.png)
![|450](assets/Pasted%20image%2020250520115155.png)
接线
![|650](assets/Pasted%20image%2020250520115237.png)
调试信号debug，自动连接，自动生成ila
![|625](assets/Pasted%20image%2020250520115525.png)
修改ila采样深度
![|525](assets/Pasted%20image%2020250520115643.png)
ctrl + s ，generate output product
掉电
首次读是随机数
![](assets/Pasted%20image%2020250520124342.png)
写完DDR以后读是递增数
![](assets/Pasted%20image%2020250520124408.png)


















































































































