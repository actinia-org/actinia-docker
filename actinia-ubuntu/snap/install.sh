#!/bin/sh

# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539778/Install+SNAP+on+the+command+line
# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539785/Update+SNAP+from+the+command+line
# http://step.esa.int/main/download/snap-download/

# Download ESA SNAP installer
wget -q --show-progress -O /src/snap/esa-snap_all_linux-${ESA_SNAP_VERSION}.0.0.sh \
 "https://download.esa.int/step/snap/${ESA_SNAP_VERSION}.0/installers/esa-snap_all_linux-${ESA_SNAP_VERSION}.0.0.sh"

# Install ESA SNAP and plugins
echo "Installing ESA SNAP ${ESA_SNAP_VERSION}.0.0 ..."
sh /src/snap/esa-snap_all_linux-${ESA_SNAP_VERSION}.0.0.sh -q -varfile /src/snap/response.varfile

sed -i 's+jdkhome="./jre"+jdkhome="$JAVA_HOME"+g' /usr/local/esa-snap/etc/snap.conf

# Update ESA SNAP and plugins
echo "Updating ESA SNAP ${ESA_SNAP_VERSION}.0.0 ..."
# freezing, when no updates available. Now there are updates, so reactivating.
/usr/local/esa-snap/bin/snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] &&
    (ps -u
    pgrep -f -a "/usr/local/esa-snap/bin"
    echo ""
    pgrep -f -a "snap")
        [ "$line" = "updates=0" ] && sleep 2 && pkill -f "/usr/local/esa-snap/bin"
done

# Cleanup
rm -rf /usr/local/esa-snap/jre \
rm -rf /src/snap
# Maybe remove more unnecessary files from /root/.snap which is later copied to the final image
echo "Done installing ESA SNAP ${ESA_SNAP_VERSION}.0.0 ..."
