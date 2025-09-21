FROM aflplusplus/aflplusplus:latest

WORKDIR /

RUN apt update && \
    apt-get install -y re2c libsqlite3-dev libjpeg-dev libpng-dev
# Setup PHP source with php-afltools
RUN git clone https://github.com/php/php-src.git
RUN git clone https://github.com/mumubebe/php-afltools.git

RUN mv /php-afltools/examples /fuzz
RUN mv /php-afltools/ext/afltools /php-src/ext

# Add more extensions if needed
RUN cd /php-src && \
    ./buildconf && \ 
    CC=afl-clang-fast CXX=afl-clang-fast++ ./configure --enable-gd --enable-exif --with-jpeg --enable-afltools && \ 
    AFL_USE_ASAN=1 make -j$(nproc)

WORKDIR /fuzz

RUN echo 'alias php-afl="/php-src/sapi/cli/php"' >> ~/.bashrc
