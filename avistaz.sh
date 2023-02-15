#!/bin/bash

torrent_name="$1"
download_directory="$2"
torrent_directory=
cookie_directoy=
torrent_processed=


sleep 30

avistaz=$(transmission-show $torrent_directory/"$torrent_name".torrent | grep 'Comment:' | grep -oE 'https://[^ ]+')

dir="$download_directory"

if [ -d "$download_directory"/"$torrent_name" ]; then
    dir="$download_directory"/"$torrent_name"
fi

wget --load-cookies=$cookie_directory/avistaz.to_cookies.txt --recursive --accept=zip,rar,srt --accept-regex=english-subtitle --no-directories --directory-prefix="$dir"/ $avistaz

for archive in "$dir"/*.{zip,rar}; do
  if [ -f "$archive" ]; then
    case "$archive" in
      *.zip) unzip -j -o "$archive" -d "$dir" && rm "$archive" ;;
      *.rar) unrar e "$archive" "$dir" && rm "$archive" ;;
    esac
  fi
done

mv $torrent_directory/"$torrent_name".torrent $torrent_processed
