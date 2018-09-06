#!/bin/sh
# Shogun's problematic installation helper
#set -x
set -e

destdir="debian/tmp/"
version="1.10.1"
soversion="1.10"

# install headers
for hdr in $(cat libtensorflow.hdrs) $(cat libtensorflow_cc.hdrs); do
	install -Dm0644 $hdr $destdir/usr/include/$hdr
done

# install libtensorflow_framework.so and libtensorflow.so
for so in "libtensorflow_framework.so" "libtensorflow.so" "libtensorflow_cc.so"; do
	fpath="$destdir/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/$so"
	install -Dm0644 $so $fpath
	mv -v $fpath $fpath.$version
	ln -vsr $fpath.$version $fpath.$soversion
	ln -vsr $fpath.$version $fpath
done
