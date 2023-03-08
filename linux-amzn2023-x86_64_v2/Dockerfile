FROM amazonlinux:2023 as build

WORKDIR /root

ENV LC_ALL=C \
    PATH=/root/tools/bin:/root/spack/bin:/usr/bin:/bin

RUN yum install -y \
        bzip2 \
        clang \
        git \
        lld \
        make \
        patch \
        python \
        tar \
        unzip \
        xz

RUN mkdir spack && \
    cd spack && \
    curl -Lfs https://github.com/spack/spack/archive/refs/heads/develop.tar.gz | tar -xzf - --strip-components=1 -C . && \
    curl -Lfs https://github.com/spack/spack/pull/34926.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35020.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35078.patch | patch -p1 && \
    curl -Lfs https://github.com/spack/spack/pull/35174.patch | patch -p1 && \
    true

ADD spack.yaml Makefile /root/

ADD linux-amzn2023-x86_64_v2/compilers.yaml linux-amzn2023-x86_64_v2/packages.yaml /root/spack/etc/spack

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
RUN find -L /opt/spack -type d \( -name '__pycache__' -or -name '.spack' \) -exec rm -rf {} + && \
    find -L /opt/spack -type f -name '*.a' -exec rm -rf {} +

# Stage 2, create a small(er) docker image
FROM amazonlinux:2023

ENV LC_ALL=C \
    PATH=/opt/spack/view/bin:/root/spack/bin:$PATH

COPY --from=build /opt/spack /opt/spack

# We stick to system compilers & linkers
RUN yum install -y gcc g++ gfortran binutils && \
    yum clean all && \
    rm -rf /var/cache/yum/*

# Install Spack again and populate caches by concretizing something
# RUN mkdir /root/spack && \
#     curl -Lfs https://github.com/spack/spack/archive/refs/heads/develop.tar.gz | tar -xzf - --strip-components=1 -C /root/spack && \
#     spack compiler find && \
#     spack spec hdf5
