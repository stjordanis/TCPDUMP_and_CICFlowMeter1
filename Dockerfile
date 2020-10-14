FROM openjdk:11-slim-buster
RUN apt-get -qq update && apt-get -qq -y install wget tcpdump libpcap0.8-dev
RUN wget -qO- \
"https://codeberg.org/iortega/TCPDUMP_and_CICFlowMeter/archive/master.tar.gz" | \
tar zxf -

WORKDIR TCPDUMP_and_CICFlowMeter-master
RUN chmod +x capture_interface_pcap.sh
RUN sed -i 's|sudo||g' ./capture_interface_pcap.sh

ENTRYPOINT ["./capture_interface_pcap.sh"]
CMD ["-i", "eth0","-d", "pcap", "-Z", "root","-G", "10"]
