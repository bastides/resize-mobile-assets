#!/bin/bash
set -e

SOURCE_PATH="$1"
OUTPUT_PATH="$2"
VERSION=1.0.0

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $0 <source_dir> <output_dir>

DESCRIPTION:
    This script generates image assets te be used in iOS apps.

    <source_dir> - The source image directory. Images inside it should be in @3x sizing.
    <output_dir> - The destination path where assets will be generated.

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
if [[ $# != 2 ]] ; then
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

# Count number of files to process
count=0
total=($1/*.*)
total=${#total[@]}

# Iterate through files
for image in $1/*.*; do
	name=$(basename "$image"); ext="${name##*.}"; name="${name%.*}"
	cp "$image" "$OUTPUT_PATH/${name}@3x.$ext"
	convert "$image" -resize 66.66% "$OUTPUT_PATH/${name}@2x.$ext"
	convert "$image" -resize 33.33% "$OUTPUT_PATH/${name}.$ext"
	((count++))
	percent=$((count * 100 / total))
	echo -ne "Generating assets: ${percent}%\r"
done

echo "Generating assets: 100%"
success "${count} files processed"