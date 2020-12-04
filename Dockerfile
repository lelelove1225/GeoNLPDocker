FROM centos:latest
RUN dnf update -y
RUN dnf install glibc-locale-source glibc-langpack-ja -y
RUN localedef -f UTF-8 -i ja_JP ja_JP.UTF-8
ENV LANG="ja_JP.UTF-8" \
    LANGUAGE="ja_JP:ja" \
    LC_ALL="ja_JP.UTF-8"
RUN dnf install boost boost-devel sqlite-devel \
    gcc-c++ automake autoconf -y
RUN dnf install bzip2 bzip2-devel gcc gcc-c++ \ 
    git make wget curl openssl-devel readline-devel \
    zlib-devel patch file -y
RUN mkdir -p ~/source/mecab
WORKDIR /source/mecab
RUN wget 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE' -O mecab-0.996.tar.gz
RUN tar zxvf mecab-0.996.tar.gz
WORKDIR /source/mecab/mecab-0.996
RUN mkdir -p /opt/mecab
RUN ./configure --prefix=/opt/mecab --with-charset=utf8 --enable-utf8-only
RUN make
RUN make install
RUN echo "export PATH=/opt/mecab/bin:\$PATH" >> ~/.bashrc
RUN source ~/.bashrc