#!/bin/sh
set -e
tar xvf b312c3cb53a0aad75a85ac2bf57c4a614fbd48d4.tar.gz --strip-components=1 -C.
cmake -Bbuild -GNinja
cd build
ninja -v
