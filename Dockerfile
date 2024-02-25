FROM debian:bullseye-20240211-slim

USER root

RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends \
    sudo \
    dnsutils \
    curl \
    git-all \
    ca-certificates=20210119 \
    lib32z1=1:1.2.11.dfsg-2+deb11u2 \
    wget=1.21-1+deb11u1 \
    locales \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && rm -rf /var/lib/apt/lists/* \
    && addgroup steam \
    && useradd -m steam \
    && usermod -aG sudo steam

ENV TICKRATE=""
ENV MAXPLAYERS=""
ENV API_KEY=""
ENV STEAM_ACCOUNT=""

RUN echo "steam ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/steam \
    && chmod 0440 /etc/sudoers.d/steam

RUN mkdir -p /home/cs2-modded-server

RUN mkdir -p /home/steam/cs2

WORKDIR /home/cs2-modded-server/

RUN chown -R steam:steam /home/steam/cs2

RUN git clone https://github.com/DanielDKnudsen/cs2-modded-server

RUN echo cloned repository

RUN mv /home/cs2-modded-server/cs2-modded-server/* /home/cs2-modded-server

RUN rm -rf /home/cs2-modded-server/cs2-modded-server

COPY ./custom_files /home/cs2-modded-server/custom_files/

COPY ./install_docker.sh /home/cs2-modded-server/install_docker.sh

WORKDIR /home/cs2-modded-server/

USER steam

CMD [ "sudo", "-E", "bash", "/home/cs2-modded-server/install_docker.sh" ]