#!/bin/bash

echo "1..5"

perl -e ' open my $file, ">", "local/test-server.pid"; print $file $$; close $file; exec "bin/server" ' &

sleep 2;

(curl -s -f http://localhost:5511/ > /dev/null && echo "ok 1") || echo "not ok 1"
(curl -s -f http://localhost:5511/404 > /dev/null && echo "not ok 2") || echo "ok 2"
(curl -s -f http://localhost:5511/admin/ > /dev/null && echo "ok 3") || echo "not ok 3"
(curl -s -f http://localhost:5511/www/ > /dev/null && echo "ok 4") || echo "not ok 4"
(curl -s -f http://localhost:5511/LIST > /dev/null && echo "ok 5") || echo "not ok 5"

kill `cat local/test-server.pid`
