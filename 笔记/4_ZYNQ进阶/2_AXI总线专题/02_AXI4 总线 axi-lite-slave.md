
## 一、创建 axi4-lite-slave 总线接口 IP
###### 1 创建一个 AXI4-Lite 接口总线 IP
![|420](assets/Pasted-image-20260131143113.png)
![|420](assets/Pasted-image-20260131143321.png)
###### 2 选择使用 vivado 自带的 AXI 总线模板创建一个 AXI4-Lite 接口 IP
![|420](assets/Pasted-image-20260131143339.png)
###### 3 设置 IP 的名字为 saxi_lite
![|420](assets/Pasted-image-20260131143519.png)
模板支持 3 中协议，分别是 AXI4-Full AXI4-Lite AXI4-Stream
###### 4 总线包括 Master 和 Slave 两种模式，这里选择 Slave 模式
![|420](assets/Pasted-image-20260131143610.png)
###### 5 选择 Verify Peripheral IP using AXI4 VIP 可以对 AXI4-Lite 快速验证
![|420](assets/Pasted-image-20260131143650.png)
###### 6 单击 Finish 后展开 VIVADO 自动产生的 demo，单击 Block Design 的工程，
saxi_lite_0是我们自定义的 IP，
master_0 是用来读写我们自定义的 saxi_lite_0，以此验证我们的 IP 正确性。
![|580](assets/Pasted-image-20260131144009.png)
###### 7 右击 Generate Output Products生成接口文件
![|380](assets/Pasted-image-20260131144423.png)
###### 8 源码+接口文件
![|460](assets/Pasted-image-20260131144554.png)


## 二、程序分析
###### 1:axi-lite-slave 的 axi_awready
从机写地址就绪
![|500](assets/Pasted-image-20260131145237.png)
###### 2:axi-lite-slave 的 axi_awaddr
核心逻辑是**仅在从机准备接收写地址的时刻，锁存主机的写地址**：
![|500](assets/Pasted-image-20260131145710.png)
###### 3:axi-lite-slave 的 axi_wready
AXI4-Lite 总线写数据通道（W Channel）的核心逻辑，作用是控制从机侧写数据就绪信号`axi_wready` 的状态
只有在满足条件时，从机才会置位该信号，表示可以接收主机发来的写数据。
![|500](assets/Pasted-image-20260131150752.png)
![|460](assets/Pasted-image-20260131150921.png)
###### 4:axi-lite-slave 的写数据寄存器
**核心数据写入逻辑**，分为两部分：
一是通过组合逻辑生成写使能信号 `slv_reg_wren`，
二是在写使能有效时，根据锁存的地址和写选通信号，将主机发来的写数据精准写入对应的从机寄存器（slv_reg0~slv_reg3），还支持按字节粒度的写入控制。
![|500](assets/Pasted-image-20260131151107.png)
![|500](assets/Pasted-image-20260131151239.png)
![|500](assets/Pasted-image-20260131151255.png)
###### 5:axi-lite-slave 的 axi_bvalid 信号
AXI4-Lite 写响应通道（B Channel）的核心控制逻辑，
作用是在写事务完成后，生成并管理从机到主机的写响应信号（`axi_bvalid` 和 `axi_bresp`），告知主机本次写操作是否成功。
![|500](assets/Pasted-image-20260131151650.png)
###### 6:axi-lite-slave 的 axi_arready
AXI4-Lite 读地址通道（AR Channel）的核心逻辑，主要实现两个功能：
一是控制从机侧读地址就绪信号 `axi_arready` 的状态，
二是在满足条件时锁存主机发来的读地址 `S_AXI_ARADDR` 到从机内部寄存器 `axi_araddr`，为后续的读数据操作提供目标地址。
![|500](assets/Pasted-image-20260131151841.png)
###### 7:axi-lite-slave 的 axi_araddr
AXI4-Lite 总线**读地址通道（AR Channel）** 的核心控制逻辑，主要实现两个关键功能：
一是控制从机读地址就绪信号 `axi_arready` 的状态，
二是在主机发送有效读地址时，将地址锁存到从机内部寄存器 `axi_araddr`，为后续读取对应寄存器数据做准备。
![|500](assets/Pasted-image-20260131152011.png)
###### 8:axi-lite-slave 的 axi_rvalid 信号
AXI4-Lite 读响应 / 读数据通道（R Channel）的核心控制逻辑，
主要作用是在主机发起读请求并完成地址握手后，生成有效的读响应信号（`axi_rvalid` 和 `axi_rresp`），并在主机接收读数据后撤销该信号，完成一次读事务的闭环。
![|500](assets/Pasted-image-20260131153740.png)
###### 9:axi-lite-slave 的读数据寄存器
AXI4-Lite 读事务的**核心数据读取与输出逻辑**，分为三部分：
生成读使能信号、
地址解码选择要读取的寄存器、
在合适时机将寄存器数据赋值给读数据总线 `axi_rdata`，最终把数据返回给主机。
![|500](assets/Pasted-image-20260131153937.png)
![|500](assets/Pasted-image-20260131153952.png)
![|500](assets/Pasted-image-20260131154012.png)
可以发现，axi-lite-slave 的代码中没有突发长度的处理，每次只处理一个地址的一个数据。
并且也没有 WLAST 和 RLAST 信号，说明 axi-lite-slave 适合一些低速的数据交互，但是可以节省一些FPGA 的逻辑资源。

## 三、仿真分析
单击仿真
![|380](assets/Pasted-image-20260131155904.png)
添加观察信号
![|500](assets/Pasted-image-20260131160557.png)


###### 写入操作

AXI 总下依次写入 1 2 3 4，slv_reg0~slv_reg3 完成数据寄存

写地址有效：
![](assets/Pasted-image-20260202095817.png)

写数据有效：
![](assets/Pasted-image-20260202095941.png)

写数据，四个reg内写入数据
![](assets/Pasted-image-20260202100056.png)

###### 读数据操作

读地址有效：
![](assets/Pasted-image-20260202100812.png)

数据有效：
![](assets/Pasted-image-20260202101140.png)

数据有效：
![](assets/Pasted-image-20260202101341.png)





















































































































