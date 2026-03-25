RAM：随机存储器
可以随时把数据写入任一指定地址的存储单元，也可以随时从任一指定地址中读出数据
读写速度是由时钟频率决定
RAM 主要用来存放程序及程序执行过程中产生的中间数据、运算结果等

嵌入式存储器结构由一列列 BRAM（块RAM）存储器模块组成
通过对BRAM配置可实现：
l RAM
l 移位寄存器
l ROM
l FIFO 缓冲器

vivado自带BMG IP 核（Block Memory Generator，块 RAM 生成器）：
可以配置成 RAM 或者ROM (均使用FPGA 内部的 BRAM 资源)
l RAM：随机存取存储器，不仅可存储数据，同时支持对存储的数据进行修改 。
l ROM：只读存储器，只能读出数据，而不能写入数据。

Xilinx 7 BRAM都是真双端口，也可配置成伪双端口or单端口
l 单端口 RAM ：一组数据总线、地址总线、时钟信号以及其他控制信号，
l 双端口 RAM ：两组数据总线、地址总线、时钟信号以及其他控制信号。

以单端口为例
![|540](assets/Pasted%20image%2020250526080920.png)

DINA：写数据信号。
ADDRA：读写地址信号，单端口RAM读写共用同该地址线。
WEA：写使能信号，高电平表示向 RAM 中写入数据，低电平表示从 RAM 中读出数据。
ENA：端口A的使能信号，高电平表示使能端口A，低电平表示端口A被禁止，禁止后端口 A 上的读写操作都会变成无效。另外ENA信号是可选的，当取消该使能信号后，RAM 会一直处于有效状态。
RSTA：复位信号，可配置成高电平或者低电平复位，该信号是可选信号。
REGCEA：输出寄存器使能信号，当REGCEA为高电平时，DOUTA保持最后一次输出的数据，REGCEA是可选信号。
CLKA：时钟信号。
DOUTA：读出的数据。
![|439](assets/Pasted%20image%2020250526080930.png)

Vivado的ip核配置选项表：
![|500](assets/Pasted%20image%2020250526080933.png)

Component Name：设置该IP核的名称，默认即可。
Interface Type：RAM接口总线。保持默认，Nativ接口类型（标准RAM接口总线）；
Memory Type：存储器类型，配置成单端口RAM。可配置成
l Single Port RAM（单端口 RAM）
l Simple Dual Port RAM（伪双端口 RAM）
l True Dual Port RAM（真双端口 RAM）
l Single Port ROM（单端口 ROM）
l Dual Port ROM （双端口 ROM）

ECC Options：Error Correction Capability，纠错能力选项，单端口 RAM 不支持 ECC。
Write Enable：字节写使能选项，勾中后可以单独将数据的某个字节写入 RAM 中，这里不使能。
Algorithm Options：算法选项。这里选择默认的 Minimum Area。可选择：
l Minimum Area（最小面积）
l Low Power（低功耗）
l Fixed Primitives（固定的原语）
![](assets/Pasted%20image%2020250526080956.png)

“Port A”选项页，设置端口 A 的参数，该页面配置如下：
Write Width：端口A写数据位宽，单位Bit，这里设置成8。
Read Width：端口A读数据位宽，一般和写数据位宽保持一致，设置成8。
Write Depth：写深度，这里设置成 32，即RAM所能访问的地址范围为0-31。
Read Depth：读深度，默认和写深度保持一致。
Operating Mode：RAM读写操作模式。这里选择 No Change 模式。共分为三种模式，分别是
l Write First（写优先模式）：指数据先写入RAM中，然后在下一个时钟输出该数据
l Read First（读优先模式）：指数据先写入RAM中，同时输出RAM中同地址的上一次数据
l No Change（不变模式）：指读写分开操作，不能同时进行读写
Enable Port Type：使能端口类型。 这里选择默认的 Use ENA pin。
l Use ENA pin（添加使能端口 A 信号）；
l Always Enabled（取消使能信号，端口 A 一直处于使能状态），
Port A Optional Output Register：端口 A 输出寄存器选项。
“Primitives Output Register”默认是选中状态，作用是打开 BRAM 内部位于输出数据总线之后的输出流水线寄存器，虽然在一般设计中为了改善时序性能会保持此选项的默认勾选状态，但是这会使得 BRAM 输出的数据延迟一拍，这不利于我们在 Vivado的ILA调试窗口中直观清晰地观察信号；而且在本实验中我们仅仅是把BRAM的数据输出总线连接到了ILA的探针端口上来进行观察，除此之外数据输出总线没有别的负载，不会带来难以满足的时序路径，因此这里取消勾选。
Port A Output Reset Options： RAM 复位信号选项，这里不添加复位信号，保持默认即可。
“Other Options”选项页用于设置 RAM 的初始值。本次实验不需要设置，直接保持默认即可。
“Summary”选项页，该页面显示了存储器的类型，消耗的 BRAM 资源等

仿真结果：
![](assets/Pasted%20image%2020250526081019.png)