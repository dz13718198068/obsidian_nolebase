参考文档：基于Vivado的AXI参考指南（UG1037）
ARM文档：AMBA AXI协议规范（IHI0022D）

AXI介绍

什么是AXI：高级可扩展接口，是AMBA的一部分
AMBA：高级微控制器总线架构，是1996年首次引入的一组微控制器总线。是开放的片内互联的总线标准，能在多主机设计中实现多个控制器核外围设备之间的连接管理

AXI接口的三种类型
AXI4（AXI4-FULL）：用于高性能的存储映射需求。（存储映射：主机在对从机进行读写操作时，指定一个目标地址，这个地址对应系统存储空间的地址，表示对该空间进行读写操作）
AXI4-Lite：简化版AXI4接口，用于低吞吐率存储器映射的通信
AXI4-Stream（ST）：用于高速流数据通信

AXI的优点：

生产力：
灵活性：
AXI4（支持突发256）
AXI4-Lite（1个数据）都属于存储器映射，
AXI-ST不属于存储器映射，突发长度不受限制
可获得性：
AXI工作方式

AXI4和AXI4-Lite包含5个独立的通道

读地址通道
读数据通道
写地址通道
写数据通道
写响应通道

AXI4：由于读写地址通道时分离的，所以支持双向同时传输；突发长度最大256
AXI4-Lite：和AXI4比较类似，但是不支持突发传说
AXI4-ST：只有一个单一数据通道，和AXI4的写数据通道比较类似，突发长度不受限制。

AXI InterConnect和AXI SmartConnect

这两个IP核都用连接单/多个存储器映射的AXI Master和单/多个存储器映射的AXI Slave
![](assets/Pasted%20image%2020250526083901.png)
![](assets/Pasted%20image%2020250526083904.png)
![](assets/Pasted%20image%2020250526083906.png)
![](assets/Pasted%20image%2020250526083909.png)


信号的描述
信号在全局时钟上升沿采样，复位信号低电平有效
![|500](assets/Pasted%20image%2020250517150356.png)
写地址通道信号： 
AWID
==AWADDR==：写地址，起始地址
==AWLEN==：突发长度。有个+1
==AWSIZE==：突发大小，单个数据的数据量
==AWBURST==：突发类型FIXED、INCR字节单位累加、WRAP
AWLOCK：锁的类型，正常传输or独有传输
AWCACHE： 0010是不缓存
AWPORT：
AWQOS：服务质量
AWREGION：区域ID
AWUSER：用户自定义信号
==AWVALID==：握手机制，master发出，当前数据有效
==AWREADY==：握手机制，slave发出，当前从机是否准备好接收数据
![|525](assets/Pasted%20image%2020250517150413.png)
写数据通道信号：
WID：
==WDATA==：写入数据
==WSTRB==：写选通信号，指示当前WDATA的哪一位数据有效
==WLAST==：拉高通知从机，当前数据是最后一个数据
WUSER：用户自定义信号
==WVALID==：握手机制。master发出，当前数据有效
==WREADY==：握手机制。slave发出，当前从机是否准备好接收数据
![|475](assets/Pasted%20image%2020250517150425.png)
写响应通道信号：
BID：
==BRESP==：写传输状态，从机发给主机
		OKAY、EXOKAY独占式存取、SLVERR从机错误、DECERR解码错误
BUSER：
==BVALID==：slave发出。
==BREADY==：master发出。
![|500](assets/Pasted%20image%2020250517152602.png)
读地址通道信号：
ARID：
==ARADDR==：读地址
==ARLEN==：突发长度
==ARSIZE==：突发大小
==ARBURST==：突发类型
ARLOCK：锁类型
ARCACHE：
ARPROT：
ARQOS：服务质量
ARREGION：区域ID
ARUSER：自定义信息
==ARVALID==：握手机制。
==ARREADY==：握手机制。
![](assets/Pasted%20image%2020250517152740.png)
读操作通道：
RID：
==RDATA==：读数据
RRESP：读响应
==RLAST==：突发传输的读的最后一个数据
RUSER：
==RVALID==：握手机制。
==RREADY==：握手机制。



时钟和复位

时钟：使用全局时钟ACLK，上升沿采样
复位：
![](assets/Pasted%20image%2020250517153632.png)


![|425](assets/Pasted%20image%2020250517154737.png)
握手处理：
五个通道使用相同的VALID/READY握手处理来传输地址、数据和控制信息
双向流程控制机制意味着master和slave都可以控制传输速率
源端产生VALID表示地址、数据和控制信息何时有效
目的端产生READY表示当前可以接收信息
==传输只有在VALID和READY同时高电平时才会发生==
![|500](assets/Pasted%20image%2020250517154508.png)
![|500](assets/Pasted%20image%2020250517154630.png)
![|500](assets/Pasted%20image%2020250517155311.png)
写地址通道：
当地址和控制信息有效时，主机才能拉高AWVALID信号
当AWVALID信号拉高之后，要保持不变直到下一个时钟上升沿
![](assets/Pasted%20image%2020250517155340.png)
 写/读响应READY应跟在VALID后面



AXI4-Lite介绍
适用于当不需要AXI4完整功能的时候，可实现一些简单的控制寄存器的读写
突发长度时1
数据位宽32or64
五缓存
不支持独占式访问
![|425](assets/Pasted%20image%2020250517162231.png)
接口较少
![|475](assets/Pasted%20image%2020250517162301.png)


时序图：
![|525](assets/Pasted%20image%2020250517162458.png)
![|525](assets/Pasted%20image%2020250517162649.png)


























