FROM ubuntu:20.04 as build

WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C \
    PATH=/root/spack/bin:/usr/bin:/bin

RUN apt-get -yqq update && \
    apt-get -yqq install \
        build-essential \
        ca-certificates \
        clang \
        llvm \
        curl \
        file \
        g++ \
        gcc \
        gfortran \
        git \
        gnupg2 \
        iproute2 \
        locales \
        make \
        patch \
        python3 \
        unzip

RUN mkdir spack && \
    cd spack && \
    curl -Lfs https://github.com/spack/spack/archive/refs/heads/develop.tar.gz | tar -xzf - --strip-components=1 -C . && \
    curl -Lfs https://github.com/spack/spack/pull/34926.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35009.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35014.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35019.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35020.patch | patch -p1 && \
    true

# System make is not great :(
RUN curl -Lfs 'https://github.com/JuliaBinaryWrappers/GNUMake_jll.jl/releases/download/GNUMake-v4.4.0+0/GNUMake.v4.4.0.x86_64-linux-gnu.tar.gz' | tar -xzf - -C /usr

ADD spack.yaml Makefile /root/

RUN --mount=type=cache,target=/buildcache \
    --mount=type=cache,target=/root/.spack/cache \
    spack compiler find && \
    spack mirror add cache file:///buildcache && \
    make -j$(nproc) BUILDCACHE=/buildcache

# Stage 2, create a small(er) docker image
FROM ubuntu:20.04

COPY --from=build /opt/spack /opt/spack
ENV PATH=/opt/spack/view/bin:/root/spack:$PATH

# We stick to system compilers & linkers
RUN apt-get -yqq update && \
    apt-get -yqq install --no-install-recommends gcc gfortran g++ libc-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /root/spack && \
    curl -Lfs https://github.com/spack/spack/archive/refs/heads/develop.tar.gz | tar -xzf - --strip-components=1 -C /root/spack
