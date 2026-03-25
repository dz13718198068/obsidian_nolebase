环境为正点原子7010开发板
思路：启明星开发板的PS内OCM里有256k的SRAM，通过PL端设计的Localbus可以直接用过AXI访问
OCM分为两片OCM0和OCM1且物理地址固定
（OCM0：0xFFFC0000~0xFFFDFFFF，OCM1：0xFFFE0000~0xFFFFFFFF）
![](assets/Pasted-image-20251229231803.png)




