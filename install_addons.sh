
while IFS=, read -r ADDON SERVER
do
  unset URL
  if [ -z $SERVER ] ; then
      ADDON_CLASS_SHORT="${ADDON:0:1}"  # Extract the first character

      case "$ADDON_CLASS_SHORT" in
        r)
            ADDON_CLASS="raster"
            ;;
        i)
            ADDON_CLASS="imagery"
            ;;
        t)
            ADDON_CLASS="temporal"
            ;;
        v)
            ADDON_CLASS="vector"
            ;;
      esac
      grass --tmp-project EPSG:4326 --exec g.extension prefix=/src/grass_addons extension=$ADDON url="/src/grass_addons/src/${ADDON_CLASS}/${ADDON}"
  else
      grass --tmp-project EPSG:4326 --exec g.extension prefix=/src/grass_addons extension=$ADDON url="$SERVER"
  fi
done < "$1"