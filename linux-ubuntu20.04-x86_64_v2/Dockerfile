FROM ubuntu:20.04 as build

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C \
    PATH=/root/tools/bin:/root/spack/bin:$PATH

RUN apt-get -yqq update && \
    apt-get -yqq install \
        build-essential \
        ca-certificates \
        clang \
        curl \
        file \
        g++ \
        gcc \
        git \
        lld \
        llvm \
        make \
        patch \
        python3 \
        unzip

RUN mkdir spack && \
    cd spack && \
    curl -Lfs https://github.com/spack/spack/archive/refs/heads/develop.tar.gz | tar -xzf - --strip-components=1 -C . && \
    curl -Lfs https://github.com/spack/spack/pull/34926.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35020.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35078.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35128.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35158.patch | patch -p1 && \
    true

ADD spack.yaml Makefile /root/

ADD linux-ubuntu20.04-x86_64_v2/compilers.yaml linux-ubuntu20.04-x86_64_v2/packages.yaml /root/spack/etc/spack

# Assume system make is too old
RUN spack env create --with-view /root/tools tools && \
    spack -e tools add gmake@4.4 && \
    spack -e tools concretize && \
    spack -e tools install

RUN --mount=type=cache,target=/buildcache \
    --mount=type=cache,target=/root/.spack/cache \
    spack mirror add cache /buildcache && \
    make -j$(nproc) BUILDCACHE=/buildcache

# Remove Spack metadata / Python cache to save some bytes
RUN find -L /opt/spack -type d \( -name '__pycache__' -or -name '.spack' \) -exec rm -rf {} +

# Stage 2, create a small(er) docker image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C \
    PATH=/opt/spack/view/bin:/root/spack/bin:$PATH

COPY --from=build /opt/spack /opt/spack

# We stick to system compilers & linkers
RUN apt-get -yqq update && \
    apt-get -yqq install --no-install-recommends libc-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Spack again and populate caches by concretizing something
# RUN mkdir /root/spack && \
#     curl -Lfs https://github.com/spack/spack/archive/refs/heads/develop.tar.gz | tar -xzf - --strip-components=1 -C /root/spack && \
#     spack compiler find && \
#     spack spec hdf5
