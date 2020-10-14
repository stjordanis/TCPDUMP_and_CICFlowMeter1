#!/bin/bash

usage() {
    echo \
    "Usage: $0 [-i interface] [-d out_dir] [-Z user] [-G rotate_seconds] \
[-m max_seconds]" 1>&2
}

rotate_interval=60
interface="eth0"
output_dir="pcap"
user="root"
max_seconds=5
while getopts ":i:m:d:Z:G:" option; do
    case "${option}" in
        m)
            max_seconds="${OPTARG}"
            ;;
        i)
            interface="${OPTARG}"
            ;;
        d)
            output_dir="${OPTARG}"
            ;;
        Z)
            user="${OPTARG}"
            ;;
        G)
            rotate_interval="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

[[ "$(grep -c "$interface" /proc/net/dev)" == "0" ]] && echo "The interface is NOT found!" && exit 255
[[ ! -d "$output_dir" ]] && echo "The output directory does NOT exist!" && exit 255

# Clean
cleanup() {
	echo "=== Capturer is being cancled ==="
    echo "=== Wait the converter finished for 3 seconds..."
	sleep 3
	echo
	echo "=== Convert left PCAP files if any"
	OIFS="$IFS"
	IFS=$'\n'
	for f in `find "${output_dir}" -type f -name "*.pcap"`; do
		echo "=== $f is left"
		"${post_rotate_command}" "$f"
	done
	IFS="$OIFS"

    echo "=== Clean stuff up"
    rm -f "$output_dir"/*.pcap

	echo
    exit 0
}

trap 'cleanup' INT TERM EXIT

#output_file=${output_dir}/$(date +'%Y-%m-%d-%H:%M:%S.pcap')
output_file_format=${output_dir}/'%Y-%m-%d-%H:%M:%S.pcap'
options="-n -nn -N -s 0"

[[ ! -z "${user}" ]] && options="${options} -Z ${user}"  #$(id -nu 1000)

# Before the post-rotatation script can be run, please edit an AppArmor configuration file:
#   $ sudo vi /etc/apparmor.d/usr.sbin.tcpdump
# by adding the line:
#   /**/* ixr,
# then
#   $ sudo service apparmor restart
#
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  # On the same directory.
post_rotate_command="${script_dir}"/convert_pcap_csv.sh

timeout_time=$(echo "${max_seconds} + 3 + ${rotate_interval}*0.2" | bc)
sudo timeout "$max_seconds" tcpdump ${options} -z "${post_rotate_command}" -i ${interface} -G ${rotate_interval} -w "${output_file_format}"

#sudo chown 1000:1000 "${output_dir}"/*
