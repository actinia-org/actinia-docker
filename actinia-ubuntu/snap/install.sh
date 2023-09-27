#!/bin/sh

# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539778/Install+SNAP+on+the+command+line
# https://senbox.atlassian.net/wiki/spaces/SNAP/pages/30539785/Update+SNAP+from+the+command+line
# http://step.esa.int/main/download/snap-download/

SNAPVER=9
# avoid NullPointer crash during S-1 processing
java_max_mem=80G

# install module 'jpy' (A bi-directional Python-Java bridge)
#git clone https://github.com/jpy-consortium/jpy.git /src/snap/jpy
#python3 -m pip install wheel
#git clone https://github.com/bcdev/jpy.git /src/snap/jpy
#(cd /src/snap/jpy && python3 setup.py bdist_wheel)
#python3 -m pip install /src/snap/jpy/dist/*.whl

#/usr/bin/python3 -c 'import jpy'
#echo "done with jpy"
# hack because ./snappy-conf will create this dir but also needs *.whl files...
#mkdir -p /root/.snap/snap-python
#cp /src/snap/jpy/dist/*.whl "/root/.snap/snap-python/"

# install and update snap
wget -q -O /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh \
	  "http://step.esa.int/downloads/${SNAPVER}.0/installers/esa-snap_all_unix_${SNAPVER}_0_0.sh"

# # hack to make it run on alpine
sh /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh -q -varfile /src/snap/response.varfile

# one more hack to keep using system java
sed -i 's+jdkhome="./jre"+jdkhome="$JAVA_HOME"+g' /usr/local/snap/etc/snap.conf
# freezing, when no updates available. Now there are updates, so reactivating.
snap --nosplash --nogui --modules --update-all 2>&1 | while read -r line; do
    echo "$line"
    [ "$line" = "updates=0" ] && 
    (ps -u
    pgrep -f -a "/usr/local/snap/bin" 
    echo ""
    pgrep -f -a "snap")
        [ "$line" = "updates=0" ] && sleep 2 && pkill -f "/usr/local/snap/bin"
done
# /usr/local/snap/bin/snap --nosplash --nogui --modules --update-all

rm -rf /usr/local/snap/jre

# Maybe remove more unnecessary files from /root/.snap which is later copied to the final image

# create snappy and python binding with snappy
# cd /usr/local/snap/bin/snappy-conf /usr/bin/python3 /root/.snap/snap-python/snappy
# (cd /root/.snap/snap-python/snappy && python3 setup.py install)

# increase the JAVA VM size to avoid NullPointer exception in Snappy during S-1 processing
# (cd /root/.snap/snap-python/snappy && sed -i "s/^java_max_mem:.*/java_max_mem: $java_max_mem/" snappy.ini)

# test
# /usr/bin/python3 -c 'from esa_snappy import ProductIO'
# if [ -f /src/snap/about.py ]
# then
# 	    /usr/bin/python3 /src/snap/about.py
# 	        cp /src/snap/about.py /root/.snap/
# fi


# cleanup installer
rm -f /src/snap/esa-snap_all_unix_${SNAPVER}_0.sh

################################################################################
# keep for debugging
# export INSTALL4J_KEEP_TEMP=yes
