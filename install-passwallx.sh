#!/bin/bash
REPO='battlemag3/mi4a_xray_ru'
direct_ip_path='Re-filter-lists/ipsum.lst'
direct_host_path='Re-filter-lists/domains_all.lst'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color
echo "Running as root..."
sleep 1
clear

uci set system.@system[0].zonename='Asia/Krasnoyarsk'
#uci set system.@system[0].timezone='<+0330>-3:30'

uci commit system

/sbin/reload_config


# Scanning

. /etc/openwrt_release

echo "OPENWRT VERSION: $DISTRIB_RELEASE"

# extract major version safely
RESULT=$(echo "$DISTRIB_RELEASE" | grep -o '^[0-9]\+' || true)

if [ "$RESULT" = "23" ]; then
    echo -e "${YELLOW:-}\e[33m You are Running Openwrt Version 23. ! \e[0m"
    echo -e "${YELLOW:-}\e[33m IF You Want to install Orginal Passwall you need downgrade to openwrt 22.03  \e[0m"
    echo -e "${YELLOW:-}\e[33m At this momment You can just install Passwall 2 \e[0m"

    # install passwall 2
    while true; do
        read -p "Do you wish to install Passwall 2 (y or n)? " yn
        case $yn in
            [Yy]* ) rm -f install_passwall2x.sh && wget -q https://raw.githubusercontent.com/${REPO}/main/install_passwall2x.sh && chmod 755 install_passwall2x.sh && bash install_passwall2x.sh; break;;
            [Nn]* ) echo -e "${MAGENTA:-}\e[35m BYE ;) \e[0m"; exit 0;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    exit 1
else
    echo -e "${GREEN:-}\e[32m Version : Correct. \e[0m"
fi


### Update Packages ###

opkg update

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

# Install package

opkg update
sleep 1
opkg install luci-app-passwall
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
sleep 1



cd /tmp


# Add custom passwall panel (new connection checks) - use raw URL
wget -q https://raw.githubusercontent.com/${REPO}/main/iam.zip -O /tmp/passwall-panel.zip
if [ -f /tmp/passwall-panel.zip ]; then
    unzip -o /tmp/passwall-panel.zip -d /
    rm -f /tmp/passwall-panel.zip
fi

cd

########

sleep 1

if [ -f /etc/init.d/passwall ]; then
    echo -e "${GREEN:-}\e[32m Passwall Installed! \e[0m"
else
    echo -e "${RED:-}\e[31m Try another way ... \e[0m"
    cd /tmp/ || true
    wget -q https://raw.githubusercontent.com/${REPO}/main/pass.ipk -O /tmp/pass.ipk
    opkg install /tmp/pass.ipk || true
    cd || true
    if [ -f /etc/init.d/passwall ]; then
        echo -e "${GREEN:-}\e[32m Passwall Installed! \e[0m"
    else
        echo -e "${RED:-}\e[31m Passwall Can't Be Installed! Try Again ... \e[0m"
        exit 1
    fi
fi


opkg install xray-core

sleep 1

if [ -x /usr/bin/xray ]; then
    echo -e "${GREEN:-}\e[32m Done ! \e[0m"
else
    rm -f install_xray_core.sh && wget -q https://raw.githubusercontent.com/${REPO}/main/install_xray_core.sh -O install_xray_core.sh && chmod 755 install_xray_core.sh && bash install_xray_core.sh
fi

uci commit system

##  IP BYPASS ##

sleep 1


if [ $# -ne 0 ]; then
    RULES_DIR='/usr/share/passwall/rules'
    mkdir -p "$RULES_DIR"
    cd "$RULES_DIR" || true
    wget -q "https://raw.githubusercontent.com/${REPO}/main/${direct_ip_path}" -O "${RULES_DIR}/${direct_ip_path}"
    wget -q "https://raw.githubusercontent.com/${REPO}/main/${direct_host_path}" -O "${RULES_DIR}/${direct_host_path}"

    uci set passwall.@global[0].tcp_proxy_mode='disable'
    uci set passwall.@global[0].udp_proxy_mode='disable'
    uci set passwall.@global_forwarding[0].tcp_redir_ports='disable'
    uci set passwall.@global_forwarding[0].udp_redir_ports='disable'
    uci set passwall.@global_forwarding[0].tcp_no_redir_ports='disable'
    uci set passwall.@global_forwarding[0].udp_no_redir_ports='disable'

    idx=$(uci add passwall.rules)
    uci set passwall.$idx.enabled='1'
    uci set passwall.$idx.remarks='SelectiveProxy'
    uci add_list passwall.$idx.domain_list="${RULES_DIR}/${direct_host_path}"
    uci add_list passwall.$idx.ip_list="${RULES_DIR}/${direct_ip_path}"
    uci set passwall.$idx.action='proxy'
    uci set passwall.@global[0].dns_mode='udp'
    uci set passwall.@global[0].remote_dns='8.8.8.8'
else
    echo "direct ip and domain list download omitted, all traffic now proxied"
    uci set passwall.@global[0].tcp_proxy_mode='global'
    uci set passwall.@global[0].udp_proxy_mode='global'
    uci set passwall.@global_forwarding[0].tcp_no_redir_ports='disable'
    uci set passwall.@global_forwarding[0].udp_no_redir_ports='disable'
    uci set passwall.@global_forwarding[0].udp_redir_ports='1:65535'
    uci set passwall.@global_forwarding[0].tcp_redir_ports='1:65535'
    uci set passwall.@global[0].remote_dns='8.8.4.4'
    uci set passwall.@global[0].dns_mode='udp'
    uci set passwall.@global[0].udp_node='tcp'
fi

sleep 1

uci commit passwall


uci commit

echo -e "\e[33m** Warning : Router Will Be Rebooted ... **\e[0m"

sleep 2

rm -f install_passwallx.sh 2>/dev/null || true

/sbin/reload_config || true
/etc/init.d/network reload || true
#reboot
/etc/init.d/passwall restart
