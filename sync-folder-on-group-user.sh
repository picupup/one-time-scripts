#!/bin/bash

echo -e "\n\n\n[$(date '+%FT%T')]\n\n"
set -e  # Exit on error
set -x  # Debug mode

groupuser=${1:-"cia-2024"}

repo=${2:-"/home/$LOGNAME/bericht_webseite"}
dest_dir=${3:-"/var/www/html/${groupuser}"}

copy=$(mktemp -d)

# Ensure repo exists
if [[ ! -d "$repo" ]]; then
  echo "Error: Repository $repo not found!"
  exit 1
fi

# Pull latest changes
git -C "$repo" pull

# Copy files excluding hidden ones and README*
rsync -av --progress --exclude='.*' --exclude='README*' "$repo/" "$copy/"

# Set permissions
find "$copy" -type d -exec chmod 755 {} + \
  -o -type f -exec chmod 744 {} +

# Transfer to target user
sudo -iu ${groupuser} bash -c "rsync -av '$copy/' '$dest_dir/'"

# Cleanup
rm -rf "$copy"
echo "✅ Deployment successful!"
