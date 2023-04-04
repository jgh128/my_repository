# **************调试代码************************
# cat /etc/sysconfig/network-scripts/ifcfg-eth0
# nmcli c mod "System eth0" \
# ip4 172.24.10.150/24 \
# gw4 172.24.10.100 \
# ipv4.dns 172.24.10.254 \
# ipv4.method manual autoconnect yes
# rm -rf ~/.ssh/known_hosts && rm -rf ~/.ssh/known_hosts.old
# echo "192.168.0.1 255.255.255.0 192.168.0.11" > ${HOMEPATH}add_ip_net.txt
# echo "192.168.0.1,255.255.255.0,192.168.0.11" > ${HOMEPATH}add_ip_net.txt
# echo "192.168.0.1/24 192.168.0.11" > ${HOMEPATH}add_ip_net.txt
#************************************************
#********** 开始配置 network-scripts/ifcfg-eth0 *******************
echo -e "注意，该脚本适用于个人便利性及新手使用。 \n"
# 原则上是适配centos 8的，为了一定程度上的便利，将从network manager抓取设备名。
# 获取首行的网卡设备，提取到网卡设备别名。
# ifconfig -s、netstat -i 显示网卡清单
# nmcli device |awk 'NR==2{print $4,$5,$6}'
a_eth=$(nmcli device |awk 'NR==2{print $1}')
# sed 检查文本是否存在关键字，有则删除行
sudo sed -i '{/IPADDR=/d;/GATEWAY=/d;/PREFIX=/d;/METMASK=/d;}' "/etc/sysconfig/network-scripts/ifcfg-$a_eth"
# sed 匹配 “BOOTPROTO=dhcp”，整行替换
sudo sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/g' "/etc/sysconfig/network-scripts/ifcfg-$a_eth"
echo -e "支持 192.168.0.1/24 格式，可空格或逗号分段：IP 子网掩码 网关 \n"
read -p "请输入IP、子网掩码、网关: " add_ip_net
# 传入到文本进行分割取值
echo "$add_ip_net" > ${HOMEPATH}add_ip_net.txt
if [ ! "$(cat ${HOMEPATH}add_ip_net.txt|grep '/')" ]; then
a_ip=$(cat ${HOMEPATH}add_ip_net.txt|awk -F "[, ' ']" '{print $1}')
a_mask=$(cat ${HOMEPATH}add_ip_net.txt|awk -F "[, ' ']" '{print $2}')
a_gateway=$(cat ${HOMEPATH}add_ip_net.txt|awk -F "[, ' ']" '{print $3}')
# 插入
sudo echo "
IPADDR=$a_ip
METMASK=$a_mask
GATEWAY=$a_gateway
" >> "/etc/sysconfig/network-scripts/ifcfg-$a_eth"
else
a_ip=$(cat ${HOMEPATH}add_ip_net.txt|awk -F "[, / ' ']" '{print $1}')
a_prefix=$(cat ${HOMEPATH}add_ip_net.txt|awk -F "[, / ' ']" '{print $2}')
a_gateway=$(cat ${HOMEPATH}add_ip_net.txt|awk -F "[, / ' ']" '{print $3}')
# 插入
sudo echo "
IPADDR=$a_ip
PREFIX=$a_prefix
GATEWAY=$a_gateway
" >> "/etc/sysconfig/network-scripts/ifcfg-$a_eth"
fi
rm -rf ${HOMEPATH}add_ip_net.txt
systemctl restart network
echo "修改成功。小推荐：yum install -y ipcalc （子网掩码换算器）"
echo '若将网络设置成自动获取，输入此条指令即可：nmcli con mod "System eth0" ipv4.method auto'
echo '若后续添加DNS，输入该指令生效：nmcli c mod "System eth0" ipv4.dns 1.1.1.1,223.5.5.5'
