FROM lambci/lambda:build-provided

RUN yum install -q -y wget \
    readline-devel \
    xorg-x11-server-devel libX11-devel libXt-devel \
    curl-devel \
    gcc-c++ gcc-gfortran \
    zlib-devel bzip2 bzip2-libs \
    java-1.8.0-openjdk-devel

# https://unix.stackexchange.com/questions/635758/local-installation-of-pcre2-not-detected-while-installing-r-4-0-4-from-source
# https://unix.stackexchange.com/questions/343452/how-to-install-r-3-3-1-in-my-own-directory

ARG VERSION=4.1.2
ARG R_DIR=/opt/R/

RUN wget -q https://cran.r-project.org/src/base/R-4/R-${VERSION}.tar.gz && \
    mkdir ${R_DIR} && \
    tar -xf R-${VERSION}.tar.gz && \
    mv R-${VERSION}/* ${R_DIR} && \
    rm R-${VERSION}.tar.gz

RUN cd /opt/R/ && \
	wget https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.39/pcre2-10.39.tar.gz && \
	tar -zxvf pcre2-10.39.tar.gz && \
	cd pcre2-10.39 && \
	./configure && \
	make -j 24 && \
	make install && \
	cd ..

WORKDIR ${R_DIR}
RUN ./configure --prefix=${R_DIR} --exec-prefix=${R_DIR} --with-libpth-prefix=/opt/ --enable-R-shlib && \
    make && \
    cp /usr/lib64/libgfortran.so.3 lib/ && \
    cp /usr/lib64/libgomp.so.1 lib/ && \
    cp /usr/lib64/libquadmath.so.0 lib/ && \
    cp /usr/lib64/libstdc++.so.6 lib/
RUN yum install -q -y openssl-devel libxml2-devel && \
    ./bin/Rscript -e 'install.packages(c("httr", "aws.s3", "logging"), repos="http://cran.r-project.org")'
CMD mkdir -p /var/r/ && \
    cp -r bin/ lib/ etc/ library/ doc/ modules/ share/ /var/r/
