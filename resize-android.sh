#!/bin/bash
set -e

SOURCE_PATH="$1"
OUTPUT_PATH="$2"
VERSION=1.0.0

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $0 <source_dir> <output_dir> [--webp]

DESCRIPTION:
    This script generates image assets te be used in Android apps.

    <source_dir>	The source image directory. Images inside it should be in XXXHDPI sizing.
    <output_dir>	The destination path where assets will be generated.
	--webp			Save output files in WebP format

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
if [[ $# -lt 2 ]] ; then
	usage
	exit 1
fi

# Check if source path exist
if [ ! -d "$SOURCE_PATH" ] ; then
	error "source directory doesn't exist"
	exit 1
fi

# Check if destination path exist
if [ ! -d "$OUTPUT_PATH" ];then
    mkdir -p "$OUTPUT_PATH"
fi

# Check if WebP format is being used
if [[ $3 == "--webp" ]]; then
	echo "JPGs will be converted to WebP format"
fi

# Count number of files to process
count=0
total=($1/*.*)
total=${#total[@]}

# Create output directories
mkdir -p "$OUTPUT_PATH/drawable-ldpi/"
mkdir -p "$OUTPUT_PATH/drawable-mdpi/"
mkdir -p "$OUTPUT_PATH/drawable-hdpi/"
mkdir -p "$OUTPUT_PATH/drawable-xhdpi/"
mkdir -p "$OUTPUT_PATH/drawable-xxhdpi/"
mkdir -p "$OUTPUT_PATH/drawable-xxxhdpi/"

# Iterate through files
for image in "${SOURCE_PATH}/*.*"; do
	name=$(basename "$image"); ext="${name##*.}"; name="${name%.*}"; opt="";
	if [ "$3" == "--webp" ] && [ "$ext" == "jpg" ]; then
		output="${name}.webp";
		opt="-quality 85 -define webp:lossless=false"
	else
		output="${name}.${ext}";
	fi
	
	convert "$image" $opt "$OUTPUT_PATH/drawable-xxxhdpi/${output}"
	convert "$image" -resize 75% $opt "$OUTPUT_PATH/drawable-xxhdpi/${output}"
	convert "$image" -resize 50% $opt "$OUTPUT_PATH/drawable-xhdpi/${output}"
	convert "$image" -resize 37.5% $opt "$OUTPUT_PATH/drawable-hdpi/${output}"
	convert "$image" -resize 25% $opt "$OUTPUT_PATH/drawable-mdpi/${output}"
	convert "$image" -resize 18.75% $opt "$OUTPUT_PATH/drawable-ldpi/${output}"
	((count++))
	percent=$((count * 100 / total))
	echo -ne "Generating assets: ${percent}%\r"
done

echo "Generating assets: 100%"
success "${count} files processed"
