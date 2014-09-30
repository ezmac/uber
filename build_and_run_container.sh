if [[ -z $SPINUP_BASEDIR ]]; then
  echo "Please use 'export SPINUP_BASEDIR=/path/to/storage/' to set your base storage directory"
  exit -1
fi
rm -rf $SPINUP_BASEDIR/uber_test && docker build -t uber_test . && docker run -i -t -p 137:137 -p 139:139 -p 445:445 -p 88:88 -p 135:135 -p 138:138 -p 2002:22 -p 9090:9000 -p 8899:80 -v $SPINUP_BASEDIR/uber_test/:/data/:rw -e "MYSQL_PASS=xm1014" uber_test 
