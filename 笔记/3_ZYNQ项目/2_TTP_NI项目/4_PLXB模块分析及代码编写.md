PLX Interface Bridge（PLXB）
这个模块本质是一个**双向协议桥**

左侧：是 **PLX Local Bus 的从设备**，接收 PLX 芯片（主设备）的读写请求。
右侧：**内部 ARB（仲裁 / 存储）模块的主设备**，把 PLX 的请求转发给 ARB，再把 ARB 的响应返回给 PLX。

观察时序图，时序图显示
PLXB的作用是，对数据、地址进行打拍；对cs、ready信号进行一些规整操作等
![](assets/Pasted-image-20260427151911636.png)
![](assets/Pasted-image-20260429135648893.png)
地址和数据打一拍
# 功能描述
根据文档的功能描述，去编写代码

All ”plxi” signals are registered at the module input to relax the input timing for routing

A burst access is triggered from the bus master with r.plxi.cs b asserted to low and r.plxi.ads b asserted to low for one clock cycle. The PLX Interface Bridge module generates arbo.cs based on this and re-triggers the arbo.cs output automatically using the arbi.ready pulse until the last burst access is detected. The last burst access is marked with r.plxi.blast b asserted to low. r.plxi.lw r is directly driving the arbo.wr rdb output to signal a read WHN-1020 or write access WHN-1010.
![](assets/Pasted-image-20260427194837007.png)

plxo.oe is used to control the plxo.ld out tri-state buffer on the top level. The PLX LD output is only driven during the PLX Access Data Phase of a a PLX Interface read access WHN-1021 when plxo.oe is asserted (at same clock cycle than plxo.ready b is asserted) WHN-1005

plxo.ready b is generated to terminate each single access. It is asserted low level for one clock cycle to validate the databus output plxo.ld out and then asserted to high again.

plxo.ready en is used to control the plxo.ready b tri-state buffer on the top level. Since more than 1 unit is sharing the ready b signal, plxo.ready en output is only driven for 2 clock cycles. The first clock cycle is to output the plxo.ready b to low WHN-1002 during the PLX Access Data Phase, and the second to set plxo.ready b to inactive (high) WHN-1007 again. To have only an external pull-up for plxo.ready b to return to high level does not work because of extensive rise time based on a pull-up and board capacities.


Figure 5.2 shows the interface timing for generic burst accesses. Depending on the addressed memory area the access response timing will increase, i.e the time frame between arbo and arbi signals will be extended. See also timings in Section 5.3.3

所有来自 PLX 侧的输入信号（`plxi_*`）均在模块输入端做**寄存器打拍寄存**，用以放宽布线时序、缓解输入时序压力。

总线主设备发起**突发传输**的条件：寄存后的片选信号 `r_plxi_cs_b` 与地址选通信号 `r_plxi_ads_b` 同时拉低，且仅维持**一个时钟周期**。

PLX 接口桥接模块（你的 PLXB）以此为触发条件，产生内部仲裁请求信号 `arbo_cs`；并依靠内部应答脉冲 `arbi_ready` 自动重复触发 `arbo_cs`，循环发起传输，直到识别到**突发传输最后一拍**为止。

一次突发传输的末尾，由 `r_plxi_blast_b` 拉低进行标记。

读写控制信号 `r_plxi_lw_r` 直接直通驱动 `arbo_wr_rdb`，向内部仲裁模块标识当前为**读操作**或**写操作**。

顶层模块中，`plxo_oe` 用于控制 PLX 侧数据输出 `plxo_ld_out` 的**三态缓冲器**。

仅在 PLX 接口**读操作的数据阶段**，`plxo_oe` 才会拉高有效；该信号与 `plxo_ready_b` 同步置位，用于 FPGA 向外驱动数据总线。

`plxo_ready_b` 用于结束每一次单次总线访问。

该信号**低电平有效**，仅拉低一个时钟周期，用来有效锁存外部数据总线输出 `plxo_ld_out`，随后立刻重新拉高恢复无效状态。

顶层电路中，`plxo_ready_en` 负责控制 `plxo_ready_b` 的三态缓冲器。

由于系统内多个功能模块会**共用同一条 ready_b 总线**，因此 `plxo_ready_en` 仅固定驱动**两个时钟周期**：

第一个时钟周期：在 PLX 访问数据阶段，强制拉低 `plxo_ready_b` 完成握手应答；

第二个时钟周期：再将 `plxo_ready_b` 重新置为高电平、退出有效。

如果仅依靠外部上拉电阻让 `ready_b` 自行恢复高电平，会受板级寄生电容影响，导致信号上升沿过慢、时序不满足，因此必须由 FPGA 主动两拍控制。

图 5.2 给出了通用突发访问的接口时序。

根据访问的存储区域不同，模块响应延时会变长，也就是内部 `arbo_*` 请求信号与 `arbi_*` 应答信号之间的间隔会加大；详细时序参数参考 5.3.3 章节。

# 仿真波形
2026年4月30日
![](assets/5c8d316465434b493cf81e19ec7da72b.png)
<font color="#ff0000">这个仿真是错误的，需要重新写代码</font>
<font color="#ff0000">ads绝对不是这么给的</font>
![](assets/Pasted-image-20260504155344260.png)
修改后的仿真结果
仿真基本正确
![](assets/Pasted-image-20260505213123295.png)

![](assets/34a9c0c7-e26e-4b42-9215-5a12e0414d9a.png)

# 三、有些总线在未使用时应该配置成高阻态
![](assets/Pasted-image-20260512164532294.png)
PLX_LD满足
PLX_READY_B不满足未激活时高阻态。
修改代码再次测试
![](assets/Pasted-image-20260512193220862.png)
给予此程序再次测试pci是否给fpga下降沿，抓下降沿测试：

工具问题导致修改代码后无法正常运行ila。暂未找到工具如何正确修改方式
问豆包说是旧的探针没有删干净，但是怎么弄都无法解决，
<font color="#ff0000">该问题暂时搁置</font>，重新建立程序跳过该问题。
解决方法（补）：需要重新Program Device一下，把程序加上改好的探针烧录进去

重新建立程序后可正常抓数，等待cs_b下降沿到来05/12。05/13早上记得和软件联调一把

0523测试：
现象依旧，arm运行到某地方卡死，ila一直处于waiting for trigger状态。
![](assets/Pasted-image-20260513100637522.png)
**测试遇到的问题：**
Cs_b和ads_b这两个信号同时拉低的时候，意味着开始传输数据。FPGA侧的触发条件设置为这两个信号下降沿检测。
通过arm向PCI5096→FPGA传输指令，arm程序会卡在启用内存访问这个地方，打印信息仅打印一半后卡死。
FPGA侧一直是wariting for trigger状态，始终未获取到Cs_b和ads_b的下降沿。
**目前疑问的点：**
首先PCI芯片作为arm和fpga的桥梁，理论上arm在配置pci芯片的时候与后端FPGA程序关联不大，为何arm会卡在配置PCI芯片上。
其次FPGA侧收到的任何信号都应该是以cs_b和ads_b这两个信号拉起作为起始的，对fpga的任何配置和读取操作都是cs_b和ads_b拉起作为传输开始，为何无法抓到这两个信号信号拉低

# 四、先烧录FPGA程序，确认总线状态
目前为止没有能触发的条件来触发抓数
所以可以在代码里写一个简单的计数器，创造触发条件，出发以后可以抓到其他信号在fpga内部的默认状态了。
![](assets/Pasted-image-20260513170537298.png)
![576](assets/Pasted-image-20260513170550108.png)
![](assets/Pasted-image-20260513170601108.png)
为何内部写个计数器作为触发条件也迟迟未触发？
解决：cnt和cnt_r的位数匹配以后就能抓到了，都设为4位的，原因未知

下图为总线状态，看波形，总线的所有input入口在没有任何操作的情况下默认都是1
![](assets/Pasted-image-20260513202146041.png)
arm发送指令后卡死，此刻再抓数
![](assets/Pasted-image-20260513203446036.png)
cs_b拉低，blast_b拉低，读地址00800
看来cs_b是拉低了的。

下降沿触发
![](assets/Pasted-image-20260514160011219.png)
现在又两种现象
1、所有命令一块输入，抓不到数据，访问失败，未抓到数
![](assets/Pasted-image-20260514180123559.png)
2、按顺序逐个输入命令，程序卡死，抓到数据，状态机没有工作
![](assets/Pasted-image-20260514170950633.png)
![](assets/Pasted-image-20260514171045768.png)
![](assets/Pasted-image-20260514201004140.png)

state永远保持不变，是否和逻辑问题有关
仿真一下看看状态机是否改变
![](assets/Pasted-image-20260514204557769.png)

cui源代码+仿真
![|700](assets/Pasted-image-20260514205755703.png)

ads延迟一拍仿真（真实总线传过来的ads_b是延迟cs_b一拍的）
![](assets/Pasted-image-20260514211418693.png)

<font color="#ff0000">仿真state状态机是正常切换的，为什么上板状态机未运行</font>
是因为reset常1导致，在代码里将复位条件修改reset-->!reset再次上板测试
![](assets/Pasted-image-20260515112807039.png)
复位条件取反以后状态机工作了
![](assets/Pasted-image-20260515122020880.png)
![](assets/Pasted-image-20260515122053790.png)
但程序依然卡死，
感觉还是状态机的判定条件错了，此时状态机在一直认为在传输数据，实际是blast判定条件有问题
![](assets/732c889311152e776fad3954deb42dba.png)
修改判定条件

![](assets/Pasted-image-20260515134846329.png)
修改判定条件以后，状态机穿了一次数据，并且握手回应了ready_b
![](assets/Pasted-image-20260515134802406.png)![](assets/Pasted-image-20260515135049240.png)
![](assets/Pasted-image-20260515135131170.png)

代码增加三态以后，log打印运行正常
![](assets/Pasted-image-20260519145046684.png)

arm换上测试程序
devmem 0x72200004 32
devmem 0x72200008 32
devmem 0x7220000C 32
打印结果如下，FPGA没抓到下降沿
![](assets/24e03db0c9fd4479301d9b01f54b5777.png)

换回最初版arm代码
![](assets/Pasted-image-20260519154901120.png)

arm程序停了也能抓到
每次抓到数据基本一致
说明FPGA和arm在重复的握手通信？？
但是数据部分有差异
![](assets/Pasted-image-20260519155139764.png)
![](assets/Pasted-image-20260519155413174.png)
![](assets/Pasted-image-20260519155500193.png)
![](assets/Pasted-image-20260519155731199.png)

20260521
程序运行首次抓
![](assets/Pasted-image-20260521110036652.png)
程序运行时还能继续抓到数据
![](assets/Pasted-image-20260521110424281.png)
关闭主程序以后抓不到数据了
运行程序后继续抓到
![](assets/Pasted-image-20260521110633354.png)
程序运行时还能继续抓到数据
![](assets/Pasted-image-20260521110721726.png)
修改task2函数代码，取消无限循环发送数据，加入暂停循环发送和开启循环发送指令代码
暂停循环发送指令后再抓
![](assets/Pasted-image-20260521110908658.png)
开启循环发送以后继续抓
![](assets/Pasted-image-20260521112022758.png)
修复系统后，程序运行起始
![](assets/Pasted-image-20260521150311557.png)
暂停循环发送
![](assets/Pasted-image-20260521150524696.png)
关闭task3的读寄存器的函数HOST_INT_ADDR后首次运行抓数
程序死掉
![](assets/Pasted-image-20260521161948253.png)
task3注释掉以后，不会再自动读fpga寄存器了，
<font color="#ff0000">但是目前dma无法启动，需要修复系统</font>
无法单次发送地址数据

arm端提供的新的镜像文件和设备树与dma编译版本不匹配，导致dma_module.ko启动失败，无法正常发送地址数据
甲方给出从emmc文件系统启动linux系统的方案，但是操作步骤较为复杂，没有合适的好操作的教程，暂时没有自己动手制作rootfs.ext4文件系统，用的tftp启动系统
从下层板卡中尝试把正常的镜像文件和设备树文件导出来，重新在上层板卡中通过tftp启动，可以正常启动dma_module.ko
后续可以正常测试单次发送数据抓取看数据是否一致

20260522
上电测试
![](assets/Pasted-image-20260522104953641.png)

关闭task3以及暂停循环发送。
符合预期，此刻抓不到任何数据

开始循环发送单个数据
![](assets/Pasted-image-20260522105336612.png)
此刻arm发送数据是12345678和87654321两个数据，抓数发现引脚分配接反
发现确实收到地址数据，但引脚分配接反，FPGA重新修改引脚分配

修改引脚分配后，上电首次抓数
![](assets/Pasted-image-20260522111150747.png)
![](assets/Pasted-image-20260522111157249.png)
关闭task3及暂停循环发送。依旧抓不到任何数据，符合预期
开始循环发送数据是12345678和87654321两个数据，符合预期
![](assets/Pasted-image-20260522111830679.png)

修改发送数据为5a5aa5a5
![](assets/Pasted-image-20260522112237083.png)

修改fpga触发条件
first value=5a5a5a5a
second value=5a5a5a5a
验证工具可以抓具体数据
可以抓到通道1的数据
![](assets/Pasted-image-20260522160109751.png)
修改触发条件，可继续抓到通道2的数据6a6a6a6a
![](assets/Pasted-image-20260522160335535.png)
通道3·
![](assets/Pasted-image-20260522161028257.png)
增加采样深度为512，看是否能抓到3个通道的数据
![](assets/Pasted-image-20260522202703083.png)
连续发4个数据测试
![](assets/Pasted-image-20260522204637637.png)
连续发送3个数据测试
![](assets/Pasted-image-20260522204938753.png)
![](assets/Pasted-image-20260522214036152.png)
![](assets/Pasted-image-20260522214051345.png)
localbus入口逻辑时序问题：
数据位能对上，地址位首位能对上，但是第二个地址位有偏移，

fpga问题：
FPGA在抓一个数据的时候时序正确
FPGA在抓两个数据的时候会进行4此握手，需要修改时序

20260525
![](assets/Pasted-image-20260525203241366.png)
![](assets/Pasted-image-20260525202726888.png)
上图1是连续发两个数据的时序图，arm下发的blast_b时序只有持续了一拍；
上图2是单发一个数据的时序图，arm下发的blast_b时序持续了7拍；
根据blast_b和地址线la的规律推断出，在下发最后一个数据的时候，blast_b拉低，此时blast_b会在地址变化的同时被拉高，导致上图1的情况blast_b只持续1拍，状态机刚刚回复第一次握手，来不及抓到blast_b信号，导致状态机正确进入接收最后一个数据的状态。

解决思路和问题：
fpga可以提前寄存blast_b的状态确保状态机按逻辑运行。

问题：
目前arm给到fpga的地址递增比较混乱

下图标注代码会导致一直占用总线查询a8，怀疑是总线一直查询a8寄存器导致的握手回应后，地址瞬间变化。加一些延迟后继续测试。
![](assets/Pasted-image-20260525204737313.png)
加延时后无效果
![](assets/Pasted-image-20260525210356899.png)

注释掉while循环继续测试，看看while循环是否和握手有关系，导致地址传输有问题。没有任何影响
![](assets/Pasted-image-20260526103046260.png)

2026/05/26
arm只发一个数据测试。FPGA可以正常抓到该数据地址。
目前单发数据，慢速模式已经不影响FPGA内部进行测试和代码编写。
但是看时序，arm下发的数据还是有问题
问题一：发完第一个数据，CS_b没有拉高
问题二：发完第一个数据，地址还会增加1
问题三：发完第一个数据，数据线还在保持，没有释放
![](assets/Pasted-image-20260526104508986.png)

arm端改变发送寄存器地址，改成05000
FPGA可以正常抓取正确数据地址
其他问题与上述发送单个数据一致
![](assets/Pasted-image-20260526105227193.png)
改成01000。
![](assets/Pasted-image-20260526105649442.png)



