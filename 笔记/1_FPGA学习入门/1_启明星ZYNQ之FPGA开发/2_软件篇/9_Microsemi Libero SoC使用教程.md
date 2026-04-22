
[Microsemi Libero系列教程（全网首发）-CSDN博客](https://blog.csdn.net/whik1194/article/details/102901710)


# 一、创建工程
新建工程，命名，路径
![](assets/Pasted-image-20260420091214999.png)
选择芯片型号
![](assets/Pasted-image-20260420095648771.png)

电平选择：根据文档NI_HRD中的接口电平，可以判断，在libero中电平选择<font color="#ff0000">LVCMOS33</font>
![](assets/Pasted-image-20260420101740982.png)
![](assets/Pasted-image-20260420101828854.png)
导入HDL设计文件，PDC约束文件，没有，直接跳过
创建HDL文件
![](assets/Pasted-image-20260420102357604.png)
写一个简单计数器，用于ila抓数
![](assets/Pasted-image-20260420110620243.png)
创建smartdesign图形化工具
![](assets/Pasted-image-20260420110955477.png)
检查语法错误
![](assets/Pasted-image-20260420111302297.png)
设顶层
![](assets/Pasted-image-20260420111525420.png)
把端口设为i/o引脚
![](assets/Pasted-image-20260420112607682.png)
Generate Component生成组件文件
![](assets/Pasted-image-20260420112710412.png)
找几个output口作为工具验证的出口
![](assets/Pasted-image-20260420151936903.png)
使用逻辑分析仪
![](assets/Pasted-image-20260420152103582.png)
![](assets/Pasted-image-20260420152143535.png)
![](assets/Pasted-image-20260420152315883.png)
![](assets/Pasted-image-20260420153817392.png)
配置内存深度
![](assets/Pasted-image-20260420153916291.png)
![](assets/Pasted-image-20260420160734489.png)
设置完信号以后run
![](assets/Pasted-image-20260420161625771.png)








# 二、引脚分配

![](assets/Pasted-image-20260420155610094.png)


# 三、仿真




# 四、逻辑分析仪ILA



































































