
while IFS=, read -r ADDON SERVER
do
  unset URL
  # Skip comment lines and commented out addons
  if [[ $ADDON = \#* ]] ; then
    continue
  fi

  if [ -z $SERVER ] ; then
      # Split addon name into components
      IFS=. ADDON_COMPONENTS=(${ADDON##*-})
      # Extract the first character
      ADDON_CLASS_SHORT="${ADDON_COMPONENTS[0]}"
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
      grass --tmp-project EPSG:4326 --exec g.extension prefix=/src/grass_addons extension=$ADDON url="/src/grass_addons/src/${ADDON_CLASS}/${ADDON}"
  else
      grass --tmp-project EPSG:4326 --exec g.extension prefix=/src/grass_addons extension=$ADDON url="$SERVER"
  fi
done < "$1"