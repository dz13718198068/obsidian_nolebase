
## 三种 AXI 总线：
![|660](assets/Pasted%20image%2020260131103238.png)
## 数据有效情况：
（1） VALID 先变高 READY 后变高。时序图如下：
![|420](assets/Pasted%20image%2020260131105327.png)
（2） READY 先变高 VALID 后变高。时序图如下：
![|460](assets/Pasted%20image%2020260131105358.png)
（3） VALID 和 READY 信号同时变高。时序图如下：
![|500](assets/Pasted%20image%2020260131105418.png)
## 突发式读写

#### 1:突发式写时序图 
这一过程的开始时，主机发送地址和控制信息到写地址通道中，然后主机发送每一个写数据到写数据通道中。当主机发送最后一个数据时，WLAST 信号就变为高。当设备接收完所有数据之后他将一个写响应发送回主机来表明写事务完成。
![|420](assets/Pasted%20image%2020260131105510.png)
![|420](assets/Pasted%20image%2020260131105544.png)
#### 2:突发式读的时序图 
当地址出现在地址总线后，传输的数据将出现在读数据通道上。设备保持 VALID 为低直到读数据有效。为了表明一次突发式读写的完成，设备用 RLAST 信号来表示最后一个被传输的数据。
![](assets/Pasted%20image%2020260131105613.png)


## AXI-4 总线信号功能

#### 1:时钟和复位
![](assets/Pasted%20image%2020260131110049.png)

#### 2:写地址通道信号 
![](assets/Pasted%20image%2020260131110059.png)
![](assets/Pasted%20image%2020260131110112.png)

#### 3:写数据通道信号： 
![](assets/Pasted%20image%2020260131110309.png)

#### 4:写响应信号：
![](assets/Pasted%20image%2020260131110323.png)

#### 5:读地址通道信号：
![](assets/Pasted%20image%2020260131110344.png)

#### 6:读数据通道信号： 
![](assets/Pasted%20image%2020260131110355.png)

















































































