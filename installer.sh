#!/bin/bash
# Polaris Meet
# for Debian/*buntu binaries.
# GNU GPLv3 or later.
DOMAIN="web.polarismeet.me"
IPADD="121.58.244.94"
EMAIL="jconadera@gmail.com"
APP_URL="https://play.google.com/store/apps/details?id=ph.polaris.app"
#DOMAIN="$(ls /etc/prosody/conf.d/ | awk -F'.cfg' '!/localhost/{print $1}' | awk '!NF || !seen[$0]++')"
CSS_FILE="/usr/share/jitsi-meet/css/all.css"
TITLE_FILE="/usr/share/jitsi-meet/title.html"
INDEX_FILE="/usr/share/jitsi-meet/index.html"
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
WBG_PATH="$JM_IMG_PATH/windows-badge.png"
MBG_PATH="$JM_IMG_PATH/macos-badge.png"
WC_PATH="/usr/share/jitsi-meet/static/welcomePageAdditionalContent.html"
JM_MANIFEST_PATH="/usr/share/jitsi-meet/manifest.json"
#
#
APP_NAME="Polaris Meet"
MOBILE_APP_NAME="Polaris Meet"
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
sudo apt install wget


if grep -Fxq "$IPADD $DOMAIN" "$HOSTS_PATH"
then
   echo "Hostname lready exist"
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

if grep -Fxq "#org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES" "$SIP_PATH"
then
   echo "STUN_MAPPING_HARVESTER_ADDRESSES already commented"
else
   sed -i "s|org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES|#org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES|g" "$SIP_PATH"
fi

if grep -Fxq "org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS=$IPADD" "$SIP_PATH"
then
   echo "NAT_HARVESTER_PUBLIC_ADDRESS already exist"
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
mkdir -p images && wget https://github.com/Gl33ch3r/PolarisMeet/raw/main/images/favicon_p.ico -P images && 
wget https://github.com/Gl33ch3r/PolarisMeet/raw/main/images/polaris.png -P images &&
wget https://github.com/Gl33ch3r/PolarisMeet/raw/main/images/polaris_record.png -P images &&
wget https://github.com/Gl33ch3r/PolarisMeet/raw/main/images/welcome-bg.png -P images &&
wget https://github.com/Gl33ch3r/PolarisMeet/raw/main/images/windows-badge.png -P images &&
wget https://github.com/Gl33ch3r/PolarisMeet/raw/main/images/macos-badge.png -P images
mkdir -p html && wget https://raw.githubusercontent.com/Gl33ch3r/PolarisMeet/main/welcomePageAdditionalContent.html -P html

#Windows Badge
if [ ! -f "$WBG_PATH" ]; then
    mv images/windows-badge.png "$WBG_PATH"
    rm -R images/windows-badge.png
else
    echo "Windows Badge file exists, skipping copying..."
fi

#MacOs Badge
if [ ! -f "$MBG_PATH" ]; then
    mv images/macos-badge.png "$MBG_PATH"
    rm -R images/macos-badge.png
else
    echo "Windows Badge file exists, skipping copying..."
fi


#Watermark
if [ ! -f "$WTM2_PATH" ]; then
    mv images/polaris.png "$WTM2_PATH"
    rm -R images/polaris.png
else
    echo "watermark file exists, skipping copying..."
fi
#Favicon
if [ ! -f "$FICON_PATH" ]; then
    mv images/favicon_p.ico "$FICON_PATH"
    rm -R images/favicon_p.ico
else
    echo "favicon file exists, skipping copying..."
fi
#Local recording icon
if [ ! -f "$REC_ICON_PATH" ];then
    mv images/favicon_p.ico "$REC_ICON_PATH"
    rm -R images/favicon_p.ico
else
        echo "recodring icon exists, skipping copying..."
fi
#welcome page background
if [ ! -f "$WB_PATH" ];then
    cp images/welcome-bg.png "$WB_PATH"
    rm -R images/welcome-bg.png
else
        echo "welcome page background exists, skipping copying..."
fi

cp html/welcomePageAdditionalContent.html "$WC_PATH"
rm -R html/welcomePageAdditionalContent.html

#Custom / Remove icons
sed -i "s|welcome-background.png|welcome-bg.png|g" "$CSS_FILE"
sed -i "s|watermark.png|polaris.png|g" "$CSS_FILE"
sed -i "s|favicon.ico|favicon_p.ico|g" "$TITLE_FILE"
sed -i "s|jitsilogo.png|polaris.png|g" "$TITLE_FILE"
sed -i "s|logo-deep-linking.png|polaris.png|g" "$BUNDLE_JS"
sed -i "s|jitsiLogo_square.png|polaris_record.png|g" "$BUNDLE_JS"
sed -i "s|Jitsi on mobile|Polaris on mobile|g" "$BUNDLE_JS"

#Customize room title
sed -i "s|Jitsi Meet|$APP_NAME|g" "$TITLE_FILE"
sed -i "s| powered by the Jitsi Videobridge||g" "$TITLE_FILE"

#Adding google font style
sed -i 's|<link rel="manifest" id="manifest-placeholder">|<link rel="manifest" id="manifest-placeholder">\n<link href="https://fonts.googleapis.com/css?family=Nunito" rel="stylesheet" type="text/css">|g' "$INDEX_FILE"


#Customizing CSS
sed -i "s|width:71px;height:32px|width:71px;height:50px|g" "$CSS_FILE" 
sed -i "s|padding-bottom:0;background-color:#131519;height:400px;|padding-bottom:0;background-color:#131519;height:440px;|g" "$CSS_FILE" 
sed -i "s|margin:104px 32px 0 32px;|margin:214px 32px 0 32px;|g" "$CSS_FILE"
sed -i "s|.welcome .header .header-text-title{color:#fff;font-size:42px;font-weight:400;|.welcome .header .header-text-title{color:#fff;font-size:42px;font-weight:700;font-family:Nunito;|g" "$CSS_FILE"
sed -i "s|.subject-text{background:rgba(0,0,0,.6);border-radius:3px 0 0 3px;|.subject-text{background:rgba(0,0,0,.6);border-radius:10px 0 0 10px;font-family:Nunito;|g" "$CSS_FILE"
sed -i "s|.label{align-items:center;background:#36383c;border-radius:3px;|.label{align-items:center;background:#36383c;border-radius:10px;|g" "$CSS_FILE"
sed -i "s|.subject-timer{background:rgba(0,0,0,.8);border-radius:0 3px 3px 0;|.subject-timer{background:rgba(0,0,0,.6);border-radius:0 10px 10px 0;|g" "$CSS_FILE"
sed -i "s|.welcome .header #enter_room{display:flex;align-items:center;max-width:480px;width:calc(100% - 32px);z-index:2;background-color:#fff;padding:4px;border-radius:4px;|.welcome .header #enter_room{display:flex;align-items:center;max-width:480px;width:calc(100% - 32px);z-index:2;background-color:#fff;padding:4px;border-radius:30px;|g" "$CSS_FILE"
sed -i "s|.welcome .welcome-page-button{border:0;font-size:14px;background:#0074e0;border-radius:3px;|.welcome .welcome-page-button{border:0;font-size:14px;background:#0074e0;border-radius:30px;|g" "$CSS_FILE"
sed -i "s|.welcome .header #enter_room .enter-room-input-container .enter-room-input{border:0;background:#fff;display:inline-block;height:50px;width:100%;font-size:14px;padding-left:10px;|.welcome .header #enter_room .enter-room-input-container .enter-room-input{border-radius:30px;border:0;background:#fff;display:inline-block;height:50px;width:100%;font-size:14px;padding-left:30px;|g" "$CSS_FILE"
sed -i "s|.welcome .header #enter_room .enter-room-input-container .enter-room-input:focus{outline:auto 2px #005fcc|.welcome .header #enter_room .enter-room-input-container .enter-room-input:focus{|g" "$CSS_FILE"
sed -i "s|.premeeting-screen .content input.field{background-color:#fff;border:none;outline:0;border-radius:3px;|.premeeting-screen .content input.field{background-color:#fff;border:none;outline:0;border-radius:20px;|g" "$CSS_FILE"
sed -i "s|.premeeting-screen .action-btn{border-radius:3px;|.premeeting-screen .action-btn{border-radius:20px;|g" "$CSS_FILE"
sed -i "s|.welcome .header .header-text-title{color:#fff;|.welcome .header .header-text-title{text-shadow:1px 1px #000000;color:#fff;|g" "$CSS_FILE"
sed -i "s|.welcome .header .header-text-subtitle{color:#fff;|.welcome .header .header-text-subtitle{text-shadow:1px 1px #000000;color:#fff;|g" "$CSS_FILE"
sed -i 's|flex;flex-direction:column;font-family:inherit;|flex;flex-direction:column;font-family:Inter,"Helvetica Neue",Helvetica,Arial,sans-serif;|g' "$CSS_FILE"
sed -i 's|select,textarea{font-family:-apple-system,BlinkMacSystemFont,open_sanslight,"Helvetica Neue",Helvetica,Arial,sans-serif!important}|select,textarea{font-family:Nunito,sans-serif!important}|g' "$CSS_FILE"
sed -i 's|color:#fff;font-family:-apple-system,BlinkMacSystemFont,open_sanslight,"Helvetica Neue",Helvetica,Arial,sans-serif;|color:#fff;font-family:Nunito,sans-serif|g' "$CSS_FILE"
sed -i 's|text-align:left;font-family:open_sanslight|text-align:left;font-family:Nunito|g' "$CSS_FILE"
sed -i "s|height:22px;border-radius:50%;box-sizing:border-box;z-index:3;background:#165ecc;color:#fff;border:2px solid #fff|height:22px;border-radius:50%;box-sizing:border-box;z-index:3;background:#165ecc;color:#fff|g" "$CSS_FILE"
sed -i 's|org.jitsi.meet|ph.polaris.meet|g' "$JM_MANIFEST_PATH"
sed -i 's|Jitsi Meet|Polaris Meet|g' "$JM_MANIFEST_PATH"
sed -i 's|static/pwa/icons/icon192.png|images/polaris.png|g' "$JM_MANIFEST_PATH"
sed -i 's|static/pwa/icons/icon512.png|images/polaris.png|g' "$JM_MANIFEST_PATH"
sed -i 's|static/pwa/icons/iconMask.png|images/polaris.png|g' "$JM_MANIFEST_PATH"

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
sed -i "s|//    'livestreaming', 'etherpad', 'sharedvideo', 'shareaudio',|    /*'livestreaming', 'etherpad', 'sharedvideo', 'shareaudio',*/|g" "$JM_CONF_PATH"
sed -i "s|//    'videoquality',|    'videoquality',|g" "$JM_CONF_PATH"
sed -i "s|//    'tileview',|    'tileview',|g" "$JM_CONF_PATH"
sed -i "s|//    'tileview',|    'tileview',|g" "$JM_CONF_PATH"
sed -i "s|// prejoinPageEnabled: false,| prejoinPageEnabled: true,|g" "$JM_CONF_PATH"

isInFile=$(cat $JM_CONF_PATH | grep -c "security' ],")

#if [ $isInFile -eq 0 ]; then
#   echo "Bracket already commented"
#else
#   sed -i "s|'security'|'security' ],|g" "$JM_CONF_PATH"
#fi

if grep -Fxq "'security' ]," "$JM_CONF_PATH"
then
     echo "Bracket already commented"
else
    sed -i "s|'security'|'security' ],|g" "$JM_CONF_PATH"
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
