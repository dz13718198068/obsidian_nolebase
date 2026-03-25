**一、UDP协议报文结构**

udp协议报文结构
![](assets/Pasted%20image%2020250526084048.png)

UDP的首部有共8字节(而TCP\IP的首部有20字节)
![](assets/Pasted%20image%2020250526084050.png)

UDP封装如图：

 **伪头部** ： 只是为了提取 IP 数据报中的源IP，目的IP信息并加上协议等字段构造的数据。在实际传输中并不会发送，仅起到校验和计算使用，因此称之为伪首部。

 **源端口号** : 一般是客户端程序请求时,由系统自动指定,端口号范围是 0 ~ 65535,0~ 1023为知名端口号。

 **目的端口** ： 一般是服务器的端口，一般是由编写程序的程序员自己指定，这样客户端才能根据ip地址和 port 成功访问服务器

 **UDP 长度** ： 是指整个UDP数据报的长度 ， 包括 报头 + 载荷，

 **UDP校验和** ： 用于检查数据在传输中是否出错，是否出现bit反转的问题，当进行校验时，需要在UDP数据报之前增加临时的伪首部。
![](assets/Pasted%20image%2020250526084053.png)

代码中结构体定义
![](assets/Pasted%20image%2020250526084057.png)

**二、UDP数据递交流程**

首先申请一个pbuf，其中有个54字节空间。用于保存各层的首部
![](assets/Pasted%20image%2020250526084101.png)
![](assets/Pasted%20image%2020250526084103.png)
![](assets/Pasted%20image%2020250526084106.png)

 pbuf的层头大小为PBUF_TRANSPORT（54字节）

 偏移payload指针添加UDP首部（8字节）

 再一次偏移payload指针添加IP首部（20字节）

**三、UDP控制块结构**
![](assets/Pasted%20image%2020250526084109.png)

 IP_PBC：通用IP控制块

 struct udp_pcb *next：指向下一个节点的指针。lwip可以实现多个udp的连接，每一个连接必须申请一个udp的控制块，控制块以单向链表链接起来。

 flags：控制块状态，例如连接状态或非连接状态

 本地端口号、目的端口号

 udp_recv_fn recv：处理网络接收数据的回调

 void *recv_arg：用户自定义参数，接收回调入参

**四、UDP控制块原理**
![](assets/Pasted%20image%2020250526084112.png)
![](assets/Pasted%20image%2020250526084115.png)