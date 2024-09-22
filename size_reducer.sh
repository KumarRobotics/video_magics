RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

########################################
# Parameters
# Modify these to fit your needs
initial_quality=1000k # Initial quality to estimate the output size
target_size=19500000 # Target size in bytes. Make it slightly smaller than 20*2**6
encoder=x264 # Either x264 or x265
########################################

# Check for input arguments. Only a single argument is allowed, the file name
if [ "$#" -ne 1 ]; then
  echo -e "${RED}Illegal number of parameters"
  echo -e "${RED}Usage: size_reducer.sh <input_video>"
  exit 1
fi

# Input video is the first argument
# Output video has the same format, but with mp4 extension and with _reduced suffix
input=$1
output=${input%.*}_reduced.mp4

# Check that the input file exists
if [ ! -f "$input" ]; then
  echo -e "${RED}File $input does not exist"
  exit 1
fi

# Set the initial quality to 950k
quality=$initial_quality

# Print the input and quality
echo -e "${YELLOW}Input: $input"
echo -e "${YELLOW}Quality: $quality"

if [ "$encoder" == "x265" ]; then
  echo -e "${YELLOW}Encoder: x265"
  libx="-c:v libx265"
  xparams="-x265-params"
elif [ "$encoder" == "x264" ]; then
  echo -e "${YELLOW}Encoder: x264"
  libx="-c:v libx264"
  xparams="-x264-params"
else
  echo -e "${RED}Encoder $encoder not supported"
  exit 1
fi

# Perform first compression
echo -e "${GREEN}Performing first compression"
ffmpeg -hide_banner -loglevel warning -y -i "$input" $libx -b:v "$quality" \
  $xparams pass=1 -an -f null /dev/null && \
  ffmpeg -hide_banner -loglevel warning -y -i "$input" $libx -b:v "$quality" \
  $xparams pass=2 -c:a aac -b:a 64k "$output"

# Get the size of the output file and modify the quality accordingly to fit
output_size=$(stat -c%s "$output")
multiplier=$(echo "scale=2; $output_size / $target_size" | bc)
# Remove the k from quality
quality_without_k=${quality%k}
new_quality=$(echo "scale=0; $quality_without_k / $multiplier" | bc)

# Add k to new quality
new_quality=${new_quality}k
echo -e "${GREEN}New quality: $new_quality"

# Compress again
echo -e "${GREEN}Performing second compression"
ffmpeg -hide_banner -loglevel warning -y -i "$input" $libx -b:v "$new_quality" \
  $xparams pass=1 -an -f null /dev/null && \
  ffmpeg -hide_banner -loglevel warning -y -i "$input" $libx -b:v "$new_quality" \
  $xparams pass=2 -c:a aac -b:a 64k "$output"

# Get final size
output_size=$(stat -c%s "$output")
echo -e "${GREEN}Final size: $output_size"
