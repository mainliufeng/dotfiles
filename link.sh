for dir in */; do
  if [ -e "$dir/link.sh" ]; then
    sh "$dir/link.sh"
  fi
done