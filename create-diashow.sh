#!/usr/bin/env bash
# Arguments: 1: download URL; [2: img_duration]; [3: output filename]; 
#
# SUMMARY: The script automates the process of downloading, processing, and converting images into a video slideshow. 
# It takes three arguments: image duration per frame, output filename, and download URL for a ZIP file containing images. 
# The script extracts the images, resizes them to a standard resolution, adds titles based on filenames, and generates a video using FFmpeg. 
# If applicable, the final video is copied to a web directory. Temporary files are cleaned up after execution, and execution time is logged. 

start=$(date '+%s')
timestamp=$(date '+%FT%T')

# Configurable variables
frame_rate=0.25  # Currently unused
download_url=${1:?'Download URL is required'}
img_duration=${2:-6}
name=${3:-"diashow"}


# Create temporary directory
dir=$(mktemp -d)
echo "Temporary directory: $dir"
cd "$dir" || { echo "Failed to create temporary directory."; exit 1; }

# Download and extract images
echo 'Downloading...'
curl -sL "$download_url" -o "$name.zip" || { echo "Download failed."; rm -rf "$dir"; exit 1; }
echo 'Unzipping...'
unzip "$name.zip" &>/dev/null || { echo "Unzip failed."; rm -rf "$dir"; exit 1; }
cd */ || { echo "Error changing to extracted directory."; rm -rf "$dir"; exit 1; }

# Create directory for processed images
PNGDIR=png_images_with_titles
mkdir -p $PNGDIR

# Image settings
target_width=1920
target_height=1080
file_counter=0

# Process images
old_ifs="$IFS"
IFS=$'\n'
names_file="$name.txt"
names=${PNGDIR}/${names_file}
> $names

for file in $(ls -1 *.jpg *.JPG *.jpeg *.JPEG *.png *.PNG 2>/dev/null | sort -n); do
  if [ -f "$file" ]; then
    title="${file##*;}"
    title="${title%.*}"
    title=$(echo "$title" | tr '_' ' ' | tr ':' ',' | tr -dc '[:alnum:]ÄÖÜäöüß<>.,()\-\+&? ')
    new_file_name="${file_counter}.${file##*.}"
    mv "${file}" "${new_file_name}" || { echo "mv failed"; exit 1; }
    file="${new_file_name}"
    echo -e "file '${file_counter}.png'\nduration ${img_duration}" >> $names
    
    echo -e "Processing:	${file_counter}	'${file}'"
    ffmpeg -i "${file}" -vf "scale=${target_width}:${target_height}:force_original_aspect_ratio=decrease,pad=${target_width}:${target_height}:(ow-iw)/2:(oh-ih)/2:color=white, \
      drawbox=y=0:color=white:width=iw:height=100:t=fill, \
      drawtext=text='${title}':fontcolor=black:fontsize=48:x=(w-text_w)/2:y=20" \
      "${PNGDIR}/${file%.*}.png" &>/dev/null || { echo "Error processing '${file}'"; rm -rf "$dir"; exit 1; }
    
    file_counter=$((++file_counter))
  fi
done

IFS="$old_ifs"

# Check if images exist
if [ -z "$(ls -A ${PNGDIR} 2>/dev/null)" ]; then
  echo "No valid images found."
  rm -rf "$dir"
  exit 1
fi

# Create video
echo "Creating video with ${img_duration} seconds per image"
ffmpeg -f concat -safe 0 -i ${names_file} -c:v libx264 -pix_fmt yuv420p "$name.mp4" || { echo "Video creation failed."; rm -rf "$dir"; exit 1; }

# Function to copy the file
function copy {
  local fn=${1:?'File name not provided'}
  if [ -d "/var/www/html/$LOGNAME-web/" ]; then
    cp "${fn}" "/var/www/html/$LOGNAME-web/"
    echo "Video copied to /var/www/html/$LOGNAME-web/${fn}"
  elif [ -d "/var/www/html/$LOGNAME/" ]; then
    cp "${fn}" "/var/www/html/$LOGNAME/"
    echo "Video copied to /var/www/html/$LOGNAME/${fn}"
  fi
}

# Copy video if successful
if [ -f "$name.mp4" ]; then
  copy "$name.mp4"
else
  echo "Error: Video not found after creation."
  rm -rf "$dir"
  exit 1
fi

# Cleanup
echo "Cleaning up temporary files."
rm -rf "$dir"
end=$(date '+%s')
echo "${timestamp}: $name; Duration '$((($end - $start) / 60))' minutes; until $(date '+%T')" >> ~/.diashow.update.time
