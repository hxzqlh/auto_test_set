#!/bin/bash

[ -d pkg ] && rm -rf pkg
mkdir pkg
cp *.txt pkg
cp *.sh  pkg
rm -rf pkg/mkpkg.sh
tar cvzf auto_test.tar pkg
[ -d pkg ] && rm -rf pkg
