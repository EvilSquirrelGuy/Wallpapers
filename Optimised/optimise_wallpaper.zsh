#! /usr/bin/env zsh

# USAGE: optimise_wallpaper.sh <input.heic> [quality=50]
#
# Outputs to input_OPTIMISED.heic

INPUT="$1"
QUALITY="${2:-50}"

FRAMEDIR=".$(crc32 $1 | tr -d '\n')_frames"

# make temp dir
mkdir "$FRAMEDIR"

# extract frames
heif-convert "$INPUT" --with-exif --png-compression-level 0 -o "$FRAMEDIR/frame.png"

# rename frames so they are ordered correctly

for f in $FRAMEDIR/frame-[0-9].png; do
  num=$(basename "$f" | grep -o '[0-9]\+')
  newnum=$(printf "%02d" "$num")
  # echo "$f $num $newnum"
  mv "$f" "$FRAMEDIR/frame-$newnum.png"
done

# generate filename for optimised
outfile="${INPUT%.heic}_OPTIMISED.heic"

# re-encode but much more optimised (this may take a while)
heif-enc -q $QUALITY -b 8 -p x265:format=yuvj420p -p x265:preset=veryslow $FRAMEDIR/*.png -o "$outfile"

# clean up
rm -rf "$FRAMEDIR"
