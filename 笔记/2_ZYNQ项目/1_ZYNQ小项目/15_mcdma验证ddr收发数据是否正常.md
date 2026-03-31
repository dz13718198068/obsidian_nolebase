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






















