#!/bin/sh
set -xe

VERSION="1.10.1"
DEB_HOST_MULTIARCH=$(dpkg-architecture -qDEB_HOST_MULTIARCH)

for lib in tensorflow_framework tensorflow tensorflow_cc; do
	cat tf.pc.in \
		| sed -e "s/#DEB_HOST_MULTIARCH#/$DEB_HOST_MULTIARCH/g" \
		| sed -e "s/#VERSION#/$VERSION/g" \
		| sed -e "s/#LIBS#/-l$lib/g" \
		> $lib.pc
done
