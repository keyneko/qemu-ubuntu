```bash
sudo apt-get install qemu-user-static debootstrap

sudo mkdir ubuntu-rootfs

# 1.利用debootstrap工具
sudo qemu-debootstrap --arch arm64 trusty ubuntu-rootfs/ --variant=minbase --verbose 

# or 2.从Ubuntu官网下载
wget http://cdimage.ubuntu.com/ubuntu-base/releases/18.04.5/release/ubuntu-base-18.04.5-base-arm64.tar.gz
sudo tar -xzvf ubuntu-base-18.04.5-base-arm64.tar.gz -C ubuntu-rootfs

# linux的binfmt机制和qemu static解释器, 在chroot环境执行arm64版本的binary
sudo cp /usr/bin/qemu-aarch64-static ./usr/bin/
sudo cp -b /etc/resolv.conf ./etc/resolv.conf

# 修改apt软件源
sudo vim /etc/apt/source.list

#中科大源
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic main universe restricted
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic main universe restricted
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse


# 挂载proc, sys, dev, dev/pts等文件系统，可以编写一个bash脚本ch-mount.sh来完成挂载和后面的卸载操作
sudo bash ch-mount.sh -m ubuntu-rootfs/

# 安装所需软件包
apt-get update
apt-get install language-pack-en-base sudo ssh net-tools ethtool wireless-tools ifupdown network-manager iputils-ping rsyslog bash-completion htop vim resolvconf tzdata --no-install-recommends

# 推荐软件
# language-pack-en-base  英文翻译的mo文件
# sudo                   sudo命令
# ssh                    ssh的client和server
# net-tools              ifconfig，netstat，route，arp等
# ethtool                ethtool命令，显示、修改以太网设置
# wireless-tools         iwconfig等，显示、修改无线设置
# ifupdown               ifup，ifdown等工具
# network-manager        Network Manager服务和框架，高级网络管理
# iputils-ping           ping和ping6
# rsyslog                系统log服务
# bash-completion        bash命令行补全
# htop                   htop工具，交互式进程查看器
# tzdata                 设置时区


# 添加用户
adduser keyneko

vi /etc/sudoers
# User privilege specification
root    ALL=(ALL:ALL) ALL
keyneko ALL=(ALL:ALL) ALL

# 设置主机名称
echo "ubuntu-arm-zynqmp" > /etc/hostname

# 设置本机入口ip
echo "127.0.0.1 localhost" >> /etc/hosts
echo "127.0.1.1 ubuntu-arm-zynqmp" >> /etc/hosts

# 允许自动更新dns
dpkg-reconfigure resolvconf

# 设置时区
dpkg-reconfigure tzdata

# 配置串口调试服务
vi /etc/init/ttyPS0.conf

start on stoppedrc or RUNLEVEL=[12345]
stop on runlevel[!12345]
respawn
exec /sbin/getty -L 115200 ttyPS0 vt102

# 配置SD卡分区挂载
vi /etc/fstab

# stock fstab - you probably want to override this with a machine specific one

/dev/root            /                    auto       defaults              1  1
proc                 /proc                proc       defaults              0  0
devpts               /dev/pts             devpts     mode=0620,ptmxmode=0666,gid=5      0  0
tmpfs                /run                 tmpfs      mode=0755,nodev,nosuid,strictatime 0  0
tmpfs                /var/volatile        tmpfs      defaults              0  0

# uncomment this if your device has a SD/MMC/Transflash slot
#/dev/mmcblk0p1       /media/card          auto       defaults,sync,noauto  0  0


# 网络设置
vi /etc/network/interfaces

注释掉source-directory /etc/network/interfaces.d行
添加以下内容:

# 本地回环
auto lo 
iface lo inet loopback 

# 两种方法任选一个

# 1、获取动态配置： 
auto eth0 
iface eth0 inet dhcp 

# 2、获取静态配置： 
# auto eth0 
# iface eth0 inet static 
# address 192.168.0.1 
# netmask 255.255.255.0 
# gateway 192.168.0.1 


# 退出chroot
exit
sudo bash ch-mount.sh -u ubuntu-rootfs/


# 登录后不能连网
# 更改DNS配置
/etc/resolv.conf
nameserver 8.8.8.8

# 修改apt软件源
sudo apt-get update

# 修复sudo权限
sudo chown root:root /usr/bin/sudo
sudo chmod 4755 /usr/bin/sudo
```
