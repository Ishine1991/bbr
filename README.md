使用方式
保存脚本： 将脚本保存为 setup_bbr.sh 并赋予可执行权限：

bash
复制代码
chmod +x setup_bbr.sh
执行脚本： 使用 root 用户或 sudo 执行脚本：

bash
复制代码
sudo ./setup_bbr.sh
验证配置：

检查文件描述符限制：
bash
复制代码
ulimit -n
检查 BBR 是否启用：
bash
复制代码
sysctl net.ipv4.tcp_congestion_control
（可选）重启系统： 如果需要确认所有配置生效，执行：

bash
复制代码
reboot
脚本优化后更灵活、安全且易于维护，适合各种场景使用。
