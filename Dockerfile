FROM wakaba/docker-perl-app-base

ADD Makefile /app/
ADD mapping.txt /app/
ADD bin /app/bin
#ADD config /app/config
ADD t /app/t

RUN cd /app && make deps PMBP_OPTIONS=--execute-system-package-installer && \
    make test && \
    echo '#!/bin/bash' > /server && \
    echo 'exec /app/bin/server' >> /server && \
    chmod u+x /server && \
    rm -fr /app/deps /app.orig /app/local/furuike/deps && \
    rm -fr /app/t /app/t_deps /app/local/furuike/t /app/local/furuike/t_deps
