#!/bin/bash
# Polaris Meet
# for Debian/*buntu binaries.
# GNU GPLv3 or later.

DOMAIN="$(ls /etc/prosody/conf.d/ | awk -F'.cfg' '!/localhost/{print $1}' | awk '!NF || !seen[$0]++')"
CSS_FILE="/usr/share/jitsi-meet/css/all.css"
TITLE_FILE="/usr/share/jitsi-meet/title.html"
INT_CONF="/usr/share/jitsi-meet/interface_config.js"
INT_CONF_ETC="/etc/jitsi/meet/$DOMAIN-interface_config.js"
BUNDLE_JS="/usr/share/jitsi-meet/libs/app.bundle.min.js"
#
JM_IMG_PATH="/usr/share/jitsi-meet/images"
WTM2_PATH="$JM_IMG_PATH/polaris.png"
FICON_PATH="$JM_IMG_PATH/favicon_p.ico"
REC_ICON_PATH="$JM_IMG_PATH/polaris_record.png"
#
APP_NAME="Polaris Meet"
MOVILE_APP_NAME="Polaris Meet"
PART_USER="Participant"
LOCAL_USER="me"
#
SEC_ROOM="TBD"
echo '
#--------------------------------------------------
# Applying Brandless mode
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

#Custom / Remove icons
sed -i "s|watermark.png|polaris.png|g" "$CSS_FILE"
sed -i "s|favicon.ico|favicon_p.ico|g" "$TITLE_FILE"
sed -i "s|jitsilogo.png|polaris.png|g" "$TITLE_FILE"
sed -i "s|logo-deep-linking.png|polaris.png|g" "$BUNDLE_JS"
sed -i "s|jitsiLogo_square.png|polaris_record.png|g" "$BUNDLE_JS"
#Customize room title
sed -i "s|Jitsi Meet|$APP_NAME|g" "$TITLE_FILE"
sed -i "s| powered by the Jitsi Videobridge||g" "$TITLE_FILE"
#ed -i "/appNotInstalled/ s|{{app}}|$MOVILE_APP_NAME|" /usr/share/jitsi-meet/lang/*

#Custom UI changes
if [ -f "$INT_CONF_ETC" ]; then
    echo "Static interface_config.js exists, skipping modification..."
else
    echo "This setup doesn't have a static interface_config.js, checking changes..."
    echo -e "\nPlease note that brandless mode will also overwrite support links.\n"
    sed -i "s|Jitsi Meet|$APP_NAME|g" "$BUNDLE_JS"
    sed -i "21,32 s|Jitsi Meet|$APP_NAME|g" "$INT_CONF"
    sed -i  "s|\([[:space:]]\)APP_NAME:.*| APP_NAME: \'$APP_NAME\',|" "$INT_CONF"
    sed -i "s|Fellow Jitster|$PART_USER|g" "$INT_CONF"
    sed -i "s|'me'|'$LOCAL_USER'|" "$INT_CONF"
    sed -i "s|LIVE_STREAMING_HELP_LINK: .*|LIVE_STREAMING_HELP_LINK: 'https://\'$DOMAIN\'/live'|g" "$INT_CONF"
    sed -i "s|SUPPORT_URL: .*|SUPPORT_URL: 'https://'\'$DOMAIN\'',|g" "$INT_CONF"
    #Logo 2
    sed -i "s|watermark.png|polaris.png|g" "$INT_CONF"
    sed -i "s|watermark.svg|polaris.png|g" "$INT_CONF"
fi
