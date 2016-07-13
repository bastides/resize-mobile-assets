## Resize mobile assets

Bash scripts for resizing *Android* and *iOS* images assets.

- `resize-android.sh` for Android drawables (LDPI to XXXHDPI)
- `resize-android-icon.sh` for Android product icons (i.e. launcher icons)
- `resize-ios.sh` for iOS assets (@1x to @3x)
- `resize-ios-icon.sh` for iOS and iWatch app icons

## Instructions

Run each script without parameters to display usage instructions, e.g. `./resize-android.sh`.

## Requirements

ImageMagick has to be installed and present in the PATH in order to use these scripts. Please see OS-specific instructions on how to do that.

## Credits

- Pawpaw ([ios-icon-generator](https://github.com/smallmuou/ios-icon-generator))

## License

This script is licensed under the terms of the MIT license.