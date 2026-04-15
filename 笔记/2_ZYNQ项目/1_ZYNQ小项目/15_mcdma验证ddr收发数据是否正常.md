将mcdma例程从7ev移植到7020上
内存地址需改小，适配7020。7020的ddr最大到3FFFFFFF
![](assets/Pasted-image-20260325103443.png)


![](assets/Pasted-image-20260325103533.png)

通道开启数量：4

![](assets/Pasted-image-20260325103600.png)


![](assets/Pasted-image-20260325103615.png)

DDR收发内存的默认值

![](assets/Pasted-image-20260325103629.png)

起始收发数据是从0xc开始

![](assets/Pasted-image-20260325103634.png)

Sendpacket里从c开始传到结束

![](assets/Pasted-image-20260325103641.png)

![](assets/Pasted-image-20260325103646.png)

收发寄存器的数据一致



手动创建4个模拟信号发生ip核
![](assets/Pasted-image-20260325142833868.png)添加ila，AXIS格式的数据要更改成相应的ila接口
![](assets/Pasted-image-20260325142849140.png)![](assets/Pasted-image-20260325142859973.png)


接下来需要验证从4个信号源发送的数据是否通过mcdma存到了DDR相应内存中
![](assets/Pasted-image-20260325143023168.png)

4个信号源的数据是128个F然后发送递减数据


sendpacket在此验证中可注释掉。不需要进行数据回环
数据源-->stream-->S2MM
MM2S-->ila

sendpaket的功能是什么
1. PS 自己造一段测试数据 
2. 给 MCDMA 填写发送任务单（BD） 
3. 启动 MCDMA 把数据从内存发到 AXI4-Stream 接口
![](assets/Pasted-image-20260326094219045.png)

直接注释掉sendpacket这条语句。停止造数，数据从外部模拟信号源输入
![](assets/Pasted-image-20260326094644000.png)
只收不发，所以发送通道初始化也注释掉
![](assets/Pasted-image-20260326094657687.png)
![](assets/Pasted-image-20260326094842463.png)
删掉头文件关于发送的函数原型，以及对应代码
![](assets/Pasted-image-20260326094938201.png)
![](assets/Pasted-image-20260326095023823.png)
注释无用变量
![](assets/Pasted-image-20260326095202973.png)


程序卡在这个地方，需要100个10BD的数据包程序才会跳出循环
此时memory一直没有变化，说明模拟造数的数据并没有传到mcdma中
![](assets/Pasted-image-20260326101054510.png)


![](assets/Pasted-image-20260326101348730.png)
观察到7020未烧录bit程序

确保fpga程序 正常烧录
模拟信号发生模块是128个F递减数据传输
![](assets/Pasted-image-20260326103655821.png)![](assets/Pasted-image-20260326104412157.png)

ddr内存未改变，写入失败？？





# 一、核心问题：
移植4个模拟信号源时手动搭建，复制粘贴，导致四个AXIS_tdes信号一样，没法区分通道id。

解决方法：将tdes改成不一样的id号



# 二、问题跟踪

## 2.1 怀疑是mcdma无法区分通道id
![](assets/65d2bad775137bb05fefc8708ad862c6.png)
![](assets/47a2cd3aa1c34972b639bd7d81885cb9.png)
![](assets/b3b5a03e52f40ca26a9f399ddb9d1112.png)
![](assets/77028061bae41878bfc14985c4c14485.png)

## 2.2实际区分通道id是通过AXIS_tdes
![](assets/ee9f091a90d0275ebee4eb913db8823c.png)
![](assets/99e8e166a0d53a02a7dce71dc40443b5.png)
![](assets/d155f6eb5041e4d017ce3dc743f31a08.png)
![](assets/d88601d2eb06e905eb27475dc94aebf0.png)
![](assets/913b735c617738f5baa4f065d84c04bd.png)
![](assets/9b9eb8f358550e9514af3569160ee2ae.png)








修改bd，用ila监测switch的4个输入和1个输出。
![](assets/Pasted-image-20260327210049129.png)
更新platform，跑程序抓数

![](assets/Pasted-image-20260327225052342.png)
![](assets/Pasted-image-20260327225105487.png)


datagen的位宽是128，switch的输入位宽是512，有何影响



为什么前端输入4个512位的data，且tvalid是4位
![](assets/Pasted-image-20260327231926064.png)
![](assets/Pasted-image-20260327231551050.png)
![](assets/Pasted-image-20260327232009927.png)




<font color="#ff0000">vitis调试debug异常卡顿</font>，此方法可暂时解决。先上电，再打开电脑打开软件。
![](assets/Pasted-image-20260330113205456.png)

tx配置后，0x03100000清零
![](assets/Pasted-image-20260330125952848.png)
![](assets/Pasted-image-20260330130016329.png)

rx配置后寄存器未变化，且卡在while1中，暂停过后程序进入异常中断
![](assets/Pasted-image-20260330130137070.png)


继续打 断点测试，看rx配置函数是否异常

再rxsetup内部打断点，发现chanid是1的时候可以完成一次for循环，
<font color="#ff0000">chanid是2的时候</font>，在Status = SetupIntrSystem(&Intc, McDmaInstPtr, ChanIntr_Id(Rx_Chan, ChanId),这个位置程序进入异常中断。
![](assets/Pasted-image-20260330131033972.png)
![](assets/Pasted-image-20260330131212823.png)
chanid是1的时候是能够完整跑完一遍for循环的。chanid是2的时候会在XMcdma_IntrEnable(Rx_Chan, XMCDMA_IRQ_ALL_MASK);这个地方跑进异常中断
![](assets/Pasted-image-20260330132303598.png)
![](assets/Pasted-image-20260330133125229.png)

程序实在chanid=2的时候，打开 MCDMA 接收中断的总开关XMcdma_IntrEnable(Rx_Chan, XMCDMA_IRQ_ALL_MASK);的过程中进入异常中断的
确认 XMDMA 的中断是否成功注册

怀疑是chanid=2的rx_chan的地址不合法？（定位结果：是校验出了问题）
![](assets/Pasted-image-20260330134711545.png)
打印出自中断函数DoneHandler(void * CallBackRef, u32 Chan_id)
![](assets/Pasted-image-20260330135101742.png)


chanid=2的的时候好像完整跑完了程序，第三次for循环的时候chanid=N/A了
所以问题有可能是chanid=2时出现的，也有可能是chanid=2运行完成以后chanid=N/A的时候出现的
![](assets/Pasted-image-20260330135904177.png)

这里有个data校验，而这个data校验是用于收发循环例程的校验代码
那个例程里是从0xc开始递增造数发出。收通道校验是否是从0xc开始的递增数据。
而目前代码的接收端是接在模拟源上的，不需要校验，注释掉这段校验代码防止异常中断发生
![](assets/Pasted-image-20260330140717341.png)

### 问题，为什么chanid=1的时候校验没出问题，但是chanid=2的时候校验却出问题了呢



![](assets/Pasted-image-20260330164851323.png)
中断函数的这个地方不断增加，i增加，bd递增，达到1000bd以后
![](assets/Pasted-image-20260330165115487.png)
![](assets/Pasted-image-20260330170635103.png)



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
| 通道 1 | **0x06000000** | 0x060027FF | 通道 1 所有 AXIS 数据存在这 |
| 通道 2 | **0x06002800** | 0x06004FFF | 通道 2 所有 AXIS 数据存在这 |
| 通道 3 | **0x06005000** | 0x060077FF | 通道 3 所有 AXIS 数据存在这 |
| 通道 4 | **0x06007800** | 0x06009FFF | 通道 4 所有 AXIS 数据存在这 |
|      |                |            |                    |


# <font color="#ff0000"># 接收数据情况：134通道收到数据，2通道未收到</font>
![](assets/Pasted-image-20260331111835756.png)
![](assets/Pasted-image-20260331111925516.png)
![](assets/Pasted-image-20260331111853086.png)
![](assets/Pasted-image-20260331111904531.png)
![](assets/Pasted-image-20260331111910449.png)




# <font color="#ff0000">收到的数据也不对，按理来说，发送模块是两个 递增，两个递减</font>
# <font color="#ff0000">但是看ddr内容，134通道的数据都是递减的，2没有，说明收到的数据也不对</font>



信号源造数规则：

| 通道号 | 规则  | 步进  |
| --- | --- | --- |
| 通道1 | 递减  | 1   |
| 通道2 | 递减  | 5   |
| 通道3 | 递增  | 1   |
| 通道4 | 递增  | 5   |
接收数据情况：134通道收到数据，2通道未收到
看ddr内存情况是所有的数据都是递减且步进1

![](assets/Pasted-image-20260331142541532.png)
![](assets/Pasted-image-20260331142357472.png)
地址分配规则：

DMA必须要求64字节对齐，偏移地址可能破坏对齐
DDR起始地址0x00000000
避开前16m：`0x00000000 ~ 0x01000000` 放 FSBL / 启动文件，**禁止占用**
必须 64 字节对齐
TX/RX 的 BD/Buffer 必须**完全独立，间隔越大越安全**



配置通道1的时候的指针：起始地址
![](assets/Pasted-image-20260331152344128.png)




![](assets/Pasted-image-20260331152603708.png)
这个for循环功能：
批量分配数据缓存空间 + 向 MCDMA 硬件提交 BD 描述符，告诉硬件：收到数据后往哪里存、存多大。

chanid=1的时候，执行完上述循环，缓存空间的指针已经溢出很大了
![](assets/Pasted-image-20260331152642380.png)


感觉地址分配有问题。增大地址的空间
![](assets/Pasted-image-20260331163853798.png)
出现报错
![](assets/Pasted-image-20260331163908294.png)
![](assets/Pasted-image-20260331163920950.png)




问题原因：

![](assets/Pasted-image-20260331171037954.png)
Mcdma访问不到那个地方
再改成这个，改小点
![](assets/Pasted-image-20260331171023843.png)
无效果





新思路：
![](assets/9dc85fa4b8d1252ec205e1d99b00c83c.png)
所以等配置完4通道以后统一打开通道
![](assets/Pasted-image-20260331185849099.png)
![](assets/Pasted-image-20260331185845052.png)



















































































