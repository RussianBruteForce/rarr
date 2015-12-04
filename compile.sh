#!/bin/sh
rm -rf obj/Release bin/Release
dmd  -inline -O    -I/usr/lib/phobos -c rarr/matrix.d -ofobj/Release/rarr/matrix.o
dmd  -inline -O    -I/usr/lib/phobos -c rarr/package.d -ofobj/Release/rarr/package.o
dmd  -inline -O    -I/usr/lib/phobos -c rarr/solve.d -ofobj/Release/rarr/solve.o
dmd  -inline -O    -I/usr/lib/phobos -c rarr/vector.d -ofobj/Release/rarr/vector.o
dmd  -inline -O    -I/usr/lib/phobos -c test_example.d -ofobj/Release/test_example.o
dmd -ofbin/Release/rarr  obj/Release/rarr/matrix.o obj/Release/rarr/package.o obj/Release/rarr/solve.o obj/Release/rarr/vector.o obj/Release/test_example.o -L-lpthread -L-lm -L-lphobos2
