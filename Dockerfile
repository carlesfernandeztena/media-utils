FROM ubuntu:22.04 as base

ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    # pip
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    # avoid interactive requests
    DEBIAN_FRONTEND=noninteractive

###################################
# FFmpeg from sources
###################################
ARG FFMPEG_VERS=6.0
WORKDIR /build
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    cmake \
    curl \
    git \
    libass-dev \
    libfdk-aac-dev \
    libfreetype6-dev \
    libgnutls28-dev \
    libmp3lame-dev \
    libnuma-dev \
    libopus-dev \
    libtool \
    libvorbis-dev \
    libvpx-dev \
    libx264-dev \
    libx265-dev \
    meson \
    nasm \
    ninja-build \
    pkg-config \
    texinfo \
    yasm \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

RUN curl -k https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERS}.tar.bz2 -o ffmpeg-snapshot.tar.bz2 && \
    tar xjvf ffmpeg-snapshot.tar.bz2
WORKDIR /build/ffmpeg-${FFMPEG_VERS}
RUN ./configure \
    --extra-cflags="-mcpu=native" \
    --extra-libs="-lpthread -lm" \
    --bindir="/build/bin" \
    --enable-gpl \
    --enable-shared \
    --disable-static \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree && \
    make -j 8 && \
    make install && \
    hash -r && \
    ldconfig /usr/local/lib && \
    cp /build/bin/ffmpeg /build/bin/ffprobe /usr/local/bin/ && \
    rm -r /build


###################################
# Python from sources
###################################
ARG PYTHON_VERS=3.11.5
RUN apt-get update && apt-get install -y --no-install-recommends \
    # certificates (curl)
    ca-certificates gnupg curl \
    # python
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libsqlite3-dev \
    libreadline-dev \
    libffi-dev && \
    # clean up
    rm -rf /var/lib/apt/lists/*
WORKDIR /build
RUN curl https://www.python.org/ftp/python/${PYTHON_VERS}/Python-${PYTHON_VERS}.tgz --output Python-${PYTHON_VERS}.tgz && \
    tar -xf Python-${PYTHON_VERS}.tgz 
WORKDIR /build/Python-${PYTHON_VERS} 
RUN ./configure --enable-optimizations --enable-loadable-sqlite-extensions && \
    make -j 8 && \
    make install && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir --upgrade setuptools && \
    ln -s /usr/local/bin/python3 /usr/local/bin/python && \
    rm -rf /build


###################################

FROM ubuntu:22.04 AS release

ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
ENV PATH="$PATH:/scripts"

WORKDIR /mnt
COPY --from=base /usr/local /usr/local/
COPY --from=base /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/

COPY requirements.txt .
RUN pip3 install -r requirements.txt && rm requirements.txt

COPY scripts/* /scripts/
COPY models/* /models/

