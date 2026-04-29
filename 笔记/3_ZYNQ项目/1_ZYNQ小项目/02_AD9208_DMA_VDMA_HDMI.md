
![](assets/Pasted-image-20250603164741.png)

![](assets/Pasted-image-20250603104855.png)
## 硬件环境搭建
### 搭建硬件
###### 1.基于VDMA驱动HDMI显示例程
基于例程：
[01_使用VDMA驱动HDMI](01_使用VDMA驱动HDMI.md)
[10_ADDA实验ADDA原理](../../2_FPGA学习入门/6_启明星ZYNQ之FPGA开发/10_ADDA实验ADDA原理.md)
[11_ADDA实验程序设计](../../2_FPGA学习入门/6_启明星ZYNQ之FPGA开发/11_ADDA实验程序设计.md)

- DA(AD9708)驱动时钟,最大支持 125Mhz 时钟
- AD(AD9280)驱动时钟,最大支持 32Mhz 时钟

打开Zynq设置，添加时钟，设置为ADC的时钟
==所以FCLK_CLK2最大频率32MHz==
![](assets/Pasted-image-20250603105229.png)
###### 2.添加DMA模块
只打开写通道
![](assets/Pasted-image-20250603165145.png)
![](assets/Pasted-image-20250603165224.png)
###### 3.添加AXI Interconnect模块
连接S00_AXI和S01_AXI分别到VDMA和DMA的MM2S接口，M00_AXI连接到HP0口。
![](assets/Pasted-image-20250603165926.png)
###### 4.增加xlconcat接口
连接到dma的中断口
![](assets/Pasted-image-20250603170008.png)
###### 5.添加自定义IP模块ad9280_sample
功能为采集ad9280数据，缓存到FIFO中，并从FIFO中读出转换为AXI4-Stream流数据。
自定义IP在repo文件夹中。
![](assets/Pasted-image-20250603170813.png)
添加同步复位模块，并将复位时钟连接到adc_clk，复位输出连接到ad9280的adc_rst_n复位接口。
![](assets/Pasted-image-20250603170633.png)
###### 6.添加AXI4-Stream Register Slice模块（可选）
AXI4-Stream Register Slice模块对Stream接口时序会有些提升。
![](assets/Pasted-image-20250603170912.png)
![](assets/Pasted-image-20250603170939.png)
###### 7.将ADC数据接口以及时钟引出
![](assets/Pasted-image-20250603171013.png)
![](assets/Pasted-image-20250603171045.png)
保存
重新Generate Output Products
创建hdl wrapper

###### 8.在wrapper里例化一个信号发生器
基于ADDA实验的verilog代码
例化一个信号发送模块
一个coe信号文件存储rom
![](assets/Pasted-image-20250603171619.png)
修改一下顶层system_wrapper
![](assets/Pasted-image-20250603171457.png)
![](assets/Pasted-image-20250603171552.png)


##### ADC自定义IP功能介绍
由于需要将ADC采集的数据通过DMA传输到ZYNQ，与DMA的接口为AXIS流接口，因此需要将ADC数据转换成AXIS流数据，同时ADC的时钟与AXIS时钟频率不同，因此需要添加FIFO进行跨时钟域数据处理。同时需要实现AXIS Master功能。工作流程为：
1. ARM配置启动寄存器和采集长度寄存器。
2. ADC采集数据并存入FIFO。
3. DMA使用AXIS接口读取FIFO中的数据，直到读取到所配置的数据量。

## Vitis程序开发
1.实验流程为：向frame buffer里写入彩条数据叠加网格叠加波形数据
2.程序中增加了adc_dma_ctrl.c和adc_dma_ctrl.h文件，以及wave.c和wave.h文件，可以在Vitis文件夹下找到
![](assets/Pasted-image-20250603124501.png)
3.首先要做显示背景，本实验中选择蓝布做背景，利用main.c文件的DemoPrintTest函数，将其他删除，只保留蓝色显示部分。
![](assets/Pasted-image-20250604103826.png)
4.在main.c中打开中断控制器，用于DMA的中断。
![](assets/Pasted-image-20250604104043.png)
5.下一步是进行网格和波形的叠加，adc_dma_ctrl.c是基于前面DMA的控制做的修改，
XAxiDma_Adc_Wave函数用于初始化DMA，控制ADC采集，波形叠加。
由于DMA只有写接口，因此在XAxiDma_Initial函数中打开S2MM中断。
![|500](assets/Pasted-image-20250604103516.png)
6.在adc_dma_ctrl.c中调用draw_grid函数叠加网格，draw_grid在wave.c文件中，
需要提供参数宽度width，高度height，即要显示网格的宽与高。
函数中设置每个方格是32* 32像素点，水平和垂直方向每隔4个点显示。
网格显示为灰色，背景为黑色，将图像数据写入画布（CanvasBuffer）缓冲区中。
![](assets/Pasted-image-20250604104408.png)
7.叠加波形函数为draw_wave，width为宽度，height为高度，
BufferPtr为波形数据指针，本实验中指向ADC接收到的数据。
CanvasBufferPtr为画布指针，处理后的数据叠加到上面。
Sign为BufferPtr数据的符号位，Bits为有效数据位，比如ADC的数据宽度为8，则可将此参数设为8。
参数color用于选择要显示的颜色，coe为系数，可以通过调节coe的值，改变波形的高度。
由于AD9280数据宽度为8，本实验中coe设置为1。
![](assets/Pasted-image-20250604104518.png)
判断Sign符号位，赋给不同的指针。
![](assets/Pasted-image-20250604104550.png)
由于得到的数据在图像上显示为离散点，为了使波形显示更平滑，进行了描点处理，将数据与前一个数据进行比较，得到差值，并在同一列描点。
![](assets/Pasted-image-20250604104731.png)
下面为500KHz未描点的正弦波，都是离散的点：
![](assets/Pasted-image-20250604104743.png)
下图为描点之后的效果，平滑了一些。
![](assets/Pasted-image-20250604104753.png)
描点函数为draw_point，需要提供横坐标，纵坐标，宽度，高度等参数
![](assets/Pasted-image-20250604104839.png)
在adc_dma_ctrl.c的XAxiDma_Adc_Wave函数中，调用frame_copy函数将画布数据copy到图像空间，并刷新Cache，之后打开ADC采集。
![](assets/Pasted-image-20250604105131.png)
修改显示分辨率的方法，在display_ctrl.c中修改vMode
![](assets/Pasted-image-20250604105256.png)
如果想改变波形背景显示区域，可以修改网格波形起始位置，修改WAVE_START_ROW改变起始行的位置，修改WAVE_START_COLUMN修改起始列的位置注意WAVE_HEIGHT\ +WAVE_START_ROW不能大于分辨率的高度，如1280* 720，不能大于720，否则显示不正常。
![](assets/Pasted-image-20250604105405.png)
在XAxiDma_Adc_Wave函数中也可修改波形的宽度，比如将其改为1024，WAVE_START_COLUMN修改为50，可见效果如下图
![](assets/Pasted-image-20250604105817.png)
![](assets/Pasted-image-20250604105828.png)
调用draw_wave函数时，Sign符号设置为UNSIGNEDCHAR
![](assets/Pasted-image-20250604105931.png)
在adc_dma_ctrl.h文件中，ADC的参数设置如下：
![](assets/Pasted-image-20250604110019.png)




### 问题及解决
###### 1.添加math.h库
注意：在程序中用到了math.h的函数，需要做以下设置才能使用，右键点开C/C++ Build Settings选项
![](assets/Pasted-image-20250603124523.png)
![](assets/Pasted-image-20250603124609.png)
###### 2.实现报错
xdc编写错误
![](assets/Pasted-image-20250603134114.png)
大概率是xdc问题，修改xdc管教约束就解决了

### 上板验证
![](assets/Pasted-image-20250604110150.png)
![](assets/Pasted-image-20250603200008.png)
修改背景及画布位置
![](assets/Pasted-image-20250603201251.png)
调整画布大小和波形偏移量
![](assets/d7e01a7261f395c98917b95591d2de3.jpg)
增加坐标轴
![](assets/Pasted-image-20250604110251.png)


























