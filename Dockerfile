#FROM quay.io/wakaba/docker-perl-app-base

#XXX
FROM debian:stretch
RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install sudo git wget curl make gcc build-essential libssl-dev && \
    rm -rf /var/lib/apt/lists/*
RUN wget https://cpan.metacpan.org/`curl -f -L https://raw.githubusercontent.com/wakaba/perl-setupenv/master/version/perl-cpan-path.txt` && \
    tar zvxf perl-*.tar.gz && \
    cd perl-* && \
    sh Configure -de -A ccflags=-fPIC -Duserelocatableinc -Dusethreads -Dman1dir=none -Dman3dir=none && \
    make -j 4 all install && \
    cd .. && \
    rm -fr perl-*

ADD Makefile /app/
ADD mapping.txt /app/
ADD gitrepos.txt /app/
ADD gitrepos.pl /app/
ADD html-footer /app/
ADD git-index.html /app/
ADD bin /app/bin
#ADD config /app/config
ADD t /app/t
ADD hero.htaccess /app/hero.htaccess
ADD hero.wiki.htaccess /app/hero.wiki.htaccess
ADD hero.diary.htaccess /app/hero.diary.htaccess

RUN cd /app && \
    git init && \
    make deps PMBP_OPTIONS=--execute-system-package-installer && \
    make test && \
    echo '#!/bin/bash' > /server && \
    echo 'exec /app/bin/server' >> /server && \
    chmod u+x /server && \
    rm -fr /app/.git /app/local/furuike/.git && \
    rm -fr /app/local/furuike/modules/*/.git && \
    rm -fr /app/deps /app.orig /app/local/furuike/deps && \
    rm -fr /app/t /app/t_deps && \
    rm -fr /app/local/furuike/t /app/local/furuike/t_deps && \
    rm -fr /app/local/suikaweb-pubdata

CMD ["/server"]