#
# Dockerfile for afl-tools. Big part of this Dockerfile is from afl++
#

FROM ubuntu:24.04

### Only change these if you know what you are doing:
# Current recommended LLVM version is 16
ENV LLVM_VERSION=19
# GCC 12 is producing compile errors for some targets so we stay at GCC 11
ENV GCC_VERSION=11

ARG DEBIAN_FRONTEND=noninteractive

ENV NO_ARCH_OPT=1
ENV IS_DOCKER=1

RUN apt-get update && apt-get full-upgrade -y && \
    apt-get install -y --no-install-recommends wget ca-certificates apt-utils && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    make cmake automake meson ninja-build bison flex \
    re2c libsqlite3-dev libjpeg-dev libpng-dev \
    git xz-utils bzip2 wget tmux jupp nano bash-completion less vim joe ssh psmisc \
    python3 python3-dev python3-pip python-is-python3 \
    libtool libtool-bin libglib2.0-dev \
    apt-transport-https gnupg dialog \
    gnuplot-nox libpixman-1-dev bc \
    gcc-${GCC_VERSION} g++-${GCC_VERSION} gcc-${GCC_VERSION}-plugin-dev gdb lcov \
    clang-${LLVM_VERSION} clang-tools-${LLVM_VERSION} libc++1-${LLVM_VERSION} \
    libc++-${LLVM_VERSION}-dev libc++abi1-${LLVM_VERSION} libc++abi-${LLVM_VERSION}-dev \
    libclang1-${LLVM_VERSION} libclang-${LLVM_VERSION}-dev \
    libclang-common-${LLVM_VERSION}-dev libclang-rt-${LLVM_VERSION}-dev libclang-cpp${LLVM_VERSION} \
    libclang-cpp${LLVM_VERSION}-dev liblld-${LLVM_VERSION} \
    liblld-${LLVM_VERSION}-dev liblldb-${LLVM_VERSION} liblldb-${LLVM_VERSION}-dev \
    libllvm${LLVM_VERSION} libomp-${LLVM_VERSION}-dev libomp5-${LLVM_VERSION} \
    lld-${LLVM_VERSION} lldb-${LLVM_VERSION} llvm-${LLVM_VERSION} \
    llvm-${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-runtime llvm-${LLVM_VERSION}-tools \
    $([ "$(dpkg --print-architecture)" = "amd64" ] && echo gcc-${GCC_VERSION}-multilib gcc-multilib) \
    $([ "$(dpkg --print-architecture)" = "arm64" ] && echo libcapstone-dev) && \
    rm -rf /var/lib/apt/lists/*
    # gcc-multilib is only used for -m32 support on x86
    # libcapstone-dev is used for coresight_mode on arm64

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} 0 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION} 0 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-${GCC_VERSION} 0 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 0 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} 0

#RUN wget -qO- https://sh.rustup.rs | CARGO_HOME=/etc/cargo sh -s -- -y -q --no-modify-path
#ENV PATH=$PATH:/etc/cargo/bin

RUN apt clean -y

ENV LLVM_CONFIG=llvm-config-${LLVM_VERSION}
ENV AFL_SKIP_CPUFREQ=1
ENV AFL_TRY_AFFINITY=1
ENV AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1

RUN git clone https://github.com/AFLplusplus/AFLplusplus.git


ARG CC=gcc-$GCC_VERSION
ARG CXX=g++-$GCC_VERSION

# Used in CI to prevent a 'make clean' which would remove the binaries to be tested
ARG TEST_BUILD

RUN cd /AFLplusplus && sed -i.bak 's/^	-/	/g' GNUmakefile && \
    make clean && make distrib && \
    ([ "${TEST_BUILD}" ] || (make install)) && \
    mv GNUmakefile.bak GNUmakefile

# Setup PHP source with php-afltools
RUN git clone https://github.com/php/php-src.git
RUN git clone https://github.com/mumubebe/php-afltools.git

RUN mkdir /fuzz
RUN mv php-afltools/examples /fuzz

RUN mv php-afltools/ext/ /php-src/ext

# Add more extensions if needed
RUN cd /php-src && \
    ./buildconf && \ 
    CC=afl-clang-fast CXX=afl-clang-fast++ ./configure --enable-gd --enable-exif --with-jpeg --enable-afltools && \ 
    AFL_USE_ASAN=1 make -j$(nproc)

WORKDIR /fuzz

RUN echo "set encoding=utf-8" > /root/.vimrc && \
    echo ". /etc/bash_completion" >> ~/.bashrc && \
    echo 'alias joe="joe --wordwrap --joe_state -nobackup"' >> ~/.bashrc && \
    echo 'alias php-afl="/php-src/sapi/cli/php"' >> ~/.bashrc
