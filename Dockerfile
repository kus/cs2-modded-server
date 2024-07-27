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
    && rm -rf /var/lib/apt/lists/*


RUN addgroup steam \
    && useradd -g steam steam \
    && usermod -aG sudo steam

ENV TICKRATE=""
ENV MAXPLAYERS=""
ENV API_KEY=""
ENV STEAM_ACCOUNT=""

RUN echo "steam ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/steam \
    && chmod 0440 /etc/sudoers.d/steam

ENV HOME="/home/steam/cs2/"

RUN mkdir -p $HOME && \
    chown -R steam:steam $HOME

ENV SRC_DIR="/home/cs2-modded-server"

WORKDIR $SRC_DIR

COPY . $SRC_DIR

USER steam

CMD [ "sudo", "-E", "bash", "/home/cs2-modded-server/install_docker.sh" ]
