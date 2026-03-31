


# 一、核心问题：
移植4个模拟信号源时手动搭建，复制粘贴，导致四个AXIS_tdes信号一样，没法区分通道id。

解决方法：将tdes改成不一样的id号



# 二、问题跟踪

## 2.1 怀疑是mcdma无法区分通道id
![](assets/65d2bad775137bb05fefc8708ad862c6.png)
![](assets/47a2cd3aa1c34972b639bd7d81885cb9.png)
![](assets/b3b5a03e52f40ca26a9f399ddb9d1112.png)
![](assets/77028061bae41878bfc14985c4c14485.png)

## 2.2实际区分通道id是通过AXIS_tdes
![](assets/ee9f091a90d0275ebee4eb913db8823c.png)
![](assets/99e8e166a0d53a02a7dce71dc40443b5.png)
![](assets/d155f6eb5041e4d017ce3dc743f31a08.png)
![](assets/d88601d2eb06e905eb27475dc94aebf0.png)
![](assets/913b735c617738f5baa4f065d84c04bd.png)
![](assets/9b9eb8f358550e9514af3569160ee2ae.png)


































