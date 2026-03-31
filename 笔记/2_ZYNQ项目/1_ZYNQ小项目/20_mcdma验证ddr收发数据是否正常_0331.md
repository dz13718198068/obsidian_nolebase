
0123探针ila口接4路信号源，4号探针接switch出口，验证信号源是正确的
![](assets/Pasted-image-20260331100039592.png)
![](assets/Pasted-image-20260331100305122.png)
![](assets/Pasted-image-20260331100134855.png)


![](assets/Pasted-image-20260331100205295.png)





为什么tlast后面还有两个数据？？？
![](assets/Pasted-image-20260331102906020.png)



为什么ila没有抓到tdest的值？
![](assets/Pasted-image-20260331102315687.png)


两个数据源切换，switch取datagen3前部分和datagen0后部分拼成一个，这样是否可行，是不是数据传输时候要带着tdest来区分通道编号，那为什么ila又看不到tdest的值？
![](assets/Pasted-image-20260331102637129.png)
![](assets/Pasted-image-20260331102718284.png)




修改bd数量
![](assets/Pasted-image-20260331105033513.png)
bd改小以后收到数据了
![](assets/Pasted-image-20260331105639145.png)

一个bd是64字节
100个bd是6400字节
单通道BD占用 = 100×64 = **6400 字节 = 0x1900**
单通道数据缓冲区 = 10包×1024字节 = **10240 字节 = 0x2800**
4个通道100个bd

找到rx通道起点，算出ddr对于4个收通道的地址分配

![](assets/Pasted-image-20260331111406496.png)

| 通道号  | 数据起始地址         | 结束地址       | 核心作用               |
| ---- | -------------- | ---------- | ------------------ |
| 通道 0 | **0x06000000** | 0x060027FF | 通道 0 所有 AXIS 数据存在这 |
| 通道 1 | **0x06002800** | 0x06004FFF | 通道 1 所有 AXIS 数据存在这 |
| 通道 2 | **0x06005000** | 0x060077FF | 通道 2 所有 AXIS 数据存在这 |
| 通道 3 | **0x06007800** | 0x06009FFF | 通道 3 所有 AXIS 数据存在这 |
|      |                |            |                    |


# <font color="#ff0000"># 接收数据情况：134通道收到数据，2通道未收到</font>
![](assets/Pasted-image-20260331111835756.png)
![](assets/Pasted-image-20260331111925516.png)
![](assets/Pasted-image-20260331111853086.png)
![](assets/Pasted-image-20260331111904531.png)
![](assets/Pasted-image-20260331111910449.png)






