#!/bin/bash
# Rewrote the script so that it is better understood by others on how to use it

# On qbitorrent or other torrent dowloader set it to run this script on torrent download I am using qbittorrent so using the examples for it but it could be made to work with other torrent apps as well. To run this script you need to transmission installed at its cli is used to read the torrent file. And wget to download the subtitle.

#save the script as avistaz.sh then in qbittorrent set the script to be run on torrent added with these flags avistaz.sh "%N" "%D". Also set copy  

#The first flag %N
torrent_name="$1"

#The 2nd flag %D
download_directory="$2"

#The directory where qbittorent saves the torrent file when added the option should be enalbed in qbittorrent and directory should be added here as well 
torrent_save=""

#The directory where .torrent are moved to after passing through this script 
torrent_processed=""
 
#extract the avistaz cookie file from chrome and save it to this directory you can use any cookies extractor plugin in chrome rememeber to save the cookie file as avistaz.to_cookies.txt
cookie_directory=""

#set the temporary directory where single episode srt will be downloaded before it can be renamed and moved beside the file 
temp_srt=""

#set the script to sleep for 30 seconds to make sure the torrent file has already been added
sleep 30

#get the torrrnt file page for wget to download subtitle
avistaz=$(transmission-show "$torrent_save""$torrent_name".torrent | grep 'Comment:' | grep -oE 'https://[^ ]+')

#this is used so that for series torrents the subtitles are downloaded and extracted into the torrent folder for sonarr to be able to detect
dir="$download_directory"

if [ -d "$download_directory"/"$torrent_name" ]; then
    dir="$download_directory"/"$torrent_name"
fi

#use wget to download available zip or rar subtittes 
wget --load-cookies=$cookie_directory/avistaz.to_cookies.txt --recursive --accept=zip,rar --accept-regex=english-subtitle --no-directories --directory-prefix="$dir"/ $avistaz

#use wget to download single episode subtitle to temp directory so that can be renamed and moved in the next step
wget --load-cookies=$cookie_directory/avistaz.to_cookies.txt --recursive --accept=srt --accept-regex=english-subtitle --no-directories --directory-prefix="$temp_srt"/ $avistaz 


#extrating zip and rar based subtitles
for archive in "$dir"/*.{zip,rar}; do
  if [ -f "$archive" ]; then
    case "$archive" in
      *.zip) unzip -j -o "$archive" -d "$dir" && rm "$archive" ;;
      *.rar) unrar e "$archive" "$dir" && rm "$archive" ;;
    esac
  fi
done

#renaming and moving single episode subttitles 
for file in "$temp_srt"/*.srt; do
  mv "$file" "$dir/${1%.*}.en.srt"
done




mv "$torrent_save""$torrent_name".torrent "$torrent_processed"
