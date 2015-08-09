FROM wakaba/docker-perl-app-base

RUN mv /app /app.orig && \
    git clone https://github.com/wakaba/suikaweb.git /app && \
    mv /app.orig/* /app/ && \
    cd /app && make deps PMBP_OPTIONS=--execute-system-package-installer && \
    make test && \
    echo '#!/bin/bash' > /server && \
    echo 'exec /app/bin/server' >> /server && \
    chmod u+x /server && \
    rm -fr /app/deps /app.orig /app/local/furuike/deps && \
    rm -fr /app/t /app/t_deps /app/local/furuike/t /app/local/furuike/t_deps
