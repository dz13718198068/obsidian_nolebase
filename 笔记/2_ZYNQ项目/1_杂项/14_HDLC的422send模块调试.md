## 1.调试进度：

| 序号  | 调试计划                                 | 完成程度 |
| --- | ------------------------------------ | ---- |
| 1   | 编写RS422发子模块                          | 100% |
| 2   | 编写top调用子模块，用vio，pll给子模块提供信号，加lia方便调试 | 100% |
| 3   | 上板测试RS422发模块功能                       | 100% |
| 4   | 编写RS422收子模块                          | 0%   |
| 5   | top例化收模块，编写测试调试代码                    |      |
| 6   | 上板测试RS422收模块功能                       |      |
| 7   | 收发模块相连，完成回环                          |      |
| 8   | isa改AXI                              |      |
| 9   | .....                                |      |
|     |                                      |      |



![](assets/Pasted%20image%2020260128214331.png)





## 2.调试笔记

#### 一、仿照RS422_CHANNEL1_SEND的Block Design写个子模块

![](assets/Pasted%20image%2020260127113106.png)

![|420](assets/Pasted%20image%2020260127113016.png)

#### 二、top模块加pll提供时钟，加ila、vio调试

PL参考时钟，引脚AD18。
接在top输入给422send模块提供时钟，
用PLL在top里转成16MHz
![|340](assets/Pasted%20image%2020260127110341.png)
![|300](assets/Pasted%20image%2020260127110416.png)
![|300](assets/Pasted%20image%2020260127110524.png)

输出口暂时随便找个空引脚AB12
![|305](assets/Pasted%20image%2020260127112253.png)
PLL ip核报错
![](assets/Pasted%20image%2020260127203719.png)
PLL 时钟输入驱动不合法。核配置了 `ZHOLD` 补偿模式，但输入时钟 `pl_clk`（接 AD18 引脚）没有连接到「时钟专用 IO（CCIO）」，或 PLL 的补偿模式与输入时钟的驱动方式不匹配，导致违反 FPGA 的硬件约束。
改`COMPENSATION` 这一项，当前值是 `ZHOLD`。点击它的下拉菜单，选择 `INTERNAL` 即可。
![|460](assets/Pasted%20image%2020260127203818.png)

下载bit文件以后，ila ip核报错。ila ip核的时钟停了
![|460](assets/Pasted%20image%2020260127212531.png)
避免用待测时钟来驱动ila，所以把16M改为PL时钟接ila看看能不能行
![|500](assets/Pasted%20image%2020260127213152.png)
改成pl时钟以后，ila核可以运行了
时钟质量有问题
抓出来的pll输出的16M时钟，时而宽，时而窄，这是为什么
![|460](assets/Pasted%20image%2020260127214414.png)
时钟是16M的，要抓16M时钟需要ila的驱动时钟是16M的整数倍。用50M时钟ila抓16M时钟就会出现这种问题。

换个思路，将pll的复位口直接输入1‘b0，这样pll就“免启动了”
pll在程序开始就能给ila和vio提供时钟了。
把ila和vio的驱动时钟重新换回16M试一下
![|500](assets/Pasted%20image%2020260127221310.png)

为什么ila抓不到pll输出的16M时钟？
vio也有可能未启动，把vio也改成晶振的时钟驱动试试
![|500](assets/Pasted%20image%2020260128195200.png)
![](assets/Pasted%20image%2020260128195944.png)

有可能是这里出问题了，用clk16MHz时钟去抓clk16MHz，大概率是这个问题，应该用一个时钟驱动ila，去抓另一个时钟。用相同的时钟可能会有问题。！！
![|500](assets/Pasted%20image%2020260128195718.png)
![|420](assets/Pasted%20image%2020260128202705.png)
![|460](assets/Pasted%20image%2020260128202737.png)
![|380](assets/Pasted%20image%2020260128203415.png)
试试能不能抓到16M呢

抓到了，到这里可以确认16M时钟是供应正常的了
![](assets/Pasted%20image%2020260128204144.png)
也就意味着16M可以正常驱动这些子模块。
手动给个复位，看看有啥变化

send_clk有了，这个send_clk是干什么的？？？
![](assets/Pasted%20image%2020260128204321.png)
先不管，看看sig_rise有没有，理论上sig_rise拉高一次就是给FIFO输入一次值，看看sig_rise有没有变化

牛逼，给了fifo一个输入，
![](assets/Pasted%20image%2020260128204602.png)
![](assets/Pasted%20image%2020260128211826.png)


修改vio配置后，可以发现发送成功，3个7e，加后面的55aa两次，加校验，输出正确。
![](assets/Pasted%20image%2020260128214231.png)

isa地址解码

怎么区分是DMA模式还是IO口模式呢
dma模式
![](assets/Pasted%20image%2020260130110325.png)
非dma模式
![](assets/Pasted%20image%2020260130110610.png)
核心判断逻辑就两点：
**DMA 使能寄存器的位值** + **DMA 硬件应答信号的电平**，二者同时满足才会进入 DMA 模式，否则一律走非 DMA 的普通 IO 模式，且 DMA 模式判断在代码里是**最高优先级**的分支（`if-else if`最前面）。


























问题汇总

为什么有DMA模式和非DMA模式（IO口模式），工作原理是怎么区分的
![|260](assets/Pasted%20image%2020260130103605.png)
![|340](assets/Pasted%20image%2020260130103614.png)






















