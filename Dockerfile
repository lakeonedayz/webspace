FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y shellinabox sudo && \
    apt-get clean

# senha root (exemplo)
RUN echo 'root:root' | chpasswd

EXPOSE 4200

CMD ["/usr/bin/shellinaboxd", \
     "--no-beep", \
     "--disable-ssl", \
     "--port=4200", \
     "--service=/terminal:root:root:/root:/bin/bash"]
