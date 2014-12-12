#! /bin/bash

declare -A PASTE_ARGS

#PASTE_URL='http://tty0.in/api/create'

syntax()
{
  echo "usage: $(basename "$0") [-p] [-e PERIOD[d|h|m]] [-t TITLE] [-u NAME] [-r PASTE_ID] [-l LANG] [FILE|-]";
  exit "$1";
}

while :; do
  getopts hpe:t:u:r:l: OPT
  case "$OPT" in
    h) # Help
      syntax 0
      ;;
    p) # Private paste
      PASTE_ARGS[p]='-dprivate=1'
      ;;
    e) # Expiry time - days, hours or minutes
      case "$OPTARG" in
        ?*d)
          PASTE_ARGS[e]="-dtime=$((${OPTARG%d} * 60 * 24))"
          ;;
        ?*h)
          PASTE_ARGS[e]="-dtime=$((${OPTARG%h} * 60))"
          ;;
        ?*m|?*)
          PASTE_ARGS[e]="-dtime=$((${OPTARG%m}))"
          ;;
        *)
          syntax 2
          ;;
      esac
      ;;
    t) # Title
      PASTE_ARGS[t]="-dtitle=$OPTARG"
      ;;
    u) # User
      PASTE_ARGS[u]="-dname=$OPTARG"
      ;;
    r) # This is a reply to the given paste ID
      PASTE_ARGS[r]="-dreply=$OPTARG"
      ;;
    l) # Language
      PASTE_ARGS[l]="-dlang=$OPTARG"
      ;;
    '?') # No more (recognised) options
      test "$?" = 0 && syntax 2
      break
      ;;
  esac
done

# Must be at most one parameter remaining
shift $(($OPTIND - 1))
test "$#" \> 1 && syntax 2

# Send the text
# If the file name is '-' or there is no parameter, read text from stdin
if test "${1:--}" = '-'; then
  curl "${PASTE_ARGS[@]}" --data-urlencode "text=$(cat)" "$PASTE_URL"
else
  curl "${PASTE_ARGS[@]}" --data-urlencode "text@$1" "$PASTE_URL"
fi
