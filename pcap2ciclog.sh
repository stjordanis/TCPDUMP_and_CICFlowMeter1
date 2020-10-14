#!/bin/bash

./capture_interface_pcap.sh -i wlan0 -d pcap -Z "$(id -nu 1000)"
