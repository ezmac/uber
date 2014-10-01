#!/bin/bash

docker run -i -t -p 137:137 -p 139:139 -p 445:445 -p 88:88 -p 135:135 -p 138:138 -p 2002:22 -p 9090:9000 -p 8899:80 -v $SPINUP_BASEDIR/$user/:/data/:rw -e "MYSQL_PASS=xm1014" uber
