FROM centos:latest
RUN dnf update -y
RUN dnf install glibc-locale-source glibc-langpack-ja -y
RUN dnf install boost boost-devel sqlite-devel \
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
RUN mkdir -p ~/source/dams
WORKDIR /source/dams
RUN wget http://newspat.csis.u-tokyo.ac.jp/download/dams-4.3.3.tgz
RUN gzip -dc dams-4.3.3.tgz | tar xf -
RUN mkdir -p /opt/dams
WORKDIR /source/dams/dams-4.3.3
RUN ./configure
RUN make
RUN make dic
RUN make test
RUN mkdir -p /tmp
WORKDIR /tmp
RUN wget https://www.sqlite.org/2019/sqlite-autoconf-3270100.tar.gz
RUN tar xvfz sqlite-autoconf-3270100.tar.gz
WORKDIR /tmp/sqlite-autoconf-3270100
RUN mkdir -p /opt/sqlite3
#WORKDIR /opt/sqlite3
RUN ./configure --prefix=/opt/sqlite3
RUN mv /usr/bin/sqlite3 /usr/bin/sqlite3_old
RUN ln -s /opt/sqlite3/bin/sqlite3 /usr/bin/sqlite3
RUN rpm -Uvh https://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN dnf install gdal-libs -y