FROM wakaba/docker-perl-app-base

ADD Makefile /app/
ADD mapping.txt /app/
ADD html-footer /app/
ADD bin /app/bin
#ADD config /app/config
ADD t /app/t

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
    rm -fr /app/t /app/t_deps /app/local/furuike/t /app/local/furuike/t_deps

CMD ["/server"]