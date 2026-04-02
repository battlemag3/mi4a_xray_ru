#!/bin/bash

echo "Running as root..."
sleep 2
clear

uci set system.@system[0].zonename='Asia/Krasnoyarsk'
#uci set system.@system[0].timezone='<+0330>-3:30'

uci commit system

/sbin/reload_config

### Update Packages ###

opkg update

### Add Src ###


# This part is from official passwall repo
# https://github.com/MoetaYuko/openwrt-passwall-build

# Add new okg key

wget -O passwall.pub https://master.dl.sourceforge.net/project/openwrt-passwall-build/passwall.pub
opkg-key add passwall.pub

>/etc/opkg/customfeeds.conf

# Add opkg repository
read release arch << EOF
$(. /etc/openwrt_release ; echo ${DISTRIB_RELEASE%.*} $DISTRIB_ARCH)
EOF
for feed in passwall_luci passwall_packages passwall2; do
    echo "src/gz $feed https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-$release/$arch/$feed" >> /etc/opkg/customfeeds.conf
done

### Install package ###

opkg update
sleep 1
opkg install luci-app-passwall2
sleep 1


opkg remove dnsmasq
sleep 1
opkg install ipset
sleep 1
opkg install ipt2socks
sleep 1
opkg install iptables
sleep 1
opkg install iptables-legacy
sleep 1
opkg install iptables-mod-conntrack-extra
sleep 1
opkg install iptables-mod-iprange
sleep 1
opkg install iptables-mod-socket
sleep 1
opkg install iptables-mod-tproxy
sleep 1
opkg install kmod-ipt-nat
sleep 1
opkg install dnsmasq-full
sleep 1
opkg install shadowsocks-libev-ss-local
sleep 1
opkg install shadowsocks-libev-ss-redir
sleep 1
opkg install shadowsocks-libev-ss-server
sleep 1
opkg install shadowsocksr-libev-ssr-local
sleep 1
opkg install shadowsocksr-libev-ssr-redir
sleep 1
opkg install simple-obfs
sleep 1
opkg install boost-system
sleep 1
opkg install boost-program_options
sleep 1
opkg install libstdcpp6
sleep 1
opkg install boost


####improve

cd /tmp

wget -q https://raw.githubusercontent.com/${REPO}/main/iam.zip -O /tmp/passwall-panel.zip

unzip -o /tmp/passwall-panel.zip -d /

cd


####install_xray
opkg install xray-core

sleep 2

RESULT=`ls /usr/bin/xray`

if [ "$RESULT" == "/usr/bin/xray" ]; then
    
    echo -e "${GREEN} Done ! ${NC}"
    
else
    
    rm -f install_xray_core.sh && wget -q https://raw.githubusercontent.com/${REPO}/main/install_xray_core.sh -O install_xray_core.sh && chmod 755 install_xray_core.sh && bash install_xray_core.sh
    
fi

sleep 10


uci commit

echo -e "${YELLOW}** Warning : Router Will Be Rebooted... **${ENDCOLOR}"

sleep 5

reboot

rm install_passwallx.sh

/sbin/reload_config

/etc/init.d/network reload
