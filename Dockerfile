FROM centos:latest
RUN dnf update -y
RUN dnf install glibc-locale-source glibc-langpack-ja -y
RUN dnf install boost boost-devel sqlite sqlite-devel \
    gcc-c++ automake autoconf -y
RUN dnf install bzip2 bzip2-devel gcc gcc-c++ \ 
    git make wget curl openssl-devel readline-devel \
    zlib-devel patch file which diffutils -y
RUN dnf group install "Development Tools" -y
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8" \
    TZ='Asia/Tokyo'
RUN mkdir -p ~/source/mecab
WORKDIR /source/mecab
RUN wget 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' -O mecab-0.996.tar.gz
RUN tar zxvf mecab-0.996.tar.gz
WORKDIR /source/mecab/mecab-0.996
RUN mkdir -p /opt/mecab
RUN ./configure --prefix=/opt/mecab --with-charset=utf8 --enable-utf8-only
RUN make
RUN make install
RUN mkdir -p ~/source/mecab-ipadic
WORKDIR /source/mecab-ipadic
RUN wget 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' -O mecab-ipadic-2.7.0-20070801.tar.gz
RUN tar zxvf mecab-ipadic-2.7.0-20070801.tar.gz
WORKDIR /source/mecab-ipadic/mecab-ipadic-2.7.0-20070801
RUN ./configure --with-mecab-config=/opt/mecab/bin/mecab-config --with-charset=utf8
RUN make
RUN make install
WORKDIR /source
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
ENV PATH /opt/mecab/bin:$PATH
RUN ./mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y -p /opt/mecab/lib/mecab/dic/neologd
WORKDIR /opt
RUN wget https://www.sqlite.org/2019/sqlite-autoconf-3270100.tar.gz
RUN tar xvfz sqlite-autoconf-3270100.tar.gz
WORKDIR /opt/sqlite-autoconf-3270100
RUN mkdir -p /opt/sqlite
RUN ./configure --prefix=/opt/sqlite
RUN make
RUN make install
RUN ln -fs /opt/sqlite3/bin/sqlite3 sqlite3
RUN mkdir -p ~/source/dams
WORKDIR /source/dams
RUN wget http://newspat.csis.u-tokyo.ac.jp/download/dams-4.3.3.tgz
RUN gzip -dc dams-4.3.3.tgz | tar xf -
RUN mkdir -p /opt/dams
WORKDIR /source/dams/dams-4.3.3
RUN dnf install https://forensics.cert.org/cert-forensics-tools-release-el7.rpm -y
RUN dnf install libiconv-devel libiconv-utils libiconv -y
RUN ./configure
# RUN ./configure --prefix=/opt/dams --with-charset=UTF8
# RUN ./configure --with-charset=UTF8 CPPFLAGS=-I/usr/local/include
# RUN ./configure --with-charset=UTF8 LIBS=-liconv CPPFLAGS=-I/usr/local/include
RUN make
RUN make dic
RUN make test
#RUN make install
#RUN make install-dic
# RUN mkdir -p /tmp
RUN rpm -Uvh https://download.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
RUN dnf install xerces-c jasper-libs libwebp giflib -y
RUN dnf config-manager --set-enabled PowerTools -y
RUN dnf install libdap -y
RUN dnf clean packages
RUN dnf install gdal-libs gdal-devel -y
RUN mkdir -p ~/source/geonlp
WORKDIR /source/geonlp
RUN wget https://geonlp.ex.nii.ac.jp/software/geonlp-1.2.0.tgz
RUN gzip -dc geonlp-1.2.0.tgz | tar xfv -
WORKDIR /geonlp-1.2.0
RUN mkdir -p /opt/geonlp
WORKDIR  /source/geonlp/geonlp-1.2.0
RUN ./configure --prefix=/opt/geonlp LDFLAGS="-L/opt/mecab/lib -L/opt/sqlite3/lib" CXXFLAGS="-I/opt/mecab/include -I/opt/sqlite3/include"
RUN ./configure --prefix=/opt/geonlp LDFLAGS="-L/opt/mecab/lib -L/opt/sqlite3/lib -L/usr/lib64" INCLUDE="-I/opt/mecab/include -I/opt/sqlite3/include -I/usr/include" CXXFLAGS="-I/opt/mecab/include -I/opt/sqlite3/include -I/usr/include"
COPY ./SelectCondition.cpp /source/geonlp/geonlp-1.2.0/libgeonlp/
RUN make
RUN make install
RUN makedir -p /opt/geonlp/lib/geonlp
WORKDIR /opt/geonlp/lib/geonlp
COPY geodic.sq3 .
COPY wordlist.sq3 .
RUN chmod 777 ./geodic.sq3
RUN chmod 777 ./wordlist.sq3
ENV PATH /opt/geonlp/bin:$PATH