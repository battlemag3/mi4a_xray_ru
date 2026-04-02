#!/bin/sh
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
service passwall stop

cd

RESULT=`cat /root/core.txt`

if [ "$RESULT" == "sing" ]; then
    
    
    echo -e "${GREEN} S ${GREEN}"
    
    rm /tmp/usr/bin/xray 2> /dev/null
    
    ##installing sing-box#
    
    cd /tmp
    echo "Downloading latest version of Sing-Box ..."
    wget -T 10 -q https://github.com/${REPO}/raw/refs/heads/main/sing.ipk
    
    if [[ -f sing.ipk ]]
    
    then
        
        echo -e "${GREEN} Download Successful ! ${ENDCOLOR}"
        
    else
        
        echo -e "${RED} ERROR : Download Unsuccessful Check Internet Connection ${ENDCOLOR}"
        exit 1
        
    fi
    
    echo -e "${MAGENTA} INSTALLING Sing-Box ... ${ENDCOLOR}"
    opkg install sing.ipk -d ram
    
    
    if [[ -f sing.ipk ]]
    
    then
        
        rm sing.ipk
        
    else
        
        echo "Stage 1 Passed"
        
    fi
    
    service passwall restart
    cd /root/
    
    
    ####improve
    
    cd /tmp
    
    wget -T 10 -q https://raw.githubusercontent.com/${REPO}/main/iam.zip -O /tmp/passwall-panel.zip
    
    unzip -o /tmp/passwall-panel.zip -d /
    
    cd /root/
    
    echo "Done !"
    
    exit 1
    
else
    
    echo -e "${GREEN} X ${GREEN}"
    
    opkg remove sing-box
    
    rm /tmp/usr/bin/sing-box 2> /dev/null
    
    
fi


cd /tmp
echo "Downloading latest version of Xray-core ..."
wget -T 10 -q https://raw.githubusercontent.com/${REPO}/main/panel.ipk -O /tmp/panel.ipk

if [[ -f /tmp/panel.ipk ]]

then
    
    echo -e "${GREEN} Download Successful ! ${ENDCOLOR}"
    
else
    
    echo -e "${RED} ERROR : Download Unsuccessful Check Internet Connection ${ENDCOLOR}"
    exit 1
    
fi

echo -e "${MAGENTA} INSTALLING XRAY ... ${ENDCOLOR}"
opkg install /tmp/panel.ipk -d ram || true


if [[ -f /tmp/panel.ipk ]]

then
    
    rm /tmp/panel.ipk
    
else
    
    echo "Stage 1 Passed"
    
fi

service passwall restart
cd /root/


####improve

cd /tmp

wget -T 10 -q https://raw.githubusercontent.com/${REPO}/main/pass.ipk -O /tmp/pass.ipk

opkg install /tmp/pass.ipk -d ram || true

rm -f /tmp/pass.ipk

cd /root/

########

echo "Done !"
