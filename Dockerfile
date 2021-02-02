FROM openjdk:11-slim-buster
RUN apt-get -qq update && apt-get -qq -y install wget tcpdump libpcap0.8-dev
RUN wget -qO- \
"https://codeberg.org/iortega/TCPDUMP_and_CICFlowMeter/archive/v0.2.1.tar.gz" | \
tar zxf -

WORKDIR tcpdump_and_cicflowmeter
RUN chmod +x capture_interface_pcap.sh
RUN chmod +x convert_pcap_csv.sh
RUN chmod +x command.sh
RUN sed -i 's|sudo||g' ./capture_interface_pcap.sh

ENTRYPOINT ["./command.sh"]
CMD ["capture", "-i", "eth0","-d", "pcap", "-Z", "root","-G", "10"]
