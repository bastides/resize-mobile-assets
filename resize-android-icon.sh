#!/bin/bash
set -e

SOURCE_FILE="$1"
OUTPUT_PATH="$2"
VERSION=1.0.0

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $0 <source_file> <output_dir>

DESCRIPTION:
    This script generates Android product icons.

    <source_dir>	The source image file, 192x192 PNG with transparent background.
    <output_dir>	The destination path where icons will be generated.

    This script is depend on ImageMagick. So you must install ImageMagick first
    On OSX you can use 'sudo brew install ImageMagick' to install it

AUTHOR:
    Arthur Krupa<arthur.krupa@gmail.com>

LICENSE:
    This script is licensed under the terms of the MIT license.

EXAMPLE:
    $0 icon.png export
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
if [ ! -f "$SOURCE_FILE" ] ; then
	error "source file doesn't exist"
	exit 1
fi

# Check if destination path exist
if [ ! -d "$OUTPUT_PATH" ];then
    mkdir -p "$OUTPUT_PATH"
fi

# Create output directories
mkdir -p "$OUTPUT_PATH/mipmap-ldpi/"
mkdir -p "$OUTPUT_PATH/mipmap-mdpi/"
mkdir -p "$OUTPUT_PATH/mipmap-hdpi/"
mkdir -p "$OUTPUT_PATH/mipmap-xhdpi/"
mkdir -p "$OUTPUT_PATH/mipmap-xxhdpi/"
mkdir -p "$OUTPUT_PATH/mipmap-xxxhdpi/"

# Generate icon files
OUTPUT_FILE="ic_launcher.png";
cp "$SOURCE_FILE" "$OUTPUT_PATH/mipmap-xxxhdpi/$OUTPUT_FILE"
convert "$SOURCE_FILE" -resize 75% "$OUTPUT_PATH/mipmap-xxhdpi/$OUTPUT_FILE"
convert "$SOURCE_FILE" -resize 50% "$OUTPUT_PATH/mipmap-xhdpi/$OUTPUT_FILE"
convert "$SOURCE_FILE" -resize 37.5% "$OUTPUT_PATH/mipmap-hdpi/$OUTPUT_FILE"
convert "$SOURCE_FILE" -resize 25% "$OUTPUT_PATH/mipmap-mdpi/$OUTPUT_FILE"
convert "$SOURCE_FILE" -resize 18.75% "$OUTPUT_PATH/mipmap-ldpi/$OUTPUT_FILE"

success "product icons generated"