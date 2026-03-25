# 一、Modelsim 软件的安装
Modelsim 是 Mentor 公司的设计的业界最优秀的语言仿真工具，是单一内核支持 VHDL 与 Verilog 混合仿真的仿真工具，具有编译仿真速度快、编译的代码与平台无关等特性

ModelSim常见的版本主要有以下几种：
1. ModelSim PE (Personal Edition) - 个人版，功能相对少
2. ModelSim SE (Standard Edition) - 标准版，功能最全
3. ModelSim OEM（Original Equipment Manufacture）-原始设备制造商版本，针对不同厂商推出，多种定制版本，比如针对Intel Xlinx等推出的
## 2.1 Modelsim 2020.4 SE下载
![|460](assets/Pasted%20image%2020250527185744.png)
## 2.2 开始安装
双击exe文件运行安装程序
![|460](assets/Pasted%20image%2020250527185840.png)
下一步
![|380](assets/Pasted%20image%2020250527185901.png)
选择安装路径（最好全英文）
![|500](assets/Pasted%20image%2020250527185943.png)
同意
![|460](assets/Pasted%20image%2020250527185959.png)
第一次提示-是否安装桌面快捷方式 选择“是”1
![|420](assets/Pasted%20image%2020250527190017.png)
第二次提示是否将 Modelsim 可执行文件放入 Path 变量，选择“是”时可以从 DOS 提示符执行 Modelsim， 这里我们选择“是”
![|420](assets/Pasted%20image%2020250527190033.png)
这里我们有license选择否，选是会重启
![|500](assets/Pasted%20image%2020250527190051.png)
安装完成
装好后打开桌面的modelsim会弹出没有license
![|340](assets/Pasted%20image%2020250527190113.png)
## 2.1 破解方法
找到crack1文件夹，复制这四个文件到剪切板
![|500](assets/Pasted%20image%2020250527190133.png)
粘贴到win64文件夹中替换文件
![|540](assets/Pasted%20image%2020250527190157.png)
找到patch64_dll.bat属性取消勾选只读
![|620](assets/Pasted%20image%2020250527190213.png)
找到你网络的物理地址复制
win+R，进入cmd，ipconfig/all里有物理地址
![|540](assets/Pasted%20image%2020250527190308.png)
记事本打开patch64_dll.bat，修改第四行，添加物理地址记得去掉短横 “-
![|340](assets/Pasted%20image%2020250527190340.png)
点击确定
双击patch64_dll.bat后生成LICENSE.TXT
文件另存到modelsim安装路径下
![|380](assets/Pasted%20image%2020250527190409.png)
下一步添加环境变量
![|340](assets/Pasted%20image%2020250527190423.png)
![|380](assets/Pasted%20image%2020250527190437.png)
双击Path，添加一条win64文件夹的路径，就在安装目录下
![|500](assets/Pasted%20image%2020250527190458.png)
再添加一条环境变量  
变量名为**MGLS_LICENSE_FILE**或者**LM_LICENSE_FILE**，
具体可以直接现在打开modelsim,会有一段红色警告会提醒你，上面有变量名注意看  
变量值就是安装路径下的LICENSE.TXT文件
![|500](assets/Pasted%20image%2020250527190522.png)
可以愉快的使用了，注意这个是和MAC地址绑定的，如果MAC地址修改了就需要重新生成LICENSE.TXT
（正常来说MAC地址是唯一的，如果你开启了随机MAC地址（通常是用于防止被别人锁定），那么MAC地址就会在重新连接WIFI时变化）