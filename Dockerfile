FROM registry.gitlab.steamos.cloud/steamrt/sniper/platform:latest-container-runtime-depot

USER root

RUN apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends \
    dnsutils \
    git-all \
    lib32z1=1:1.2.11.dfsg-2+deb11u2 \
    wget=1.21-1+deb11u1 \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales

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

COPY custom_files $SRC_DIR/custom_files

COPY install_docker.sh \
    run.sh \
    start.sh \
    stop.sh \
    $SRC_DIR

COPY game/csgo $SRC_DIR/game/csgo

USER steam

CMD [ "sudo", "-E", "bash", "/home/cs2-modded-server/install_docker.sh" ]
