
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




