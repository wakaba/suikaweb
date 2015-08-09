#!/bin/bash
export SUIKAWEB_HTTP_PORT=5511

echo "1..5"

perl -e ' open my $file, ">", "local/test-server.pid"; print $file $$; close $file; exec "bin/server" ' &

sleep 2;

(curl -s -f http://localhost:$SUIKAWEB_HTTP_PORT/ > /dev/null && echo "ok 1") || echo "not ok 1"
(curl -s -f http://localhost:$SUIKAWEB_HTTP_PORT/404 > /dev/null && echo "not ok 2") || echo "ok 2"
(curl -s -f http://localhost:$SUIKAWEB_HTTP_PORT/admin/ > /dev/null && echo "ok 3") || echo "not ok 3"
(curl -s -f http://localhost:$SUIKAWEB_HTTP_PORT/www/ > /dev/null && echo "ok 4") || echo "not ok 4"
(curl -s -f http://localhost:$SUIKAWEB_HTTP_PORT/LIST > /dev/null && echo "ok 5") || echo "not ok 5"

kill `cat local/test-server.pid`
