#!/bin/sh
mkdir -p lib
rm -rf lib/*
rm -f examples/test examples/image_test

fpc -Fisrc/inc -Fisrc/inc/fonts -FUlib -Fusrc src/oglgraph.pas

fpc  -Fulib examples/test.pas
fpc  -Fulib examples/image_test.pas
fpc  -Fulib examples/fill.pas
rm examples/*.o
