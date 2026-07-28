# sourced function library
if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i '' "s/a/b/" "$1"
else
  sed -i "s/a/b/" "$1"
fi
trap 'rm -f "$TMP"' EXIT
trap - EXIT
