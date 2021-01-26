#!/usr/bin/env sh

com="$1"
shift
if [ "$com" = "convert" ]; then
    ./convert_pcap_csv.sh $@
elif [ "$com" = "capture" ]; then
    ./capture_interface_pcap.sh $@
fi
