- [一、初识 ZYNQ](#一、初识%20ZYNQ)
- [二、ZYNQ 芯片命名规则](#二、ZYNQ%20芯片命名规则)





---
### 一、初识 ZYNQ
Zynq 是由两个主要部分组成的：
1. PL： 可编程逻辑(Progarmmable Logic)，也就是 FPGA 部分。
2. PS： 处理系统（Processing System)， 就是 ARM 的 SOC 的部分
![|247](photo/Pasted%20image%2020250604200240.png)
---
### 二、ZYNQ 芯片命名规则
Artix7、 Kintex7 和 Virtex7 这三个系列的命名规则是通用的
以 ZYNQ“XC7Z020-CLG400-2”为例：
- **“XC”是“Xilinx 公司”；**
- **“7”是 7 系列（Series）；**
- **“Z”是型号是 zynq；**
- **“020”是价值索引（Value Index），该数值越大对应芯片内部资源越丰富，价值越高；**
- **“clg400”芯片封装信息，**
	- “CLG”是芯片制造工艺信息，
	- “400”是芯片封装引脚计数（Package Pin Count）；
- **“-2”是速度等级（Speed Grade）；**
- **“-I”是温度等级（Temperature Grade），温度等级有三种标准，分别是“C”、“E”与“I”。**
	- C：商业级， 表示芯片可以工作在 0°C 到+85°C；
	- E：扩展级， 表示芯片可以工作在 0°C 到+100°C； 
	- I：工业级， 表示芯片可以工作在-40°C 到+125°C。
![](photo/Pasted%20image%2020250604200931.png)













