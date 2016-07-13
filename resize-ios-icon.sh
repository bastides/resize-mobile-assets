#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_FILE="$1"
OUTPUT_PATH="$2"
IOS_DIR="iOS"
IWATCH_DIR="iWatch"
APPICON_DIR="AppIcon.appiconset"
VERSION=1.0.0

usage() {
cat << EOF
VERSION: $VERSION
USAGE:
    $0 <source_file> <output_dir>

DESCRIPTION:
    This script generates iOS app icon assets from a single image file.

    <source_file> - The source image file, should be at least 1024x1024px in size (preferably 1536x1536px).
    <output_dir> - The destination path where icons will be generated.

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
if [[ $# != 2 ]] ; then
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

# Generate icons (https://developer.apple.com/library/ios/qa/qa1686/_index.html)
echo -e 'Generating files:'

ITUNES_OUTPUT="$OUTPUT_PATH/$IOS_DIR"
mkdir -p "$ITUNES_OUTPUT"
convert "$SOURCE_FILE" -resize 512x512 "$ITUNES_OUTPUT/iTunesArtwork.png"
convert "$SOURCE_FILE" -resize 1024x1024 "$ITUNES_OUTPUT/iTunesArtwork@2x.png"
convert "$SOURCE_FILE" -resize 1536x1536 "$ITUNES_OUTPUT/iTunesArtwork@3x.png"
echo -e '> iTunes artworks'

IOS_OUTPUT="$OUTPUT_PATH/$IOS_DIR/$APPICON_DIR"
mkdir -p "$IOS_OUTPUT"
convert "$SOURCE_FILE" -resize 29x29 "$IOS_OUTPUT/Icon-App-29x29@1x.png"
convert "$SOURCE_FILE" -resize 58x58 "$IOS_OUTPUT/Icon-App-29x29@2x.png"
convert "$SOURCE_FILE" -resize 87x87 "$IOS_OUTPUT/Icon-App-29x29@3x.png"
convert "$SOURCE_FILE" -resize 40x40 "$IOS_OUTPUT/Icon-App-40x40@1x.png"
convert "$SOURCE_FILE" -resize 80x80 "$IOS_OUTPUT/Icon-App-40x40@2x.png"
convert "$SOURCE_FILE" -resize 120x120 "$IOS_OUTPUT/Icon-App-40x40@3x.png"
convert "$SOURCE_FILE" -resize 60x60 "$IOS_OUTPUT/Icon-App-60x60@1x.png"
convert "$SOURCE_FILE" -resize 120x120 "$IOS_OUTPUT/Icon-App-60x60@2x.png"
convert "$SOURCE_FILE" -resize 180x180 "$IOS_OUTPUT/Icon-App-60x60@3x.png"
convert "$SOURCE_FILE" -resize 76x76 "$IOS_OUTPUT/Icon-App-76x76@1x.png"
convert "$SOURCE_FILE" -resize 152x152 "$IOS_OUTPUT/Icon-App-76x76@2x.png"
convert "$SOURCE_FILE" -resize 228x228 "$IOS_OUTPUT/Icon-App-76x76@3x.png"
convert "$SOURCE_FILE" -resize 167x167 "$IOS_OUTPUT/Icon-App-83.5x83.5@2x.png"
cat "$SCRIPT_DIR/resize-ios-icon/ios.json" > "$IOS_OUTPUT/Contents.json"
echo -e '> iOS app icons'

IWATCH_OUTPUT="$OUTPUT_PATH/$IWATCH_DIR/$APPICON_DIR"
mkdir -p "$IWATCH_OUTPUT"
convert "$SOURCE_FILE" -resize 48x48 "$IWATCH_OUTPUT/Icon-24@2x.png"
convert "$SOURCE_FILE" -resize 55x55 "$IWATCH_OUTPUT/Icon-27.5@2x.png"
convert "$SOURCE_FILE" -resize 58x58 "$IWATCH_OUTPUT/Icon-29@2x.png"
convert "$SOURCE_FILE" -resize 87x87 "$IWATCH_OUTPUT/Icon-29@3x.png"
convert "$SOURCE_FILE" -resize 80x80 "$IWATCH_OUTPUT/Icon-40@2x.png"
convert "$SOURCE_FILE" -resize 88x88 "$IWATCH_OUTPUT/Icon-44@2x.png"
convert "$SOURCE_FILE" -resize 172x172 "$IWATCH_OUTPUT/Icon-86@2x.png"
convert "$SOURCE_FILE" -resize 196x196 "$IWATCH_OUTPUT/Icon-98@2x.png"
cat "$SCRIPT_DIR/resize-ios-icon/iwatch.json" > "$IWATCH_OUTPUT/Contents.json"
echo -e '> iWatch app icons'

success "all icons generated"