RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

# Input video is the first argument
# Output video has the same format, but with mp4 extension and with _reduced suffix
input=$1
output=${input%.*}.mp4
#
# Set the quality to 950k
quality=5000k

# Print in yellow input and quality
echo -e "${YELLOW}Input: $input"
echo -e "${YELLOW}Quality: $quality"


# H265
# ffmpeg -y -i "$input" -c:v libx265 -b:v "$quality" -x265-params pass=1 -an -f
# null /dev/null && ffmpeg -i "$input" -c:v libx265 -b:v "$quality" -x265-params
# pass=2 -c:a aac -b:a 64k "$output"
#
# H264
ffmpeg -hide_banner -loglevel warning -y -i "$input" -c:v libx264 \
  -b:v "$quality" -x264-params pass=1 -an -f null /dev/null && \
  ffmpeg -hide_banner -loglevel warning -y -i "$input" -c:v libx264 \
  -b:v "$quality" -x264-params pass=2 -c:a aac -b:a 64k "$output"

# Get the size of the output file and modify the quality accordingly to fit in
# 20 MB
output_size=$(stat -c%s "$output")
multiplier=$(echo "scale=2; $output_size / 98000000" | bc)
# don't forget to remove the k from quality
quality_without_k=${quality%k}
new_quality=$(echo "scale=0; $quality_without_k / $multiplier" | bc)

# Add k to new quality
new_quality=${new_quality}k
# Print new quality in green
echo -e "${GREEN}New quality: $new_quality"

# Compress again
ffmpeg -hide_banner -loglevel warning -y -i "$input" -c:v libx264 \
  -b:v "$new_quality" -x264-params pass=1 -an -f null /dev/null && \
  ffmpeg -hide_banner -loglevel warning -y -i "$input" -c:v libx264 \
  -b:v "$new_quality" -x264-params pass=2 -c:a aac -b:a 64k "$output"

# Get final size
output_size=$(stat -c%s "$output")

# print in green
echo -e "${GREEN}Final size: $output_size"
