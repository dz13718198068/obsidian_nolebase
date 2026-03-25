- [一、ZYNQ PL 简介](#一、ZYNQ%20PL%20简介)
		- [1. 可编程输入/输出单元](#1.%20可编程输入/输出单元)
		- [2. 基本可编程逻辑单元](#2.%20基本可编程逻辑单元)
		- [5. 嵌入式块 RAM](#5.%20嵌入式块%20RAM)
		- [4. 丰富的布线资源](#4.%20丰富的布线资源)
		- [5. 底层内嵌功能单元](#5.%20底层内嵌功能单元)
		- [6. 内嵌专用硬核](#6.%20内嵌专用硬核)
		- [7. ZYNQ PL 架构](#7.%20ZYNQ%20PL%20架构)
- [二、ZYNQ PS 简介](#二、ZYNQ%20PS%20简介)
	- [PS部分](#二、ZYNQ%20PS%20简介#PS部分)
			- [1. APU](#7.%20ZYNQ%20PL%20架构#1.%20APU)
			- [2. APU之外](#7.%20ZYNQ%20PL%20架构#2.%20APU之外)
			- [3. PS与PL之间的接口](#7.%20ZYNQ%20PL%20架构#3.%20PS与PL之间的接口)
			- [4. PS外部接口](#7.%20ZYNQ%20PL%20架构#4.%20PS外部接口)
- [三、ZYNQ 的优势](#三、ZYNQ%20的优势)
	- [1. ZYNQ 应用的领域](#三、ZYNQ%20的优势#1.%20ZYNQ%20应用的领域)









---
### 一、ZYNQ PL 简介
FPGA 基本结构一般由六部分组成，分别为
- 可编程输入/输出单元
- 基本可编程逻辑单元
- 底层嵌入功能单元
- 布线资源
- 嵌入式块 RAM 
- 内嵌专用硬核
![|580](photo/Pasted%20image%2020250604213959.png)
##### 1. 可编程输入/输出单元
I/O 单元，输入/输出（Input/Ouput），与外界电路的接口部分Zynq 上的通用输入/输出功能（IOB）合起来被称作 SelectIO 资源。50 个 IOB 一组。每个 IOB 有1个焊盘，与外部世界连接来做单个信号的输入或输出。每个 IOB 还包含一个IOSERDES 和 IODELAY 资源，可以做并行和串行数据的可编程转换。
![|620](photo/Pasted%20image%2020250604214142.png)
##### 2. 基本可编程逻辑单元
基本可编程逻辑单元几乎都是由查找表（LUT， Look Up Table）和寄存器（Register）组成。比较经典的基本可编程逻辑单元的配置是一个寄存器加一个查找表，但是不同厂商的寄存器与查找表也有一定的差异，而且寄存器与查找表的组合模式也不同。
Xilinx 7 系列 FPGA 中的可编程逻辑单元叫 CLB（Configurable Logic Block，可配置逻辑块），每个CLB 里包含两个逻辑片（ Slice）。每个 Slice 由 4 个查找表、 8 个触发器和其他一些逻辑所组成的。 CLB示意图如下所示：
![|580](photo/Pasted%20image%2020250604214637.png)
CLB 是逻辑单元的最小组成部分，在 PL 中排列为一个二维阵列，通过可编程互联连接到其他类似的资源。每个 CLB 里包含两个逻辑片，并且紧邻一个开关矩阵， 如下图所示
![|620](photo/Pasted%20image%2020250604214659.png)
##### 5. 嵌入式块 RAM
Zynq-7000 里的块 RAM 和 Xilinx 7 列 FPGA 里的 BRAM 是等同的，它们可以实现 RAM、 ROM 和先入先出（First In First Out， FIFO）缓冲器。每个块RAM 可以存储最多 36KB 的信息，并且可以被配置为一个 36KB 的 RAM 或两个独立的 18KB RAM。默认的字宽是 18 位，这样的配置下每个 RAM 含有 2048 个存储单元。 RAM 还可以被“重塑”来包含更多更小的单元（比如 4096 x9 位或 8192x4 位），或是另外做成更少更长的单元（如 1024 x36 位或 512x72 位）。把两个或多个块 RAM 组合起来可以形成更大的存储容量。 PL 中的块 RAM 示意图如下所示：
![|580](photo/Pasted%20image%2020250604214810.png)
除了块 RAM，还可以灵活地将 LUT 配置成 RAM、 ROM、 FIFO 等存储结构，这种技术被称为分布式 RAM。根据设计需求，块 RAM 的数量和配置方式也是器件选型的一个重要标准。
##### 4. 丰富的布线资源
布线资源根据工艺、长度、宽度和分布位置的不同而划分为4 类不同的类别：
1. **全局布线资源**，用于芯片内部全局时钟和全局复位/置位的布线；
2. **长线资源**，用以完成芯片 Bank 间的高速信号和第二全局时钟信号的布线；
3. **短线资源**，用于完成基本逻辑单元之间的逻辑互连和布线；
4. **分布式的布线资源**，用于专有时钟、复位等控制信号线。
##### 5. 底层内嵌功能单元
一般指的是通用程度较高的嵌入式功能模块，比如 PLL（Phase Locked Loop）、 DLL （Delay Locked Loop）、 DSP、 CPU 等。
Xilinx 7 系列器件中的时钟资源包含了时钟管理单元 CMT（全称 Clock Management Tile，即时钟管理单元），每个 CMT 由一个 MMCM（全称 Mixed-Mode Clock Manager，即混合模式时钟管理）和一个 PLL（全称 Phase Locked Loop，即锁相环）组成。像 xc7z020 芯片内部有 4 个 CMT， xc7z010 芯片内部有 2 个 CMT，为设备提供强大的系统时钟管理以及高速 I/O 通信的能力。
##### 6. 内嵌专用硬核
主要指那些通用性相对较弱，不是所有 FPGA 器件都包含硬核。
在 ZYNQ 的 PL 端有一个数模混合模块——XADC，它就是一个硬核。 XADC 包含两个模数转换器（ADC），一个模拟多路复用器，片上温度和片上电压传感器等。我们可以利用这个模块监测芯片温度和供电电压，也可以用来测量外部的模拟电压信号。
##### 7. ZYNQ PL 架构
![](photo/Pasted%20image%2020250604215310.png)

---
### 二、ZYNQ PS 简介
ZYNQ = PS + PL
PS：SoC
PL：可编程逻辑器件
![](photo/Pasted%20image%2020250604112035.png)
#### PS部分
###### 1. APU
- Application Processor Unit：应用处理单元
- ARM Cortex-A9 CPU：处理器（ZYNQ是双核）
- FPU：浮点单元，浮点运算加速
- NEON Engine：实现单指令多数据的功能，例如处理视频数据时对像素点进行分别加速处理FFT等（并行处理）
- MMU：存储管理单元，可实现物理地址到虚拟地址的映射
- I-Cache：指令Cache，一级缓存
- D-Cache：数据Cache，一级缓存
- L2 Cache：二级Cache，两处理器共用
- OCM：on chip memery，片上存储器
- Snoop Controller：一致性控制单元，通过SCU访问二级Cache或OCM
- DMA：DMA通道，直接存储访问，可实现数据搬移
- GIC：中断控制器，可以帮助CPU接收并管理外部中断
![|420](photo/Pasted%20image%2020250604112059.png)
###### 2. APU之外
- Central Interconnect：中央互联，类似于开关，可实现不用模块、接口间的通信。
- SOC的其他互联：Central Interconnect、OCM互联、PL to Memory的互联。连接管理指挥各个模块的通信
- I/O Peripherals：通过复用MIO与外界连接（灵活性低），可使用常见标准接口、通用IO接口：GPIO。MIO与外设的映射可以自主控制，
- Memory Interfaces动态存储器接口：可接DDR
- Memory Interfaces静态存储器接口：连接SRAM、Flash等静态存储器（差别：数据是否需要动态刷新）
- Clock Generation：时钟生成。晶振输入时钟，该模块产生所需频率，通过锁相环实现
- Reset：复位模块。管理系统复位，常见来源：上电、复位按键、看门口产生复位


###### 3. PS与PL之间的接口
- EMIO：扩展的MIO，MIO是PS直接与外部交汇的接口（54个），可通过EMIO扩展引脚，PS可通过EMIO使用PL的IO引脚，PS也可以通过EMIO与PL中的模块进行交互。
- XADC：PL里的硬核，可实现数模转换。PS端的XADC接口可通过接口直接访问PL中的XADC硬核。
- DMA：可实现PL到PS的直接存储访问
- IRQ：中断请求，PL中可产生中断，传到PS中的中断控制器，处理器接收中断后进行处理
- Config：FPGA的配置接口，PS启动后配置PL实现PL的启动（ZYNQ中是以PS为核心的）
以下三个为AXI接口：
- GP接口General Purpose Ports：通用接口，M_AXI_GP主接口：PS作为主机发起通信，S_AXI_GP从接口：PS作为从机响应通信
- HP接口High Performance Ports高性能接口：连接到存储器互联，四个HP接口，fifo实现数据缓冲，实现高带宽大数据量的数据访问。例如使用摄像头即时存储图像。PL做主机，PS做从机
- ACP接口，加速器一致接口：连接到SCU，可控制OCM片上存储器、二级Cache缓存。可实现PL到OCM和L2 Cache的访问。可实现从PL到PS存储器的低延时的访问。PL主机，PS从机
![](photo/Pasted%20image%2020250526075553.png)
###### 4. PS外部接口
![|500](photo/Pasted%20image%2020250604220203.png)

---
### 三、ZYNQ 的优势

#### 1. ZYNQ 应用的领域
1. 汽车
   
2. 通信
   
3. 机器人、控制和仪器
   
4. 图像处理
   
5. 医疗应用


























