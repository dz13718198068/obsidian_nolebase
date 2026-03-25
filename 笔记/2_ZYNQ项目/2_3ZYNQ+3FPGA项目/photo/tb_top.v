
// RS422开关箱仿真测试平台
module tb_zdyz_switch();

// 1. 定义仿真信号（对应top模块的输入输出）
reg         clk_50m;     // 50MHz时钟
reg         rst_n;       // 复位信号（低有效）
reg         sw1;         // 拨码开关高位
reg         sw0;         // 拨码开关低位
reg         periph_rx;   // 422输入信号
reg         fmql100_rx;  // 100T外设输入
reg         fmql45s_rx;  // 45S外设输入

wire        periph_tx;   // 422输出信号
wire        fmql100_tx;  // 100T外设输出
wire        fmql45s_tx;  // 45S外设输出

// 2. 生成50MHz时钟（周期20ns）
initial begin
    clk_50m = 1'b0;
    forever #10 clk_50m = ~clk_50m;  // 每10ns翻转一次，频率50MHz
end

// 3. 生成复位信号（先复位，后释放）
initial begin
    rst_n = 1'b0;        // 初始复位
    #100;                // 复位100ns
    rst_n = 1'b1;        // 释放复位
end

// 4. 模拟拨码开关切换（覆盖所有状态）
initial begin
    // 初始状态：sw=00（通道关闭）
    sw1 = 1'b0;
    sw0 = 1'b0;
    #500;  // 稳定500ns
    
    // 切换到sw=01（422↔100T）
    sw1 = 1'b0;
    sw0 = 1'b1;
    #500;
    
    // 切换到sw=10（422↔45S）
    sw1 = 1'b1;
    sw0 = 1'b0;
    #500;
    
    // 切换到sw=11（通道关闭）
    sw1 = 1'b1;
    sw0 = 1'b1;
    #500;
    
    // 结束仿真
    $stop;
end

// 5. 模拟测试输入信号（422和外设的输入）
initial begin
    // 422输入信号：周期40ns的方波
    periph_rx = 1'b0;
    forever #20 periph_rx = ~periph_rx;
    
    // 100T外设输入：周期80ns的方波
    fmql100_rx = 1'b1;
    forever #40 fmql100_rx = ~fmql100_rx;
    
    // 45S外设输入：周期120ns的方波
    fmql45s_rx = 1'b0;
    forever #60 fmql45s_rx = ~fmql45s_rx;
end

// 6. 例化top模块（连接仿真信号）
top u_top(
    .clk_50m      (clk_50m),
    .rst_n        (rst_n),
    .sw1          (sw1),
    .sw0          (sw0),
    .periph_rx    (periph_rx),
    .periph_tx    (periph_tx),
    .fmql100_rx   (fmql100_rx),
    .fmql100_tx   (fmql100_tx),
    .fmql45s_rx   (fmql45s_rx),
    .fmql45s_tx   (fmql45s_tx)
);

// 7. 打印关键状态（可选，方便调试）
initial begin
    $monitor("时间=%0t, sw=%b%b, periph_tx=%b, fmql100_tx=%b, fmql45s_tx=%b",
             $time, sw1, sw0, periph_tx, fmql100_tx, fmql45s_tx);
end

endmodule