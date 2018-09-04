#!/bin/sh
set -x

for NINJA in $(ls *.ninja) ""; do
	ninja -f $NINJA -t clean || true
done
