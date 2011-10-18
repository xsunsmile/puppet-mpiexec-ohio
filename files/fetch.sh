#!/bin/bash

[ ! -z "$1" ] && version="$1" || version="0.84"
repo_url="http://www.osc.edu/~djohnson/mpiexec"
wget -t 1 --connect-timeout=10 $repo_url/mpiexec-$version.tgz
if [ -e mpiexec-$version.tgz ]; then
  [ -e mpiexec ] && rm -rf mpiexec
  tar zxf mpiexec-$version.tgz 2>&1 >/dev/null
  rm -rf mpiexec-$version.tgz
  mv mpiexec-$version mpiexec
fi
[ ! -e mpiexec ] && git clone https://github.com/xsunsmile/mpiexec-clone.git mpiexec
exit 0
