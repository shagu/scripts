#!/bin/bash
# audiobook.sh
#   convert all selected files into an audiobook with chapters
#   based on the file-length and adding all images as cover art.
#
# dependencies:
#   - ffmpeg
#   - libmp4v2
#   - gpac
#   - faac
#
# usage:
#   audiobook.sh *.m4a
#

book=${PWD##*/}.m4a
chapter_start=0
i=0

# clean up previous results
rm -f "$book"
rm -rf .audiobook
mkdir -p .audiobook

# convert audio to aac and save chapterlist
for file in "$@"; do
  i=$((i+1))

  echo -e "\e[96m::\e[0m Adding \e[93m$file\e[0m"

  # convert to pcm-wav stereo 44100hz to make sure to have all in the same format
  ffmpeg -loglevel error -stats -i "$file" -vn -ar 44100 -ac 2 ".audiobook/$file.wav"

  # convert to Advanced Audio Coding (AAC)
  faac ".audiobook/$file.wav" -o ".audiobook/$file" -w
  rm ".audiobook/$file.wav"

  # append result to the new audiobook file
  MP4Box -cat ".audiobook/$file" "$book"
  rm ".audiobook/$file"

  # write result into chapter list
  echo "CHAPTER${i}=${chapter_start}" >> .audiobook/chapters
  echo "CHAPTER${i}NAME=$(basename "$file" .m4a)" >> .audiobook/chapters

  # read length to determine next chapter start
  chapter_start=$(MP4Box -info "$book" 2>&1 | sed -n 's/.*Computed Duration \(.*\) - Indicated.*/\1/p')
done

# edit and add chapters to audiobook
$EDITOR .audiobook/chapters
MP4Box -chap .audiobook/chapters "$book"
mp4chaps --convert --chapter-qt "$book"

# add all jpg files as cover art to audiobook
for file in *.jpg; do
  mp4art --add "$file" "$book"
done