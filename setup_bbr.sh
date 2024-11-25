#!/bin/bash
# Optimized script with IPv6 check and fallback

# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root!"
    exit 1
fi

# 检查 BBR 支持
if ! modprobe tcp_bbr >/dev/null 2>&1; then
    echo "Error: BBR is not supported on this system."
    exit 1
fi

# 设置时区
timedatectl set-timezone Asia/Shanghai

# 配置 IPv4 的内核参数
cat >/etc/sysctl.conf <<EOF
fs.file-max = 655360
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_rmem = 8192 262144 536870912
net.ipv4.tcp_wmem = 4096 16384 536870912
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_notsent_lowat = 131072
EOF

# 检查 IPv6 是否启用
if [ -d /proc/sys/net/ipv6 ]; then
    echo "IPv6 is enabled. Configuring IPv6 parameters..."
    cat >>/etc/sysctl.conf <<EOF
net.ipv6.tcp_congestion_control = bbr
net.ipv6.tcp_slow_start_after_idle = 0
net.ipv6.tcp_rmem = 8192 262144 536870912
net.ipv6.tcp_wmem = 4096 16384 536870912
net.ipv6.tcp_adv_win_scale = -2
EOF
    sysctl -p
else
    echo "Warning: IPv6 is not enabled or supported. Skipping IPv6 configuration."
fi

# 应用内核参数
sysctl -p

# 确认 BBR 启用状态
ipv4_bbr=$(sysctl net.ipv4.tcp_congestion_control | grep -o "bbr")
ipv6_bbr="skipped"
if [ -d /proc/sys/net/ipv6 ]; then
    ipv6_bbr=$(sysctl net.ipv6.tcp_congestion_control | grep -o "bbr" || echo "not enabled")
fi

if [[ "$ipv4_bbr" == "bbr" ]]; then
    echo "BBR successfully enabled for IPv4!"
else
    echo "Error: BBR was not enabled for IPv4."
    exit 1
fi

if [[ "$ipv6_bbr" == "bbr" ]]; then
    echo "BBR successfully enabled for IPv6!"
else
    echo "Warning: BBR was not enabled for IPv6. Ensure IPv6 is supported and enabled."
fi

echo "System configuration updated successfully. A reboot is recommended for full effect."
