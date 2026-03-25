Vivado工具使用规则
参考手册：
1． Vivado Design Suite User Guide:System-Level Design Entry (UG895)。
2． Vivado Design Suite User Guide: DesignAnalysis and Closure Techniques(UG906)。

# 一、FPGA 开发流程
![|540](photo/Pasted%20image%2020250605091013.png)
# 二、FPGA 工程管理
主要分为以下四类：
1. 开发过程中使用的辅助文档文件（如绘图软件绘制的波形图文件等），该类文件存放的文件夹我们命名为 doc；
2. 新建工程及产生的文件，该类文件存放的文件夹我们命名为 prj； 
3. 开发过程中的 RTL 代码文件，该类文件存放的文件夹我们命名为 rtl； 
4. 仿真工程与仿真文件，该类文件存放的文件夹我们命名为 sim；
![|420](photo/Pasted%20image%2020250605092730.png)
# 三、点亮 LED 灯
## 3.1 功能分析
PL_KEY0 按键来控制底板上的 PL_LED0 灯亮灭。
按下点亮、松开熄灭。
## 3.2 硬件介绍
![|500](photo/Pasted%20image%2020250605095231.png)
![|420](photo/Pasted%20image%2020250605095243.png)
## 3.3 系统设计
进行模块划分和梳理模块间交互信号
## 3.4 硬件介绍
使用Viso绘制，绘制文件放在doc文件下
![|460](photo/Pasted%20image%2020250605095524.png)
![|460](photo/Pasted%20image%2020250605095624.png)
![|380](photo/Pasted%20image%2020250605095635.png)
![|460](photo/Pasted%20image%2020250605095644.png)
正点原子提供了Viso模具
![|500](photo/Pasted%20image%2020250605095733.png)
复制到我的形状里
![|500](photo/Pasted%20image%2020250605095804.png)
![|540](photo/Pasted%20image%2020250605095826.png)
## 3.5 绘制波形图
实际效果图
![|460](photo/Pasted%20image%2020250605100101.png)
根据效果图绘制真值表
![|500](photo/Pasted%20image%2020250605100145.png)
波形图绘制技巧：
- 输入信号的颜色定义为绿色，
- 输出的信号定义为红色，
- 中间变量信号定义为蓝色。
![|500](photo/Pasted%20image%2020250605100323.png)
绘制波形完成后按照波形编写RTL代码。
## 3.6 编写RTL代码
采用Notepad++工具来编写代码
好用
## 3.7 Modelsim手动仿真
编写仿真文件（TestBench）
1. 向被测功能模块的输入接口添加激励；
2. 对被测功能模块的顶层接口进行信号例化；
3. 判断被测功能模块的输出是否满足设计预期。

在前面 led\sim 中新建一个 tb 文件夹，
![|500](photo/Pasted%20image%2020250605100927.png)
在 tb 文件夹下面新建一个“tb_led.v”
![|500](photo/Pasted%20image%2020250605100951.png)

1. 定义仿真单位：仿真单位是 1ns，用于延迟语句，“#200”就是延迟 200ns；
```verilog
`timescale 1ns / 1ns //仿真单位/仿真精度
```
2. 定义输入与输出：一般输入信号定义为寄存器类型（reg），一般输出信号定义为线型（wire）。
```verilog
module tb_led();
//reg define
reg key;
//wire define
wire led;
```
3. 输入信号初始化：一位按键输入的初始化。因为板载按键默认为高电平，所以初始化时我们给按键赋值高电平。
```verilog
//信号初始化
initial begin
key <= 1'b1; //按键上电默认高电平
```
4. 给输入信号赋值：结合延迟语句给输入按键赋不同的值。模拟按键被按下和被释放。
```verilog
//key 信号变化
#200 //延迟 200ns
key <= 1'b1; //按键没有被按下
#1000
key <= 1'b0; //按键被按下
#600
key <= 1'b1;
#1000
key <= 1'b0;
end
```
5. 例化 led 模块：例化点亮 LED 模块。通过例化 led 模块，我们 TB 模块编写的激励就可以传递到待测模块进行仿真
```verilog
//例化 led 模块
led u_led(
.key (key),
.led (led)
);
endmodule
```

**在 modelsim中仿真**
**建立project**
![|460](photo/Pasted%20image%2020250605103114.png)
![|460](photo/Pasted%20image%2020250605103131.png)
![|460](photo/Pasted%20image%2020250605103233.png)
- Create New File（创建新文件）
- Add Existing File （添加已有文件）
- Create Simulation（创建仿真）
- Create New Folder（创建新文件夹）

**这里我们先选择“Add Existing File”（添加已有文件）**
![|500](photo/Pasted%20image%2020250605103320.png)
**添加仿真文件**
![|500](photo/Pasted%20image%2020250605103459.png)
**文件添加完成**
![|500](photo/Pasted%20image%2020250605103537.png)
**编译：**
- Compile Selected（编译所选）
- Compile All（编译全部）
![|500](photo/Pasted%20image%2020250605103633.png)
- Compile Order：文件编译顺序，可以调整编译的.v 文件的编译顺序。
- Compile Report：编译报告，内容为当次编译的详细报告。
- Compile Summary：编译摘要，执行过的编译操作都在编译摘要有记录。

**编译完成：**
![|500](photo/Pasted%20image%2020250605103715.png)
- “√”表示编译通过状态
- “×”表示编译错误
- 黄色的三角符表示包含警告的编译通过

**开始配置仿真环境：【Simulate】→【Start Simulation...】**
![|500](photo/Pasted%20image%2020250605103931.png)
- Design Optimization：优化设计设置页面。
- Runtime Options：运行选项配置，例如波形格式配置、仿真时间设置等。
- Restart：重启仿真。
- Break/End Simulation：终止仿真运行。

**配置仿真功能：**
- Design：标签内居中的部分是 Modelsim 中当前包含的全部库，展开看到库中包含的设计单元，这些库和单元是为仿真服务的，使用者可以选择需要进行仿真的设计单元开始仿真，此时被选中的仿真单元的名字就会出现在下方的 Design Unit（s）位置。支持同时对多个文件进行仿真。右侧是 ==Resolution 选项，这里可以选择仿真的时间精度。==
  ![|420](photo/Pasted%20image%2020250605104016.png)
- VHDL
- Verilog
- Libraries：可以设置搜索库。 
  Search Libraries 和 Search Libraries First 的功能基本一致，唯一不同的是 Search Libraries First 中指定的库会在指定的用户库之前被搜索。
  ![|460](photo/Pasted%20image%2020250605112738.png)
- SDF：Standard Delay Format（标准延迟格式）的缩写，内部包含了各种延迟信息，也是用于时序仿真的重要文件。 
  SDF Files 区域用来添加 SDF 文件。
  第一个“Disable SDF warning”是禁用 SDF 警告，
  第二个“Reduce SDF errors to warnings”是把所有的 SDF 错误信息变成警告信息。
  Multi-Source delay 中可以控制多个目标对同一端口的驱动，如果有多个控制信号同时控制同一个端口或互连，且每个信号的延迟值不同，可以使用此选项统一延迟。
  latest、 min 和 max。 
  latest选项选择最后的延迟作为统一值， 
  max 选项选择所有信号中延迟最大的值作为统一值， 
  min 选项选择所有信号中延迟最小的值作为统一值
  ![|460](photo/Pasted%20image%2020250605112724.png)
- Others

**勾选“Enable optimization”**
![|420](photo/Pasted%20image%2020250605114209.png)
**优化选项进行如下图设置**
![|460](photo/Pasted%20image%2020250605114246.png)
如果不进行上面的优化选项配置， Modelsim SE-64 2020.4 仿真会报如下截图所示错误
![|340](photo/Pasted%20image%2020250605114353.png)
**点击“OK” 就可以开始进行功能仿真**
![|460](photo/Pasted%20image%2020250605114420.png)
![|460](photo/Pasted%20image%2020250605114437.png)
**添加查看的信号**
![|420](photo/Pasted%20image%2020250605114509.png)
![|500](photo/Pasted%20image%2020250605114524.png)
**仿真按钮，如下图**
![|380](photo/Pasted%20image%2020250605114553.png)
Restart：复位仿真，点击该按钮会有一个弹框如下图所示
![|420](photo/Pasted%20image%2020250605114616.png)
- Run Length：设置仿真时间，配合运行仿真按钮使用；
- Run：运行仿真，配合设置仿真时间一起使用，会按照设置仿真时长进行仿真；
- ContinueRun：继续仿真，在停止仿真后需要继续运行仿真，可以使用继续仿真按钮；
- Run -All：一直仿真，点击仿真复位后，再点击一直仿真，仿真会一直运行，直到点击 Stop 停止仿真；
- Break：中断当前编译或者仿真；
- Stop：在下一步或者下一时间之前停止仿真。
- 注意：使用“Run -All”与“ContinueRun”时，如果仿真工程是只有组合电路，没有使用时钟，工程仿真使用“Run -All”与“ ContinueRun”时，就只能跑到仿真文件的激励的节点，不能一直运行仿真。此时如果在仿真文件添加持续的时钟输入，点击“ Run -All”与“ContinueRun”时就会一直仿真。

**选择仿真时间为 10us**
![|500](photo/Pasted%20image%2020250605114749.png)
**仿真结果**
![|540](photo/Pasted%20image%2020250605114805.png)
**ModelSim 软件中几个常用小工具**
放大、缩小和全局显示功能，有快捷键
![|540](photo/Pasted%20image%2020250605114828.png)
黄色图标是用来在波形图上添加用来标志的黄色竖线，紧跟着的是将添加的黄色竖线对齐到信号的下降沿和上升沿
![|580](photo/Pasted%20image%2020250605114906.png)
**当我们需要对 IP 核进行仿真时一定要事先将 IP 核的库文件加载到Modelsim 库中去。**
RTL 代码仿真验证完成

## 3.8 新建工程
![|460](photo/Pasted%20image%2020250605121333.png)
![|460](photo/Pasted%20image%2020250605121339.png)
![|460](photo/Pasted%20image%2020250605121411.png)
![|500](photo/Pasted%20image%2020250605121438.png)
工程类型选择：
- “RTL Project”是指按照正常设计流程所选择的类型，这也是常用的一种类型。
	- “Do not specify sources at this time”：用于设置是否在创建工程向导的过程中添加设计文件，如果勾选后，则不创建或者添加设计文件，我们后续需要添加设计文件，所以不勾选该选项。
	- “Project is an extensible Vitis platform”：创建的工程是否需要扩展 Vitis 开发平台，点亮 LED等实验不需要 Vitis 开发平台。所以这个选项我们也不需要勾选。
- “Post-synthesis Project”在导入第三方工具所产生的综合后网表时才选择；
- “I/O Planning Project”一般用于在开始 RTL 设计之前，创建一个用于早期 IO 规划和器件开发的空工程；
- “Imported Project” 用于从 ISE、 XST 或 Synopsys Synplify 导入现有的工程源文件； 5）“Example Project”是指创建一个 Vivado 提供的工程模板。

**选择开发板的芯片型号**
![|500](photo/Pasted%20image%2020250605121626.png)
![|580](photo/Pasted%20image%2020250605121712.png)
Category:种类，如下图所示按照芯片用途有四个类别
- Automotive ：车用芯片；
- General Purpose：一般用途的芯片； 
- Military/Hi-Reliability：军用/高可靠性的芯片； 
- Radition Tolerant：辐射耐受性的芯片；
![|500](photo/Pasted%20image%2020250605121746.png)
![|500](photo/Pasted%20image%2020250605121903.png)
**工程界面：**
![](photo/Pasted%20image%2020250605121928.png)
1. Flow Navigator。 Flow Navigator 提供对命令和工具的访问，其包含从设计输入到生成比特流的整个过程。 在点击了相应的命令时，整个 Vivado 工程主界面的各个子窗口可能会作出相应的更改。
2. 数据窗口区域。默认情况下， Vivado IDE 的这个区域显示的是设计源文件和数据相关的信息。
	- Sources 窗口： 显示层次结构（Hierarchy）、 IP 源文件（IP Sources）、库（Libraries）和编译顺序（Compile Order）的视图。
	- Netlist 窗口： 提供分析后的（elaborated）或综合后的（synthesized）逻辑设计的分层视图。
3.  Properties 窗口： 显示有关所选逻辑对象或器件资源的特性信息。
4. 工作空间（Workspace）： 工作区显示了具有图形界面的窗口和需要更多屏幕空间的窗口，包括：
	- Project Summary。提供了当前工程的摘要信息，它在运行设计命令时动态地更新。
	- 用于显示和编辑基于文本的文件和报告的 Text Editor。
	- 原理图（Schematic）窗口。
	- 器件（Device）窗口。
	- 封装（Package）窗口。
5. 结果窗口区域：在 Vivado IDE 中所运行的命令的状态和结果，显示在结果窗口区域中，这是一组子窗口的集合。在运行命令、生成消息、创建日志文件和报告文件时，相关信息将显示在此区域。默认情况下，此区域包括以下窗口：
	- Tcl Console： 允许您输入 Tcl 命令，并查看以前的命令和输出的历史记录。
	- Messages： 显示当前设计的所有消息，按进程和严重性分类，包括“Error”、“Critical Warning”、“Warning”等等
	- Log： 显示由综合、实现和仿真 run 创建的日志文件。
	- Reports： 提供对整个设计流程中的活动 run 所生成的报告的快速访问。
	- Designs Runs： 管理当前工程的 runs。
6. 主工具栏： 主工具栏提供了对 Vivado IDE 中最常用命令的单击访问。
7. 主菜单： 主菜单栏提供对 Vivado IDE 命令的访问。
8. 窗口布局（Layout）选择器： Vivado IDE 提供预定义的窗口布局，以方便调用设计过程中的各种窗口。布局选择器使您能够轻松地更改窗口布局。或者，可以使用菜单栏中的“Layout”菜单来更改窗口布局

## 3.9 设计输入

### 3.9.1 设置字体
“Settings”→“Text Editor”→“Fonts and Colors”
![|620](photo/Pasted%20image%2020250605122351.png)
### 3.9.2 手动设置顶层
从“Sources”窗口的右击菜单中选择“Set as Top”

## 3.10 分析与综合


### 3.10.1 分析（Elaborated）
Vivado 会编译 RTL 源文件并进行全面的语法检查，
![|500](photo/Pasted%20image%2020250605122552.png)
Vivado 会生成顶层原理图视图，并在默认 view layout 中显示设计。此页面可分配I/O
![|540](photo/Pasted%20image%2020250605122659.png)
- Name：工程中顶层端口的名称。
- Direction：说明管脚是输入还是输出。
- Neg Diff Pair：负差分对， 差分信号在 I/O Ports 窗口中只显示在一行里中（只会显示 P 端信号， N 端信号显示在 Neg Diff Pair 属性栏中）。
- Package Pin：配置管脚封装。
- Fixed： 每一个端口都有 Fixed 属性，表明该逻辑端口是由用户赋值的。端口必须保持锁定状态，才能避免生成比特流时不会发生错误。
- Bank， I/O Std， Vcco， Slew Type， 
- Drive Strength：显示 I/O 端口的参数值。
- Bank：显示管脚所在的 Bank。
- I/O Std：配置管脚的电平标准，常用电平标准有 LVTTL 和 LVCMOS、 SSTL、 LVDS 与 HSTL 等。Vcco：选择的管脚的电压值。
- Vref： 在我们的设计中，硬件上 VREF 引脚悬空。
- Drive Strength： 驱动强度，默认 12mA。
- Slew Type： 指上升下降沿的快慢，设置快功耗会高一点，默认设置慢（ slow）。
- Pull Type：管脚上下拉设置，有上拉、下拉、保持与不设置。
- Off-Chip Termination： 终端阻抗，默认 50Ω。
- IN-TERM： 是用于 input 的串联电阻
![|620](photo/Pasted%20image%2020250605122804.png)
引脚配置在硬件原理图
==供电电压在原理图的bank供电电压==
![|500](photo/Pasted%20image%2020250605123056.png)
管脚约束
![|500](photo/Pasted%20image%2020250605123143.png)
![|620](photo/Pasted%20image%2020250605123132.png)
“Ctrl+S”保存
管脚约束也可以手敲

**I/O约束语句**
set_property”是命令的名称；
“PACKAGE_PIN L14”是引脚位置参数，代表引脚位置是 L14；
“[get_ports key]”代表该约束所要附加的对象是 key 引脚；
“IOSTANDARD LVCMOS33”代表该引脚所使用的电平标准是LVCMOS33。
```verilog
#IO 管脚约束
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports key] set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports led]
```

**时钟周期约束语句**
“create_clock”是该命令的名称，它会创建一个时钟；
其后的“-name clk”、“-period 20”、“[get_ports sys_clk ]”都是该命令的各个参数，
分别表示所创建时钟的名称是“ clk”、
时钟周期是 20ns、
时钟源是 sys_clk 端口，
==一般只对输入的时钟做周期的约束==
```verilog
#时钟周期约束
create_clock -name clk -period 20 [get_ports sys_clk ]
```
### 3.10.2 对代码进行综合
![|460](photo/Pasted%20image%2020250605123852.png)
**“Open Synthesized Design”选项打开综合设计。**
![|460](photo/Pasted%20image%2020250605123925.png)
**综合后原理图**
![|540](photo/Pasted%20image%2020250605123948.png)
- IBUF 是输入缓存
- OBUF 是输出缓存
- 取反通过一个 LUT1实现

**综合后设计其他选项**
- Constraints Wizard：约束向导。
- Edit Timing Constraints：编辑时间约束。
- Set Up Debug：引导创建在线调试。
- Report Timing Summary：报告时序摘要并运行时序分析。
- Report Clock Networks：时钟网络报告。
- Report Clock Interaction：时钟交互报告。
- Report Methodology： 检查符合 UltraFast 设计方法的设计。
- Report DRC： 设计规则检查。
- Report Noise： 噪声分析报告。
- Report Utilization：资源利用率报告。
- Report Power：电源报告。
- Schematic：打开综合后的原理图设计。
![|460](photo/Pasted%20image%2020250605124058.png)
## 3.11 设计实现
**“Run Implementation”**
![|460](photo/Pasted%20image%2020250605124216.png)
**打开实现设计**
![](photo/Pasted%20image%2020250605124245.png)
Netlist”窗口中有“Nets”与“Leaf Cells”，点击“Nets”与“Leaf Cells”下面的选项，右边的器件图会高亮对应模块，所以实现设计将代码映射到了 FPGA 底层资源上。
**查看“ Design Runs”窗口中的实现结果**
![](photo/Pasted%20image%2020250605124341.png)
与综合的选项类似
![|460](photo/Pasted%20image%2020250605125003.png)
### 3.12 下载验证
![|420](photo/Pasted%20image%2020250605133524.png)
**生成bit流**
![|540](photo/Pasted%20image%2020250605133539.png)
**打开硬件管理**
![|460](photo/Pasted%20image%2020250605133631.png)
**连接硬件**
![|420](photo/Pasted%20image%2020250605133650.png)
**“Auto Connect”**
![|500](photo/Pasted%20image%2020250605133706.png)
**“ Program Device”**
![|500](photo/Pasted%20image%2020250605133820.png)
**下载程序**
![|460](photo/Pasted%20image%2020250605134046.png)
**“Enable end of startup check”**
勾选就是使用下载完成校验，如果下载失败就会返回一个错误提示
一般这里我们都是默认勾选的。

**开发板断电，程序会丢失**
ZYNQ 芯片无法单独固化比特流文件（ PL 的配置文件）
==这是由于 ZYNQ 非易失性存储器的引脚（如 SD 卡、 QSPI Flash）是 ZYNQ PS 部分的专用引脚，这些非易失性存储器由 PS 的 ARM 处理器进行驱动，需要将 bit 流文件和 elf 文件（软件程序的下载文件）合成一个 BOOT.BIN，才能进行固化，因此需要学习 ZYNQ 嵌入式 VITIS 的开发流程。==

参考笔记：[16_程序固化实验&](../../2_启明星ZYNQ之嵌入式Vitis开发/16_程序固化实验&.md)


































