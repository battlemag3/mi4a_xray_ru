#!/bin/sh
echo "Running as root..."
sleep 2
clear

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

##Scanning

. /etc/openwrt_release
echo "Version: $DISTRIB_RELEASE"

RESULT=`echo $DISTRIB_RELEASE`
if [ "$RESULT" == "23.05.0" ]; then
    
    echo -e "${YELLOW} Maybe You get Some Errors on 23.05.0 ! Try 22.03.5 or less ... ${YELLOW}"
    
    echo -e "${NC}  ${NC}"
    
else
    
    echo -e "${GREEN} Version : OK ${GREEN}"
    
    echo -e "${NC}  ${NC}"
fi

sleep 1

. /etc/openwrt_release
echo "َArchitecture: $DISTRIB_ARCH"

RESULT=`echo $DISTRIB_ARCH`
if [ "$RESULT" == "mipsel_24kc" ]; then
    
    echo -e "${GREEN} Architecture : OK ${GREEN}"
    
else
    
    echo -e "${RED} OOPS ! Your Architecture is Not compatible ${RED}"
    exit 1
    
fi

sleep 1

### Passwall Check


RESULT=`ls /etc/init.d/passwall`
if [ "$RESULT" == "/etc/init.d/passwall" ]; then
    
    echo -e "${GREEN} Passwall : OK ${GREEN}"
    echo -e "${NC}  ${NC}"

else
    
    echo -e "${RED} OOPS ! First Install Passwall on your Openwrt . ${RED}"
    echo -e "${NC}  ${NC}"
    exit 1
    
fi


######## Temp Space Check

a=`cd /tmp && du  -m -d 0 | grep -Eo '[0-9]{1,9}'`
b=38
if [ "$a" -gt "$b" ]; then
    
    echo -e "${GREEN} Temp Space : OK ${GREEN}"
    echo -e "${NC}  ${NC}"
    
else
    
    echo -e "${YELLOW} TEMP SPACE NEED : 38 MB ${YELLOW}"
    
fi


sleep 2

## Service INSTALL ##

cd /root/

if [[ -f install-passwall-panel.sh ]]
then
    rm -f install-passwall-panel.sh
else
    echo "Stage 3 Passed"
fi

wget -q https://raw.githubusercontent.com/${REPO}/main/install-passwall-panel.sh -O install-passwall-panel.sh

chmod 755 install-passwall-panel.sh

sleep 1

if [[ -f up.sh ]]

then
    rm up.sh
    
else
    
    echo "Stage 4 Passed"
    fi

wget https://raw.githubusercontent.com/${REPO}/main/up.sh

chmod 777 up.sh

sleep 1


if [[ -f timer.sh ]]

then
    
    rm timer.sh
    
else
    
    echo "Stage 5 Passed"
    
fi

wget https://raw.githubusercontent.com/${REPO}/main/timer.sh

chmod +x timer.sh

cd

cd /sbin/

if [[ -f passwall-init ]]
then
    rm -f passwall-init
else
    echo "Stage 6 Passed"
fi

wget -q https://raw.githubusercontent.com/${REPO}/main/passwall-init-v2 -O passwall-init-v2

chmod 755 passwall-init-v2

mv passwall-init-v2 passwall-init

cd

########

sleep 1


cd /etc/init.d/


if [[ -f passwall-init ]]

then
    
    rm passwall-init
    
else
    
    echo "Stage 7 Passed"
    
fi


wget -q https://raw.githubusercontent.com/${REPO}/main/passwall-init -O passwall-init

chmod +x /etc/init.d/passwall-init

/etc/init.d/passwall-init enable

cd /root/

echo -e "${GREEN} almost done ... ${ENDCOLOR}"


####improve

cd /tmp

wget -q https://raw.githubusercontent.com/${REPO}/main/passwall-panel.zip -O passwall-panel.zip

unzip -o passwall-panel.zip -d /

cd /root/

########

> core.txt
> vore.txt

# Which One? ###############

echo " "
echo -e "${YELLOW} 1.${NC} ${CYAN} Sing-box ${NC}"
echo -e "${YELLOW} 2.${NC} ${CYAN} Xray ${NC}"
echo -e "${YELLOW} 4.${NC} ${RED} EXIT ${NC}"
echo " "


echo " "
read -p " -Select Core Option : " choice

case $choice in
    
    1)
        
        echo "sing" >> core.txt
        echo "sing-box" >> vore.txt
        
        opkg update
        
        opkg install ca-bundle
        opkg install kmod-inet-diag
        opkg install kernel
        opkg install kmod-netlink-diag
        opkg install kmod-tun
        
        uci set passwall.@global_app[0].singbox_file='/tmp/usr/bin/sing-box'
        
        uci commit passwall
        
        #read -s -n 1
    ;;
    
    2)
        
        echo "xray" >> core.txt
        echo "xray" >> vore.txt
        
        ##Config
        
        RESULT=`grep -o /tmp/usr/bin/xray /etc/config/passwall`
        if [ "$RESULT" == "/tmp/usr/bin/xray" ]; then
            echo -e "${GREEN}Cool !${NC}"
            
        else
            
            echo -e "${YELLOW}Replacing${YELLOW}"
            sed -i 's/usr\/bin\/xray/tmp\/usr\/bin\/xray/g' /etc/config/passwall
            
        fi
        
        #read -s -n 1
    ;;
    
    4)
        echo ""
        echo -e "${GREEN}Exiting...${NC}"
        exit 0
        
        read -s -n 1
    ;;
    
    *)
        echo "  Invalid option Selected ! "
        echo " "
        echo -e "  Press ${RED}ENTER${NC} to continue"
        exit 0
        
        read -s -n 1
    ;;
esac


##EndConfig

/etc/init.d/passwall-init start


sleep 1

>/var/spool/cron/crontabs/root
echo "*/1 * * * * sh /root/timer.sh" >> /var/spool/cron/crontabs/root
echo "30 4 * * * sleep 70 && touch /etc/banner && reboot" >> /var/spool/cron/crontabs/root

/etc/init.d/cron restart

##checkup

cd


uci commit dhcp

/sbin/reload_config


if [[ -f install-passwall-panel.sh ]]
then
    echo -e "${GREEN}OK !${NC}"
else
    echo -e "${RED}Something Went Wrong Try again ... ${NC}"
fi

cd /etc/init.d/


if [[ -f passwall-init ]]
then
    echo -e "${GREEN}OK !${NC}"
else
    echo -e "${RED}Something Went Wrong Try again ... ${NC}"
fi

cd

sleep 3


rm install_xray_core.sh 2> /dev/null
