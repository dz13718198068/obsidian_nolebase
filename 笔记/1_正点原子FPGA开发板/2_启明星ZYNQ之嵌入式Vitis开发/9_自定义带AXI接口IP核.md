DDR在PS部分
PL想对DDR访问需要AXI接口
![|450](assets/Pasted-image-20250519153026.png)
![|225](assets/Pasted-image-20250519010100.png)
AXI接口时序
![|525](assets/Pasted-image-20250519010206.png)
![|500](assets/Pasted-image-20250519010312.png)

创建一个带AXI接口的IP核
打开IP核管理
![|550](assets/Pasted-image-20250519153505.png)
在ip管理工程中创建新ip
![|300](assets/Pasted-image-20250519153719.png)
创建带AXI4接口的ip核
![|400](assets/Pasted-image-20250519153920.png)
路径修改为当前工程路径下的“ ip_repo”文件夹
![|500](assets/Pasted-image-20250519153901.png)
全功能AXI
![|475](assets/Pasted-image-20250519154128.png)
编辑ip
![|450](assets/Pasted-image-20250519154221.png)
生成AXI例化模块和AXI时序模块
![|275](assets/Pasted-image-20250519154754.png)
 ip工程路径如下
![](assets/Pasted-image-20250519154934.png)
自动生成的AXI4 ip核大致功能：
根据外部输入按键，当检测到外部信号上升沿的时候，开始对DDR3的内存进行读写
读写的范围时4096个地址的字节 
先写，再读，读完后进行比较。
若读写正确，error信号为低电平。若读写错误，error信号拉高

代码分析：
![|425](assets/Pasted-image-20250519155516.png)
- 参数
- 用户接口信号（主要是AXI4的接口）
- 例化AXI时序模块（AXI的时序在此模块中实现）

参数可以在功能模块中修改默认值
![|675](assets/Pasted-image-20250519155720.png)
![|650](assets/Pasted-image-20250519160035.png)
端口信号
![|625](assets/Pasted-image-20250519160401.png)
后面的端口信号都是AXI4的接口信号
![|650](assets/Pasted-image-20250519160830.png)
例化主接口时序核心代码
![|600](assets/Pasted-image-20250519161029.png)
参数传递（顶层模块参数传递）
![|475](assets/Pasted-image-20250519161143.png)
![|575](assets/Pasted-image-20250519161427.png)
函数：计算输入的值的位宽。位宽是4
![|575](assets/Pasted-image-20250519162750.png)
计算突发请求的位宽
![|575](assets/Pasted-image-20250519170825.png)
该参数用在写突发的计数 和 读突发的计数。作为位宽
![|475](assets/Pasted-image-20250519171023.png)
状态机参数
![|600](assets/Pasted-image-20250519171345.png)
写状态要写4k，读也读4k
![|500](assets/Pasted-image-20250519171600.png)
写地址通道
![|700](assets/Pasted-image-20250519172504.png)
写数据通道
![|700](assets/Pasted-image-20250519173746.png)
写响应通道：从机返回给主机，主机只有bready信号
![|500](assets/Pasted-image-20250519173958.png)
读地址通道
![|675](assets/Pasted-image-20250519174059.png)
读数据通道
![|450](assets/Pasted-image-20250519174124.png)
其余信号
![|700](assets/Pasted-image-20250519174359.png)

==AXI信号看着很多，其实需要关注的信号很少
操作时关注data或valie等影响时序的数值就行==

输入信号打拍
![|700](assets/Pasted-image-20250519174633.png)


==AXI4状态机分析：==
![|700](assets/Pasted-image-20250519180105.png)
![|700](assets/Pasted-image-20250519180124.png)
![|700](assets/Pasted-image-20250519180133.png)




看完状态机在回来看握手机制的时序代码

对==写地址==通道的valid信号进行赋值
![|725](assets/Pasted-image-20250519202006.png)
对==写地址==通道的地址进行赋值
![|550](assets/Pasted-image-20250519202559.png)
对==写数据==通道的valid进行赋值
![|550](assets/Pasted-image-20250519205944.png)
先看==写索引==信号如何赋值
![|550](assets/Pasted-image-20250519211319.png)
其实这个index就是统计传了多少数据用的
这样就可以通过index的值拉高wlast信号了
![|575](assets/Pasted-image-20250519211617.png)
数据产生这里给了个很简单的累加数据
![|575](assets/Pasted-image-20250519211949.png)
bready只是响应一下，所以信号好处理
从机发过来一个bvalid，判断一下，bready拉高。只拉高一个时钟周期
![|600](assets/Pasted-image-20250519212205.png)
==写响应==的错误判断
![|600](assets/Pasted-image-20250519214345.png)
==读地址==通道和==读数据==通道与前面写的类似
![|500](assets/Pasted-image-20250519215026.png)
成功读握手
![|550](assets/Pasted-image-20250519215206.png)
读数据计数
![|600](assets/Pasted-image-20250519215249.png)
rready大部分都是拉高状态。last和rready同时，最后一个读完时才拉低
![|600](assets/Pasted-image-20250519221057.png)
==读错误==逻辑
![](assets/Pasted-image-20250519222603.png)
![](assets/Pasted-image-20250519222658.png)
读响应RRESP与BRESP逻辑一致
![](assets/Pasted-image-20250519222835.png)
错误标志
![](assets/Pasted-image-20250519223117.png)
会在COMPARE状态机中赋值到端口
![](assets/Pasted-image-20250519223221.png)
start_single_burst_write拉高后把burst_write_active拉高
而burst_write_active拉高后又把start_single_burst_write拉低
只是==为了确保只持续一个脉冲==
![](assets/Pasted-image-20250519223518.png)
写完成信号什么时候被拉高
写突发次数计数
总共发起了多少次写
![](assets/Pasted-image-20250520094934.png)
最后一次突发
拉高writes_done
![](assets/Pasted-image-20250520095108.png)
burst_read_active与写的类似，省略
读操作完成
![](assets/Pasted-image-20250520095421.png)
reads_done和writes_done主要控制状态机跳转











































