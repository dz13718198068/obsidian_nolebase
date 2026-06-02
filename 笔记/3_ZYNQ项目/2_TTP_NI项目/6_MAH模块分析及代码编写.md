![](assets/Pasted-image-20260428220647800.png)



The Memory Access Handler module deals with 2 main topics:
 • memory access to the external RAM based on the address range (single read/write access, consistent read/write access) WHN-1021
 • Main Data Reduction functionality on RX State Message Area readout (consistent read access to both Dual Bus RX State Message Areas)

内存访问处理模块（MAH）主要负责两大核心功能：

1. 依据地址范围，完成对**外部 RAM**的存储器访问操作（包含：单次独立读写、连续一致性读写）；
2. 在读取「RX 状态消息存储区」时，实现核心的数据缩减（Data Reduction）功能，对**双总线两路 RX 状态消息区**执行统一连续读访问。

### 功能描述

### 5.3.3.2.1 Memory Access Generation

![](assets/Pasted-image-20260507155917565.png)
![](assets/Pasted-image-20260507155933636.png)
![](assets/Pasted-image-20260507160101727.png)![](assets/Pasted-image-20260507160108595.png)



![](assets/Pasted-image-20260507162035956.png)
![](assets/Pasted-image-20260507162056200.png)
![](assets/Pasted-image-20260507162103018.png)
![](assets/Pasted-image-20260507162341710.png)

![](assets/Pasted-image-20260507162626775.png)
![](assets/Pasted-image-20260507162637255.png)
![](assets/Pasted-image-20260507162645197.png)

![](assets/Pasted-image-20260507163137360.png)


![](assets/Pasted-image-20260507163329472.png)
![](assets/Pasted-image-20260507163336841.png)
![](assets/Pasted-image-20260507163343014.png)
![](assets/Pasted-image-20260507163450790.png)


![](assets/Pasted-image-20260507163524431.png)
![](assets/Pasted-image-20260507163532679.png)
![](assets/Pasted-image-20260507163547959.png)
![](assets/Pasted-image-20260507163904707.png)
![](assets/Pasted-image-20260507163914414.png)

![](assets/Pasted-image-20260507164224436.png)
![](assets/Pasted-image-20260507164235127.png)
![](assets/Pasted-image-20260507164244109.png)
![](assets/Pasted-image-20260507183454460.png)
![](assets/Pasted-image-20260507183500910.png)

![](assets/Pasted-image-20260507183909157.png)
![](assets/Pasted-image-20260507183915908.png)
![](assets/Pasted-image-20260507184301677.png)
![](assets/Pasted-image-20260507184313335.png)



![](assets/Pasted-image-20260507185152136.png)
![](assets/Pasted-image-20260507185146701.png)


![](assets/Pasted-image-20260507185243648.png)

![](assets/Pasted-image-20260507185534361.png)
![](assets/Pasted-image-20260507185606408.png)


