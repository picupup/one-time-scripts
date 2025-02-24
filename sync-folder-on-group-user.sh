#!/bin/bash
# In this script it syncs the browser page with the content from the repository.
# Variable `$LOGNAME` is used instead of `$HOME` or `$USER`, because they might not be set while cronjob is running

echo -e "\n\n\n[$(date '+%FT%T')]\n\n"
set -e  # Exit on error
set -x  # Debug mode

groupuser=${1:-"cia-2024"}
name="bericht_webseite"
repo="/home/$LOGNAME/repos/$name"
dest_dir="/var/www/html/${groupuser}"

copy=/home/$LOGNAME/tmp/$name
mkdir -p $copy

# Ensure repo exists
if [[ ! -d "$repo" ]]; then
  echo "Error: Repository $repo not found!"
  exit 1
fi

# Pull latest changes
git -C "$repo" pull

if [[ -d "${repo}/dist" ]]; then
  repo="${repo}/dit"
fi

# Copy files excluding hidden ones and README*
rsync -av --delete --exclude='.*' --exclude='README*' "$repo/" "$copy/"

# Set permissions
find "$copy" -type d -exec chmod 755 {} + \
  -o -type f -exec chmod 744 {} +

# Transfer to target user
sudo -iu ${groupuser} bash -c "rsync -av --delete --exclude='cia-diashow*' '$copy/' '$dest_dir/'"

echo "Deployment successful!"
