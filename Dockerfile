FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 as builder
# Need devel instead of runtime, for access to nvcc

ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    # pip
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100

###################################
# FFmpeg from sources with GPU encoding/decoding
# Check latest NV_CODEC_TAG at https://github.com/FFmpeg/nv-codec-headers/tags
###################################
ARG FFMPEG_VERS="6.0"
ARG NV_CODEC_TAG="n12.0.16.0"
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
    libc6 \
    libc6-dev \
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
    unzip \
    yasm \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

# Install NVIDIA codec headers before FFmpeg
RUN curl -kL https://github.com/FFmpeg/nv-codec-headers/archive/refs/tags/${NV_CODEC_TAG}.tar.gz -o nv-codec-headers.tar.gz && \
    ls -lah && \
    tar zxvf nv-codec-headers.tar.gz && \
    rm nv-codec-headers.tar.gz
WORKDIR /build/nv-codec-headers-${NV_CODEC_TAG}
RUN make install
# Download, configure, install FFmpeg
WORKDIR /build
RUN curl -kL https://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERS}.tar.bz2 -o ffmpeg.tar.bz2 && \
    tar xjvf ffmpeg.tar.bz2
WORKDIR /build/ffmpeg-${FFMPEG_VERS}
RUN ./configure \
    --extra-cflags="-mcpu=native" \
    --extra-libs="-lpthread -lm" \
    --bindir="/build/bin" \
    --enable-gpl \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --extra-cflags="-I/usr/local/cuda/include" \
    --extra-ldflags="-L/usr/local/cuda/lib64" \
    --enable-cuda-nvcc \
    --enable-libnpp \
    --disable-static \
    --enable-shared && \
    make -j 8 && \
    make install && \
    hash -r && \
    ldconfig /usr/local/lib && \
    cp /build/bin/ffmpeg /build/bin/ffprobe /usr/local/bin/ && \
    rm -r /build


###################################
# Python from sources
###################################
ARG PYTHON_VERS=3.11.4
WORKDIR /build
RUN curl https://www.python.org/ftp/python/${PYTHON_VERS}/Python-${PYTHON_VERS}.tgz --output Python-${PYTHON_VERS}.tgz && \
    tar -xf Python-${PYTHON_VERS}.tgz 
WORKDIR /build/Python-${PYTHON_VERS} 
RUN ./configure --enable-optimizations && \
    make -j 8 && \
    make install && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir --upgrade setuptools && \
    ln -s /usr/local/bin/python3 /usr/local/bin/python && \
    rm -rf /build

# FROM base AS release
# ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
# COPY --from=base /usr/local /usr/local/