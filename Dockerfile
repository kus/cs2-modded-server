# Steam Runtime 4 (Debian 13 "trixie").
# Steam Runtime 3 "sniper" is Debian 11 "bullseye", whose security suite was retired in
# August 2026: its index is still published but the .deb files are gone, so every
# apt-get install on that base now fails with 404s. Upstream CS2 projects moved for the
# same reason (joedwards32/CS2 in September 2026, Source2ZE build containers ship
# steamrt3 + steamrt4). All the plugin binaries shipped in game/csgo need at most
# GLIBC_2.29, well below the 2.41 this image provides, so they load unchanged.
FROM registry.gitlab.steamos.cloud/steamrt/steamrt4/platform:latest-container-runtime-depot

USER root

ENV DEBIAN_FRONTEND=noninteractive

# No version pins: they tie the build to one Debian point release and break on the next.
# git-all was removed - nothing in the image uses git, and it pulled in emacs,
# subversion and cvs through its metapackage dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    dnsutils \
    lib32z1 \
    wget \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# groupadd, not addgroup: Debian 13 dropped the adduser package from the base image,
# and groupadd ships with passwd, which is essential.
RUN groupadd steam \
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
