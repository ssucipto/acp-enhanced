# sourced function library
trap 'rm -f "$TMP"' EXIT
sed -i '' "s/a/b/" "$1"
