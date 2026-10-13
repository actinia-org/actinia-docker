#! /bin/bash

while IFS=, read -r ADDON SERVER
do
  unset URL
  # Skip comment lines and commented out addons
  if [[ $ADDON = \#* ]] ; then
    continue
  fi
  echo "Installing addon: $ADDON"
  if [ -z $SERVER ] ; then
      # Extract the first character(s) for the addon class
      ADDON_CLASS_SHORT=$(echo $ADDON | cut -f1 -d".")
      case "$ADDON_CLASS_SHORT" in
        d)
            ADDON_CLASS="display"
            ;;
        db)
            ADDON_CLASS="db"
            ;;
        g)
            ADDON_CLASS="general"
            ;;
        i)
            ADDON_CLASS="imagery"
            ;;
        m)
            ADDON_CLASS="misc"
            ;;
        r)
            ADDON_CLASS="raster"
            ;;
        r3)
            ADDON_CLASS="raster3d"
            ;;
        t)
            ADDON_CLASS="temporal"
            ;;
        v)
            ADDON_CLASS="vector"
            ;;
      esac
      grass --tmp-project EPSG:4326 --exec g.extension prefix=/src/grass_addons_build extension=$ADDON url="/src/grass-addons/src/${ADDON_CLASS}/${ADDON}"
  else
      grass --tmp-project EPSG:4326 --exec g.extension prefix=/src/grass_addons_build extension=$ADDON url="$SERVER"
  fi
done < "$1"