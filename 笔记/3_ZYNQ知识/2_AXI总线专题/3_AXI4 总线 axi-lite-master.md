
## 一、创建 axi4-lite-master 总线接口 IP
###### 1 创建 axi4-lite-master 总线接口 IP
![|460](assets/Pasted%20image%2020260202112324.png)

###### 2 使用 vivado 自带的 AXI 总线模板创建一个 AXI4-Lite 接口 IP
![|460](assets/Pasted%20image%2020260202112408.png)

###### 3 设置 IP 的名字为 maxi_lite
![|460](assets/Pasted%20image%2020260202112548.png)

###### 4 模板支持 3 种协议，总线包括 Master 和 Slave 两种模式，这里选择 Master 模式
![|460](assets/Pasted%20image%2020260202112538.png)

###### 5 选择 Verify Peripheral IP using AXI4 VIP 可以对 AXI4-Lite 快速验证
![|460](assets/Pasted%20image%2020260202112750.png)

###### 6 maxi_lite_0就是我们自定义的 IP，
slave_0 是用来验证 maxi_lite_0 正确性的
![](assets/Pasted%20image%2020260202144547.png)


###### 7 采用默认地址分配即可
![](assets/Pasted%20image%2020260202144643.png)

###### 8 uisrc/03_ip/ maxi_lite_1.0/hdl 路径下的maxi_lite_v1_0_M00_AXI.v 就是我们的源码。
另外一个 maxi_lite_v1_0.v是软件产生了一个接口文件，如果我们自己定义 IP 可有可无。
![](assets/Pasted%20image%2020260202144932.png)


## 二、程序分析

axi 总线信号的关键无非是地址和数据，而写地址的有效取决于 AXI_AWVALID 和AXI_AWREADY，写数据的有效取决于 S_AXI_WVALID 和 S_AXI_WREADY。

同理，读地址的有效取决于 AXI_ARVALID 和 AXI_ARREADY，
读数据的有效取决于 S_AXI_RVALID 和 S_AXI_RREADY。

###### 1:产生初始化信号
AXI 主机（Master）侧的**事务启动延迟逻辑**，核心作用是对 `INIT_AXI_TXN` 这个事务启动触发信号做两拍（两级寄存器）同步延迟，生成稳定的启动触发时序，避免因信号毛刺或异步输入导致 AXI 事务启动异常。
![|500](assets/Pasted%20image%2020260202151257.png)

###### 2:axi-lite-master 的 axi_awvalid
当 start_single_write 有效，开始一次写传输，设置 axi_awvalid 有效。
AXI 主机（Master）侧**写地址有效信号（axi_awvalid）的控制逻辑**，核心作用是根据复位、事务启动脉冲和从机的就绪反馈，精准控制 `axi_awvalid` 的置位（发起写地址请求）和清零（完成地址握手 / 复位），完全符合 AXI 协议对主机侧写地址通道的规范要求。
![|500](assets/Pasted%20image%2020260202152306.png)

###### 3:axi-lite-master 的 axi_awaddr
握手完成后地址递增
AXI 主机（Master）侧**写地址递增逻辑**，核心作用是在每次写地址握手完成后，将下一次要发送的写地址 `axi_awaddr` 自动递增 4 字节（符合 AXI-Lite 4 字节对齐的要求），通常用于连续写多个寄存器 / 内存地址的场景（比如批量配置参数）
![](assets/Pasted%20image%2020260202153916.png)

###### 4:axi-lite-master 的 axi_wvalid
当 M_AXI_WREADY && axi_wvalid 同时有效的时候，数据才是有效的，对于 axi-lite_master 接口，M_AXI_WREADY && axi_wvalid 同时有效的时间窗口是一个时钟周期。

AXI 主机（Master）侧**写数据有效信号（axi_wvalid）的控制逻辑**，核心作用是和写地址通道配合，精准控制主机向从机发送写数据的时机 —— 在写事务启动时置位有效信号，在从机接收数据完成后清零，完全符合 AXI 协议对写数据通道的规范要求。
![](assets/Pasted%20image%2020260202154644.png)

###### 5:axi-lite-master 的 axi_wdata
产生写测试用的测试数据
AXI 主机（Master）侧**写数据总线（axi_wdata）的赋值逻辑**，核心作用是在复位 / 初始化时给写数据赋初始值，在每次写数据握手完成后更新数据（基于初始值 + 索引），通常用于 “连续写不同数据到多个地址” 的场景（比如批量写入递增的配置参数）。
![](assets/Pasted%20image%2020260202155122.png)

###### 6:写次数记录 write_index 计数器
这个 demo 中以 start_single_wirte 信号作为统计的，如果我们完全自定 axi-lite_master 代码可以自行优化，可以写出更好的代码。我们这里是用 vivado 模板产生的代码主要线教会大家如何使用现有的手段和软件工具学习 axi4总线。
AXI 主机侧**写事务索引计数器（write_index）的控制逻辑**，核心作用是在每次触发单次写事务时，让索引值自增 1，用于标记已完成的写事务次数，或为写数据 / 地址生成提供动态偏移（比如你之前理解的 DDR 地址偏移）。
![](assets/Pasted%20image%2020260202155841.png)

###### 7:axi-lite-master 的 axi_bready
当收到写通道的 axi-lite-slave 发回的 M_AXI_BVALDI 应答信号，设置 axi_bready 为 1，BRESP 返回 AXI 写操作是否有错误。
AXI 主机（Master）侧**写响应通道（B Channel）的控制逻辑**，核心包含两部分：
一是精准控制主机的写响应就绪信号 `axi_bready`，完成写响应的握手闭环；
二是通过组合逻辑检测写响应错误，标记异常的写事务。
![](assets/Pasted%20image%2020260202160606.png)

###### 8:axi-lite-master 的 axi_arvalid
AXI 主机（Master）侧**读地址有效信号（axi_arvalid）的控制逻辑**，核心作用是根据复位、读事务启动信号和从机的就绪反馈，精准控制 `axi_arvalid` 的置位（发起读地址请求）和清零（完成地址握手 / 复位），是实现 AXI 读事务的核心环节，逻辑和写地址通道高度对称。
![](assets/Pasted%20image%2020260202161114.png)

###### 9:axi-lite-master 的 axi_araddr
AXI 主机（Master）侧**写地址自动递增逻辑**，核心作用是在每次写地址握手完成后，将下一次要发送的写地址 `axi_awaddr` 自动增加 4 字节（严格匹配 AXI-Lite 4 字节地址对齐的协议要求），专门用于 “连续向多个地址写入数据” 的场景（比如你之前理解的从 DDR 批量读取数据后，依次写入不同的从机寄存器 / 内存地址）。
![](assets/Pasted%20image%2020260202161827.png)

###### 10:axi-lite-master 的 axi_rready
当 M_AXI_RVALID && axi_rready同时有效的时候，数据才是有效的，对于 axi-lite_master 接口，M_AXI_RVALID && ~axi_rready== 1 的时候设置 axi_rready=1，当 axi_rready== 1，再设置 axi_rready=0
![](assets/Pasted%20image%2020260202163311.png)

###### 11:axi-lite-master 的 M_AXI_RDATA
当 M_AXI_RVALID && axi_rready 都有效的时候，对读取的 M_AXI_RDATA 数据和expected_rdata 数据进行比较。
AXI 主机侧**读数据校验逻辑**，核心作用是在完成读数据握手后，将从机返回的实际读数据（`M_AXI_RDATA`）与主机预设的预期数据（`expected_rdata`）做对比，若不一致则置位 `read_mismatch` 标志位，用于检测读数据传输错误（比如数据在总线上传输出错、从机返回错误数据）。
![](assets/Pasted%20image%2020260202164857.png)

###### 12:产生对比数据 expected_rdata
数据 expected_rdata 用于和读出的 M_AXI_RDATA 进行对比以此验证数据的正确性
AXI 主机侧**写数据（axi_wdata）的动态生成逻辑**，核心作用是在复位 / 初始化时给写数据赋固定初始值，在每次写数据握手完成后，基于 “初始值 + 写索引” 生成新的写数据，专门适配 “连续向不同地址写入递增 / 规律数据” 的场景（比如你之前理解的从 DDR 批量读取数据前，先向 DDR 写入递增测试数据）。
![](assets/Pasted%20image%2020260202165101.png)

###### 13:读次数记录 read_index 计数器
这个 demo 中以 start_single_read 信号作为统计的，如果我们完全自定 axi-lite_master 代码可以自行优化，可以写出更好的代码。我们这里是用 vivado 模板产生的代码主要线教会大家如何使用现有的手段和软件工具学习 axi4总线。
AXI 主机侧**读事务索引计数器（read_index）的控制逻辑**，核心作用是在每次触发单次读事务时，让读索引值自增 1，用于标记已发起的读事务次数，或为读地址 / 预期读数据生成动态偏移（比如 DDR 读地址的偏移量），逻辑和你之前接触的写事务索引（write_index）高度对称，但适配读事务场景。
![](assets/Pasted%20image%2020260202230342.png)

###### 14:axi-lite-master 的状态机
**AXI 主机完整的读写 + 校验状态机逻辑**，核心实现了 “批量写数据→批量读数据→数据校验” 的闭环测试流程，包含预期读数据生成、状态机控制读写事务发起、错误标记三大核心功能。我会拆解成新手易懂的模块，逐一解释核心逻辑和整体流程。
- **初始化阶段**：复位后进入 IDLE 状态，等待`init_txn_pulse`触发事务；
- **写阶段（INIT_WRITE）**：批量发起写事务，向从机 / DDR 写入递增数据；
- **读阶段（INIT_READ）**：批量发起读事务，从相同地址读取数据；
- **校验阶段（INIT_COMPARE）**：对比读取数据与预期数据，标记错误并完成流程；
- **预期数据生成**：同步更新`expected_rdata`，为读数据校验提供基准值。

模块 1：预期读数据生成逻辑（expected_rdata）
![](assets/Pasted%20image%2020260202230611.png)

模块 2：主机状态机核心逻辑（mst_exec_state）

|   |   |   |
|---|---|---|
|状态|核心功能|关键信号控制|
|IDLE|复位/等待启动：接收`init_txn_pulse`触发事务，初始化错误/完成标志|`mst_exec_state <= IDLE`；`ERROR=0`，`compare_done=0`|
|INIT_WRITE|批量发起写事务：直到`writes_done`（写完成）才跳转到读阶段|1. 无未完成写事务时，置`start_single_write=1`（单周期脉冲）发起写请求；<br>2. 写响应完成后，清零`write_issued`，准备下一次写；<br>3. `writes_done=1`时跳转到`INIT_READ`|
|INIT_READ|批量发起读事务：直到`reads_done`（读完成）才跳转到校验阶段|1. 无未完成读事务时，置`start_single_read=1`（单周期脉冲）发起读请求；<br>2. 读数据完成后，清零`read_issued`，准备下一次读；<br>3. `reads_done=1`时跳转到`INIT_COMPARE`|
|INIT_COMPARE|数据校验：将错误标志（`error_reg`）赋值给`ERROR`，标记完成并返回IDLE|`ERROR <= error_reg`（锁存错误）；`compare_done=1`（标记流程完成）；<br>跳回`IDLE`|

模块 3：状态机跳转逻辑（核心闭环）
![](assets/Pasted%20image%2020260202230519.png)

###### 15:最后一个写数据
`last_write` 和 `writes_done` 逻辑是 AXI 主机**写事务完成的精准判定逻辑**，核心解决了 “如何确认批量写事务的最后一次传输完成” 的问题
![](assets/Pasted%20image%2020260202231312.png)
![](assets/Pasted%20image%2020260202231336.png)
![](assets/Pasted%20image%2020260202231348.png)

###### 16:最后一个读数据

![](assets/Pasted%20image%2020260202231544.png)
![](assets/Pasted%20image%2020260202231556.png)



## 三、仿真分析


###### 3.1 写数据过程
![](assets/Pasted%20image%2020260203095701.png)

###### 3.2 读数据过程
![](assets/Pasted%20image%2020260203101237.png)















































































