#!/bin/bash
# set -x

downloadSpeed=""

downloadUrl=$1
downloadLocation=${2:-/tmp/}
if [ ! -z "$3" ]; then downloadSpeed="--limit-rate=$3"; fi 

mkdir -p $downloadLocation
cd $downloadLocation
  
wget -c --progress=bar:force:noscroll $downloadSpeed $downloadUrl
case "${downloadUrl##*.}" in
    xz)
        echo "XZ file, decompressing"; xz -d -k -f "${downloadUrl##*/}"
        ;;
    gz)
        echo "GZ file, decompressing"; gunzip -k -d -f "${downloadUrl##*/}"
        ;;
    *)
        echo "No action for this file format"
        ;;
esac
