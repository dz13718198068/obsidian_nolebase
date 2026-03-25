在FPGA研发及学习过程中，有一个关键步骤就是下板实现，做硬件“硬现”很重要，一般来说用JTAG口比较常见一些，因此相信肯定有些大侠遇到过JTAG口失灵或者损坏无法使用的事情。最近我就遇到了这类事情，FPGA的JTAG口突然就不能下载程序了，而且这种事情已经不是第一次了，之前在做项目的时候也出现过，而且出现的形式也极其相似，之前还用的好好的，第二天就不行了，真是让人郁闷。为此，本人也是去尝试了很多解决办法，一开始也没有去设想是JTAG口坏了，于是乎，本人换了usb-blaster，可一点反应也没有。难道真的是JTAG口坏了？于是，本人就去查阅相关资料去搞清楚问题的本质在哪里，下面就是本人的一些收获，分享出来，仅供各位大侠参考，一起交流学习。

![](photo/Pasted%20image%2020260126094144.png)

根据查阅资料及本人的一些实践经验所得，在使用JTAG下载接口的过程中，请不要随意带电插拔，否则会损坏FPGA芯片的JTAG口信号管脚。那么如何去确认JTAG口已经损坏了呢。首先你要去排除基本的几项因素，一是，是否匹配连接，有很多设备会对应很多接口，在实际条件下要匹配正确，否则也会出现上述情况；二是，排除下载线的问题，如果是下载线坏了，可以使用多根下载线去尝试，排除这类问题。如果还是不能访问FPGA的JTAG口，那么很有可能你的FPGA芯片的JTAG口已经损坏。此时请用万用表检查TCK，TMS，TDO和Tdi是否和GND短路，如果任何一个信号对地短路则表示JTAG信号管脚已经损坏。  

至于JTAG口是什么，这里我们也来探讨一下，JTAG英文全称是 Joint Test Action Group，翻译过来中文就是联合测试工作组。

JTAG是一种IEEE标准用来解决板级问题，诞生于20世纪80年代。今天JTAG被用来烧录、debug、探查端口。当然，最原始的使用是边界测试。

## 1、边界测试

举个例子，你有两个芯片，这两个芯片之间连接了很多很多的线，怎么确保这些线之间的连接是OK的呢，用JTAG，它可以控制所有IC的引脚。这叫做芯片边界测试。

![图片](https://mmbiz.qpic.cn/mmbiz_png/aU04XPq8pdhiaSRGF9C70ofYqT8qxUvszK8SMyqp6IYG6qCAhgcEMLolrXbp9LVaUBGhdqpKdfsk8MFsGrjOoUg/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=2)

## 2、JTAG引脚  

JTAG发展到现在已经有脚了，通常四个脚：TDI，TDO，TMS，TCK，当然还有个复位脚TRST。对于芯片上的JTAG的脚实际上是专用的。

- TDI：测试数据输入，数据通过TDI输入JTAG口；
    
- TDO：测试数据输出，数据通过TDO从JTAG口输出；
    
- TMS：测试模式选择，用来设置JTAG口处于某种特定的测试模式；
    
- TCK：测试时钟输入；
    
- TRST：测试复位。
    

![图片](https://mmbiz.qpic.cn/mmbiz_png/aU04XPq8pdhiaSRGF9C70ofYqT8qxUvszXX7Eicg6tD0vibY4MGrE0JZLqxKLwheSuwFYq32mxDNyh1sgPibawgarw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=3)

CPU和FPGA制造商允许JTAG用来端口debug；FPGA厂商允许通过JTAG配置FPGA，使用JTAG信号通入FPGA核。  

## 3、JTAG如何工作

PC控制JTAG：用JTAG电缆连接PC的打印端口或者USB或者网口。最简单的是连接打印端口。

TMS：在每个含有JTAG的芯片内部，会有个JTAG TAP控制器。TAP控制器是一个有16个状态的状态机，而TMS就是这玩意的控制信号。当TMS把各个芯片都连接在一起的时候，所有的芯片的TAP状态跳转是一致的。下面是TAP控制器的示意图：

![图片](https://mmbiz.qpic.cn/mmbiz_png/aU04XPq8pdhiaSRGF9C70ofYqT8qxUvsz6BetHrSDBm0icCkpwWiaQXIKFd4tcG6970HzsYOetFo52hfykqNZ9jLQ/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=4)

改变TMS的值，状态就会发生跳转。如果保持5个周期的高电平，就会跳回test-logic-rest，通常用来同步TAP控制器；通常使用两个最重要的状态是Shift-DR和Shift-IR，两者连接TDI和TDO使用。  

IR：命令寄存器，你可以写值到这个寄存器中通知JTAG干某件事。每个TAP只有一个IR寄存器而且长度是一定的。

DR：TAP可以有多个DR寄存器，与IR寄存器相似，每个IR值会选择不同的DR寄存器。（很迷）

## 4、JTAG链相关疑问

计算JTAG链中的IC数目：

一个重要的应用是IR值是全一值，表示BYPASS命令，在BYPASS模式中，TAP控制器中的DR寄存器总是单bit的，从输入TDI到输出TDO，通常一个周期，啥也不干。

可用BYPASS模式计算IC数目。如果每个IC的TDI-TDO链的延迟是一个时钟，我们可以发送一些数据并检测它延迟了多久，那么久可以推算出JTAG链中的IC数目。

得到JTAG链中的器件ID：

大多数的JTAG IC都支持IDCODE命令。在IDCODE命令中，DR寄存器会装载一个32bit的代表器件ID的值。不同于BYPASS指令，在IDCODE模式下IR的值没有标准。不过每次TAP控制器跳转到Test-Logic-Reset态，它会进入IDCODE模式，并装载IDCODE到DR。

5、边界扫描：

![图片](https://mmbiz.qpic.cn/mmbiz_png/aU04XPq8pdhiaSRGF9C70ofYqT8qxUvsznr7KxxT6icSAdBN0Q3tjeXLaaW3JIUqBzgB8Yz2yx6KZGbIFTZ7h9cA/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=5)

TAP控制器进入边界扫描模式时，DR链可以遍历每个IO块或者读或拦截每个引脚。在FPGA上使用JTAG，你可以知晓每个引脚的状态当FPGA在运行的时候。可以使用JTAG命令SAMPLE，当然不同IC可能是不同的。  

![图片](https://mmbiz.qpic.cn/mmbiz_jpg/aU04XPq8pdhiaSRGF9C70ofYqT8qxUvszluyibpTMjpENlejpiasORwCpy42U0BATw1mBjbDVPuImjYPRqRc7Lnsw/640?wx_fmt=jpeg&tp=webp&wxfrom=5&wx_lazy=1#imgIndex=6)

这里没有过多的讲解JTAG调试原理，但是但是对于感兴趣的大侠们，可以获取详细文档查看一下，JTAG调试原理详细技术文档。  

链接：https://pan.baidu.com/s/1PbBFgWnZgROeIiYhscBuZw

提取码：0u5a

如果JTAG口已经损坏了，那只能“节哀顺变”了，但是也不要只顾着伤心，最重要的是分析其中的原因，做其他事情也是一样的道理。那我们就来分析分析，我们在使用的过程中，可能经常为了方便，随意插拔JTAG下载口，在大多数情况下不会发生问题。但是仍然会有很小的机率发生下面的问题，因为热插拔而产生的JTAG口的静电和浪涌，最终导致FPGA管脚的击穿。至此，也有人怀疑是否是盗版的USB Blaster或者ByteBlasterII设计简化，去除了保护电路导致的。但经过很多实际情况的反馈，事实证明原装的USB Blaster 也会发生同样的问题。也有人提出质疑是否是ALTERA的低端芯片为了降低成本，FPGA的IO单元没有加二极管钳位保护电路。这类质疑其实都不是解决问题的本质，最重要的是我们要规范操作，尽可能的去减少因为实际操作不当导致一些硬件设备、接口等提前结束寿命或“英年早逝”，那重点来了，关于JTAG下载口的使用，我们需要如何去规范操作呢。

**上电时的操作流程顺序：**

<font color="#ff0000">- 1.在FPGA开发板及相关设备断电的前提下，插上JTAG下载线接口；</font>
    
<font color="#ff0000">- 2.插上USB Blaster或者ByteBlasterII的电缆；</font>
    
<font color="#ff0000">- 3.接通FPGA开发板的电源。</font>
    

**下电时的操作流程顺序：**

<font color="#ff0000">- 1.断开FPGA开发板及相关设备的电源；</font>
    
<font color="#ff0000">- 2.断开USB Blaster或者ByteBlasterII的电缆；</font>
    
<font color="#ff0000">- 3.拔下JTAG下载线接口，并放置适宜地方存储。</font>
    

虽然上述的操作步骤有点繁琐，有时我们在使用的时候也是不以为然，但是为了保证芯片不被损坏，建议大家还是中规中矩的按照上述的步骤来操作。本人上述出现的问题，经过检测后就是TCK跟GND短路了，虽然发生的概率不是很大，但是为了能够更合理更长久的的使用硬件相关设备，还是建议大家在实操过程中，不要担心繁琐，中规中矩操作，换个角度思考，“多磨多练”也是对自己有好处的。最后，还是给各位唠叨一句，关于JTAG下载口的使用最好不要带电热插拔，起码可以让JTAG口“活”的久一些，毕竟长情陪伴也是挺不错的，不要等到失去了才知道惋惜。



































































