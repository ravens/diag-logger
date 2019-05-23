FROM ubuntu:18.04
MAINTAINER Yan Grunenberger <yan@grunenberger.net>
RUN apt-get -qy update
RUN apt-get -qy install python-pip git libusb-dev
WORKDIR /root
RUN pip install pyusb
RUN pip install scapy
RUN git clone https://github.com/mitshell/CryptoMobile && cd CryptoMobile && python setup.py install
RUN git clone https://github.com/P1sec/pycrate && cd pycrate && python setup.py install
COPY diag-logger.py /root/diag-logger.py
ENTRYPOINT ["python","/root/diag-logger.py"] 