#!/bin/bash
set -euxo pipefail


convert_to_raw() {
  local input=$1
  local start_time=$2
  local duration=$3
  # Add _converted before the extension, remove the leading path, and change the extension to .mov
  output=$(basename "$input" | sed 's/\.[^.]*$//')_converted.mov
  # save the output into the converted_vids folder
  output="converted_vids/$output"
  ffmpeg -i "$input" -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -an -f mov \
    -ss "$start_time" -t "$duration" "$output"
}

mkdir -p converted_vids

# Use: convert_to_raw timestamp_beginning duration
convert_to_raw vids/DJI_VirginiaForest_0009_D.MP4 00:00:18 00:00:20
