#!/bin/bash
# Polaris Meet
# for Debian/*buntu binaries.
# GNU GPLv3 or later.
DOMAIN="secure.polarismeet.me"
IPADD="121.58.244.78"
EMAIL="jconadera@gmail.com"
#DOMAIN="$(ls /etc/prosody/conf.d/ | awk -F'.cfg' '!/localhost/{print $1}' | awk '!NF || !seen[$0]++')"
CSS_FILE="/usr/share/jitsi-meet/css/all.css"
TITLE_FILE="/usr/share/jitsi-meet/title.html"
INT_CONF="/usr/share/jitsi-meet/interface_config.js"
BUNDLE_JS="/usr/share/jitsi-meet/libs/app.bundle.min.js"
SIP_PATH="/etc/jitsi/videobridge/sip-communicator.properties"
SYSTEM_PATH="/etc/systemd/system.conf"
HOSTS_PATH="/etc/hosts"
JM_CONF_PATH="/etc/jitsi/meet/$DOMAIN-config.js"
#
JM_IMG_PATH="/usr/share/jitsi-meet/images"
WTM2_PATH="$JM_IMG_PATH/polaris.png"
FICON_PATH="$JM_IMG_PATH/favicon_p.ico"
REC_ICON_PATH="$JM_IMG_PATH/polaris_record.png"
WB_PATH="$JM_IMG_PATH/welcome-bg.png"
#
#
APP_NAME="Polaris Meet"
MOVILE_APP_NAME="Polaris Meet"
PART_USER="Participant"
LOCAL_USER="me"
#
#Adding Jitsi repository
echo '
#--------------------------------------------------
# Preparing and Adding Jitsi Meet Repository...
#--------------------------------------------------
'
sudo apt-add-repository universe
sudo apt update
sudo hostnamectl set-hostname $DOMAIN


if grep -Fxq "$IPADD $DOMAIN" "$HOSTS_PATH"
then
   echo "Hostname Already exist"
else
   echo $IPADD $DOMAIN >> "$HOSTS_PATH"
fi
curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null
sudo apt update

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 10000/udp
sudo ufw allow 22/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
echo "y" | sudo ufw enable


#Install Jisti Meet
echo '
#--------------------------------------------------
# Starting Installing Jitsi Meet
#--------------------------------------------------
'

sudo apt install jitsi-meet -y

echo $EMAIL | sudo /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

sed -i "s|org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES|#org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES|g" "$SIP_PATH"
if grep -Fxq "org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=$IPADD" "$SIP_PATH"
then
   echo "NAT_HARVESTER_PUBLIC_ADDRESS Already exist"
else
   echo "org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS="$IPADD >> "$SIP_PATH"
fi
sed -i "s|#DefaultLimitNOFILE=|DefaultLimitNOFILE=65000|g" "$SYSTEM_PATH"
sed -i "s|#DDefaultLimitNPROC=|DDefaultLimitNPROC=65000|g" "$SYSTEM_PATH"
sed -i "s|#DefaultTasksMax=|DefaultTasksMax=65000|g" "$SYSTEM_PATH"


#Install Jisti Meet
echo '
#--------------------------------------------------
# Starting Polaris Meet Customization...
#--------------------------------------------------
'
#Watermark
if [ ! -f "$WTM2_PATH" ]; then
    cp images/polaris.png "$WTM2_PATH"
else
    echo "watermark file exists, skipping copying..."
fi
#Favicon
if [ ! -f "$FICON_PATH" ]; then
    cp images/polaris.png "$FICON_PATH"
else
    echo "favicon file exists, skipping copying..."
fi
#Local recording icon
if [ ! -f "$REC_ICON_PATH" ];then
    cp images/polaris_record.png "$REC_ICON_PATH"
else
        echo "recodring icon exists, skipping copying..."
fi

#welcome page background
if [ ! -f "$WB_PATH" ];then
    cp images/welcome-bg.png "$WB_PATH"
else
        echo "welcome page background exists, skipping copying..."
fi

#Custom / Remove icons
sed -i "s|welcome-background.png|welcome-bg.png|g" "$CSS_FILE"
sed -i "s|watermark.png|polaris.png|g" "$CSS_FILE"
sed -i "s|favicon.ico|favicon_p.ico|g" "$TITLE_FILE"
sed -i "s|jitsilogo.png|polaris.png|g" "$TITLE_FILE"
sed -i "s|logo-deep-linking.png|polaris.png|g" "$BUNDLE_JS"
sed -i "s|jitsiLogo_square.png|polaris_record.png|g" "$BUNDLE_JS"
#Customize room title
sed -i "s|Jitsi Meet|$APP_NAME|g" "$TITLE_FILE"
sed -i "s| powered by the Jitsi Videobridge||g" "$TITLE_FILE"

#Customizing CSS
sed -i "s|width:71px;height:32px|width:71px;height:50px|g" "$CSS_FILE" 
sed -i "s|padding-bottom:0;background-color:#131519;height:400px;|padding-bottom:0;background-color:#131519;height:470px;|g" "$CSS_FILE" 
sed -i "s|margin:104px 32px 0 32px;|margin:214px 32px 0 32px;|g" "$CSS_FILE"
sed -i "s|.welcome .header .header-text-title{color:#fff;font-size:42px;font-weight:400;|.welcome .header .header-text-title{color:#fff;font-size:42px;font-weight:700;|g" "$CSS_FILE"
#Custom UI changes
if [ -f "$INT_CONF" ]; then
    echo "Static interface_config.js exists, starting modification..."
    echo -e "\nPlease note that custumization will also overwrite support links.\n"
    sed -i "s|Jitsi Meet|$APP_NAME|g" "$BUNDLE_JS"
    sed -i "21,32 s|Jitsi Meet|$APP_NAME|g" "$INT_CONF"
    sed -i "s|\([[:space:]]\)APP_NAME:.*| APP_NAME: \'$APP_NAME\',|" "$INT_CONF"
    sed -i "s|Fellow Jitster|$PART_USER|g" "$INT_CONF"
    sed -i "s|'me'|'$LOCAL_USER'|" "$INT_CONF"
    sed -i "s|DISABLE_PRESENCE_STATUS: false,|DISABLE_PRESENCE_STATUS: true,|g" "$INT_CONF"
    sed -i "s|DISABLE_TRANSCRIPTION_SUBTITLES: false,|DISABLE_TRANSCRIPTION_SUBTITLES: true,|g" "$INT_CONF"
    sed -i "s|DISPLAY_WELCOME_FOOTER: true,|DISPLAY_WELCOME_FOOTER: false,|g" "$INT_CONF"
    sed -i "s|HIDE_INVITE_MORE_HEADER: false,|HIDE_INVITE_MORE_HEADER: true,|g" "$INT_CONF"
    sed -i "s|INITIAL_TOOLBAR_TIMEOUT: 20000,|INITIAL_TOOLBAR_TIMEOUT: 10000,|g" "$INT_CONF"
    sed -i "s|JITSI_WATERMARK_LINK: .*|JITSI_WATERMARK_LINK: 'https:/\/$DOMAIN\',|g" "$INT_CONF"
    sed -i "s|org.jitsi.meet|ph.polaris.app|g" "$INT_CONF"
    sed -i "s|MOBILE_DOWNLOAD_LINK_F_DROID:|//MOBILE_DOWNLOAD_LINK_F_DROID:|g" "$INT_CONF"
    sed -i "s|MOBILE_DOWNLOAD_LINK_IOS:|//MOBILE_DOWNLOAD_LINK_IOS:|g" "$INT_CONF"
    sed -i "s|NATIVE_APP_NAME: 'Jitsi Meet',|NATIVE_APP_NAME: \'$APP_NAME\',|g" "$INT_CONF"
    sed -i "s|PROVIDER_NAME: 'Jitsi',|PROVIDER_NAME: \'$APP_NAME\',|g" "$INT_CONF"
    sed -i "s|LIVE_STREAMING_HELP_LINK: .*|LIVE_STREAMING_HELP_LINK: 'https:/\/$DOMAIN\/live',|g" "$INT_CONF"
    sed -i "s|SUPPORT_URL: .*|SUPPORT_URL: 'https:/\/$DOMAIN\',|g" "$INT_CONF"
    #Logo 2
    sed -i "s|watermark.png|polaris.png|g" "$INT_CONF"
    sed -i "s|watermark.svg|polaris.png|g" "$INT_CONF"
else
 echo "This setup doesn't have a static interface_config.js, checking changes..."
fi

sed -i "s|// toolbarButtons:| toolbarButtons:|g" "$JM_CONF_PATH" 
sed -i "s|//    'microphone',|    'microphone',|g" "$JM_CONF_PATH" 
sed -i "s|//    'fodeviceselection',|    'fodeviceselection',|g" "$JM_CONF_PATH" 
sed -i "s|//    'livestreaming',|    'livestreaming',|g" "$JM_CONF_PATH"
sed -i "s|//    'videoquality',|    'videoquality',|g" "$JM_CONF_PATH"
sed -i "s|//    'tileview',|    'tileview',|g" "$JM_CONF_PATH"
sed -i "s|// prejoinPageEnabled: false,| prejoinPageEnabled: true,|g" "$JM_CONF_PATH"

 
isInFile=$(cat $JM_CONF_PATH | grep -c "/*'sharedvideo', 'shareaudio',*/")
isInFile2=$(cat $JM_CONF_PATH | grep -c "security'\n     ],")

if [ $isInFile2 -eq 0 ]; then
   echo "Bracket already commented"
else
   sed -i "s|'security'|'security'\n     ],|g" "$JM_CONF_PATH"
fi

if [ $isInFile -eq 0 ]; then
   echo "Sharedvideo and Shareaudio already commented"
else
   sed -i "s|'sharedvideo', 'shareaudio',|/*'sharedvideo', 'shareaudio',*/|g" "$JM_CONF_PATH"
fi

echo "
########################################################################
                        Customization complete!!
                               IMPORTANT:
           Please clear your browsing history to verify changes.
              For customized support: gonfreecs600@gmail.com
########################################################################
"
echo "Restarting Jitsi services in..."
secs=$((10))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
sudo systemctl restart jitsi-videobridge2 jicofo prosody nginx
