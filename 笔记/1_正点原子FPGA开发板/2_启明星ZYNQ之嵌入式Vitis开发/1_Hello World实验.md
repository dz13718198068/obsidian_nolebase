嵌入式开发流程
![|500](photo/Pasted%20image%2020250517165251.png)

硬件部分：step1-step4，Vivado
软件部分：step5，SDK
功能验证：step6


ZYNQ嵌入式最小系统构成：
（1）ARM Cortex-A9 为核心
（2）DDR3 为内存
（3）UART 串口传输信息
![|500](photo/Pasted%20image%2020250517165504.png)

任务：使用串口打印“Hello World”


**硬件设计：**
**step1：创建工程（略）**
**step2：使用 IP Integrator 创建 Processing System**
创建block design
![|500](photo/Pasted%20image%2020250517170119.png)
添加PS（ZYNQ7 Processing System）
![|500](photo/Pasted%20image%2020250517170359.png)
配置ZYNQ7 Processing System模块，关掉不需要的接口和功能
打开UART0
![|500](photo/Pasted%20image%2020250517170658.png)
查看UART0的MIO引脚信息
![|500](photo/Pasted%20image%2020250517170835.png)
配置UART0波特率（默认）
![|500](photo/Pasted%20image%2020250517170932.png)
配置 PS 的 DDR3 控制器
![|500](photo/Pasted%20image%2020250517171110.png)
配置PS的时钟
![|500](photo/Pasted%20image%2020250517171253.png)
移除PS 中与 PL 端交互的接口（搭建最小系统）
![|500](photo/Pasted%20image%2020250517171413.png)
移除Clock_Reset和AXI接口
![|500](photo/Pasted%20image%2020250517171618.png)
观察PS模块接口减少了4个接口，点击Run Block Automation生成具体引脚
![|500](photo/Pasted%20image%2020250517171820.png)
验证当前设计
![|500](photo/Pasted%20image%2020250517172000.png)
**step3：生成顶层 HDL 模块**
![|500](photo/Pasted%20image%2020250517173121.png)
Create HDL Wrapper，使用 Verilog HDL 对设计进行封装， 主要完成了对 block design 的例化
![|500](photo/Pasted%20image%2020250517173248.png)
勾选了“ Let Vivado manage wrapper and auto-update”， 这样我们在修改了 Block Design 之后就不需要再重新生成顶层模块， Vivado 工具会自动更新该文件。
![|500](photo/Pasted%20image%2020250517173336.png)
**step4：生成 Bitstream 文件并导出到 SDK**
为用到PL部分无需生成 Bitstream 文件，只需将硬件导出到 SDK 即可。
导出硬件
![|300](photo/Pasted%20image%2020250517174535.png)
无需比特流
![|325](photo/Pasted%20image%2020250517174611.png)
后缀名.hdf 的文件即硬件定义文件。
![|500](photo/Pasted%20image%2020250517174814.png)
打开SDK
![|350](photo/Pasted%20image%2020250517174939.png)
进入到软件部分


**软件设计**


硬件描述文件system.hdf的标签页显示了整个 PS 系统的地址映射信息。
![|625](photo/Pasted%20image%2020250517175414.png)
![|650](photo/Pasted%20image%2020250517175653.png)
**step5：在 SDK 中创建应用工程**
新建一个 SDK 应用工程
![|625](photo/Pasted%20image%2020250517175801.png)
![|650](photo/Pasted%20image%2020250517180045.png)
应用工程：hello_world
板级支持包(BSP)工程：hello_world_bsp
工具会自动编译生成elf文件和.mss(微处理器软件说明)文件
微处理器软件说明.mss包含 BSP 的操作系统信息、 硬件设计中各个外设的软件驱动等信息。
![|700](photo/Pasted%20image%2020250517180413.png)
源码共3句话
![|725](photo/Pasted%20image%2020250517180630.png)
函数init_platform：使能caches和初始化uart
函数cleanup_platform ：取消使能caches
这俩函数无效果，但因平台的通用性和可移植性保留这两个函数
函数printf()：“ xil_printf.h”中Xilinx 定义的一个用于打印字符串的函数
程序保存后会自动编译
![|550](photo/Pasted%20image%2020250517181023.png)
点击“ Build All”或Ctrl+B可主动编译工程
![|475](photo/Pasted%20image%2020250517181209.png)



下载验证
![|650](photo/Pasted%20image%2020250517182207.png)
在SDK终端中添加板子端口
下载程序后可看到hello world的打印信息
![](photo/Pasted%20image%2020250517182341.png)


































































































