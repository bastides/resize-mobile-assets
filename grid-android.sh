#!/bin/bash
set -e

TEMP_PATH="temp"
VERSION=1.0.0

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $0 <sources>

DESCRIPTION:
    This script overlays Android gridlines over layout images and saves the output as a new file.

    <sources>	The source images (as blob), should be smaller than 1920x1920 px.

    This script is depend on ImageMagick. So you must install ImageMagick first
    On OSX you can use 'sudo brew install ImageMagick' to install it

AUTHOR:
    Arthur Krupa<arthur.krupa@gmail.com>

LICENSE:
    This script is licensed under the terms of the MIT license.

EXAMPLE:
    $0 images export
EOF
}

# Create grid image
grid() {
GRID_COLOR="magenta"
GRID_LINE_ALPHA="0.2"
GRID_SEPARATOR_ALPHA="0.4"
GRID_OUTPUT_FILE="grid.png"
GRID_CELL_SIZE=8
GRID_SEPARATOR=2
GRID_WIDTH=1920
GRID_HEIGHT=1920
GRID_CMD_LINE=""
GRID_ROWS=$(($GRID_HEIGHT/$GRID_CELL_SIZE))
GRID_COLUMNS=$(($GRID_WIDTH/$GRID_CELL_SIZE))

mkdir -p "$TEMP_PATH"

# draw horizontal grid lines
i=1; GRID_ROW_Y=$GRID_CELL_SIZE
while [ $i -lt $GRID_ROWS ]; do
	opacity=$GRID_LINE_ALPHA
	if [ $(( $i % $GRID_SEPARATOR )) -eq 0 ]; then
		opacity=$GRID_SEPARATOR_ALPHA
	fi
	GRID_CMD_LINE="${GRID_CMD_LINE} stroke-opacity $opacity line 0,$GRID_ROW_Y $GRID_WIDTH,$GRID_ROW_Y"
	GRID_ROW_Y=$(( $GRID_ROW_Y + $GRID_CELL_SIZE ))
	(( i++ ))
done

# draw vertical grid lines
i=1; GRID_ROW_X=$GRID_CELL_SIZE
while [ $i -lt $GRID_ROWS ]; do
	opacity=$GRID_LINE_ALPHA
	if [ $(( $i % $GRID_SEPARATOR )) -eq 0 ]; then
		opacity=$GRID_SEPARATOR_ALPHA
	fi
	GRID_CMD_LINE="${GRID_CMD_LINE} stroke-opacity $opacity line $GRID_ROW_X,0 $GRID_ROW_X,$GRID_HEIGHT"
	GRID_ROW_X=$(( $GRID_ROW_X + $GRID_CELL_SIZE ))
	(( i++ ))
done

convert -size ${GRID_WIDTH}x${GRID_HEIGHT} xc:transparent -fill none -stroke $GRID_COLOR -draw "${GRID_CMD_LINE}" "$TEMP_PATH/$GRID_OUTPUT_FILE"
}

success() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo -e "[${green}SUCCESS${normal}] $1"
}

error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo -e "[${red}ERROR${normal}] $1"
}

# Check ImageMagick
command -v convert >/dev/null 2>&1 || { error >&2 "ImageMagick is not installed"; exit -1; }

# Check param
if [[ $# -lt 1 ]] ; then
	usage
	exit 1
fi

# Count number of files to process
count=0
skipped=0
total=("$@")
total=${#total[@]}

# Create PNG file with grid, to be composited over source files
grid

# Iterate through source files and composite images
for image in "$@"; do
	name=$(basename "${image}"); directory=$(dirname "${image}"); ext="${name##*.}"; name="${name%.*}"; opt=""; output="${name}.grid.${ext}";
	((count++))
	percent=$((count * 100 / total))
	echo -ne "Applying grid: ${percent}%\r"
	
	if [[ ${image} =~ .*\.(jpg|jpeg|png|bmp|gif|webp) ]]; then
		composite -gravity NorthWest -compose Multiply "${TEMP_PATH}/${GRID_OUTPUT_FILE}" "${image}" "$directory/${output}"		
	else
		((skipped++))
		continue
	fi
done

# Remove temporary directory
rm -rf "${TEMP_PATH}"

# Final messages
echo "Applying grid: 100%"
success "${count} files processed (${skipped} files skipped)"