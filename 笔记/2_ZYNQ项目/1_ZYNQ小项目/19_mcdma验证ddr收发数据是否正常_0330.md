
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














































