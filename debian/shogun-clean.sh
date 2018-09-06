#!/bin/sh
set -x

for NINJA in $(find . -type f -name '*.ninja'); do
	ninja -f $NINJA -t clean || true
done
