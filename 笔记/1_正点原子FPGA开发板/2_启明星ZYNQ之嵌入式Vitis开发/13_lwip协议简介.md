**一、lwIP简介**

**1、lwIP简介**

**lwIP是什么**：阉割的TCP/IP协议（交换机、路由器、光纤收发器）
**lwIP能做什么**：无线网关、远程模块、嵌入式NAT无线路由器(NAT基础上添加lwIP)、网络摄像头

**TCP/IP协议栈结构**

应用层：HTTP、MQTT、NTP、FTP......（最接近用户的层）
传输层：TCP(可靠，只能在传输层分片)、UDP(不可靠)
网络层：IP(可对UDP分片重组)、ARP(获取对方MAC，数据转发)、ICMP(Ping上是否互通)......
链路层：数据链路层(MAC内核)＋物理层(PHY芯片)
![](assets/Pasted%20image%2020250526084005.png)

**lwIP+MAC+PHY实现了TCP/IP协议栈结构**（lwIP实现了应用层传输层网络层）

**TCP/IP协议栈的数据封装与解封装**

封装：数据添加各层协议的首部。
解封装：在各层间除去自层的首部。
![](assets/Pasted%20image%2020250526084008.png)

**2、lwIP结构框图**
![](assets/Pasted%20image%2020250526084011.png)

**3、如何使用lwIP**

根据：文档资料、例程源码

**二、MAC简介**

**1、MAC简介**

10/100/1000M以太网MAC内核，提供地址及媒体访问的控制方式（看手册）

MAC内核的特性：

1传输速率：支持外部PHY数据实现10/100/1000传输速率
2协议标准：符合MII和RMII接口与快速以太网PHY
3工作模式：全双工or半双工
4站管理接口：支持MDIO接口配置和管理PHY设备
5其他特性

**2、ST的ETH框架**

 以太网DMA数据包以DMA方式发送/接收
 MAC内核以太网真发送时，给数据加上一些控制信息；以太网帧接收时，去掉控制信息
 PHY交互接口：
 数据通道：介质接口RMII/MII
 管理通道：SMI站管理接口
![](assets/Pasted%20image%2020250526084018.png)

**3、SMI站管理接口**

允许应用程序通过时钟线和数据线访问任意PHY寄存器，最多支持32个PHY访问

 MDC：周期时钟引脚
 MDIO：数据输入/输出比特流
**SMI帧格式**
![](assets/Pasted%20image%2020250526084022.png)
PHYAD：PHY地址
REGAD：寄存器地址
DATA数据位：16位数据位
![](assets/Pasted%20image%2020250526084025.png)
![](assets/Pasted%20image%2020250526084028.png)

**4、介质接口MII、RMII**

用于MAC与外接PHY互联，支持10/100数据传输模式。以太网帧转发到PHY设备当中
![](assets/Pasted%20image%2020250526084031.png)

介质接口MII、RMII比较

**相同的特性**

 支持外部PHY接口实现10/100数据传输速率
 符合IEEE协议标准等

**不同的特性**

 引脚数量
 参考时钟
 数据位宽等
![](assets/Pasted%20image%2020250526084035.png)

**介质接口MII、RMII参考时钟**
![](assets/Pasted%20image%2020250526084037.png)