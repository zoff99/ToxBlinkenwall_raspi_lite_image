#! /bin/bash

rm -f /tmp/xxx.out
rm -f /tmp/xxx.out2

echo "$1" > /tmp/xxx.out
cd /tmp/
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
cat xxx.out >> xxx.out2 ; cat xxx.out2 >> xxx.out
rm -f xxx.out2

cat xxx.out > /dev/fb0
rm -f xxx.out

