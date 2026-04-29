![](assets/Pasted-image-20260428220647800.png)



The Memory Access Handler module deals with 2 main topics:
 • memory access to the external RAM based on the address range (single read/write access, consistent read/write access) WHN-1021
 • Main Data Reduction functionality on RX State Message Area readout (consistent read access to both Dual Bus RX State Message Areas)

内存访问处理模块（MAH）主要负责两大核心功能：

1. 依据地址范围，完成对**外部 RAM**的存储器访问操作（包含：单次独立读写、连续一致性读写）；
2. 在读取「RX 状态消息存储区」时，实现核心的数据缩减（Data Reduction）功能，对**双总线两路 RX 状态消息区**执行统一连续读访问。

### 功能描述


























