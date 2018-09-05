#!/bin/sh
# Shogun's problematic installation helper
#set -x
set -e

destdir="debian/tmp/"
version="1.10.1"
soversion="1.10"

# installation helper
# usage: myinstall <srcfile> <dstfile>
# XXX: Never do so: myinstall <srcfile> <dstdir>
myinstall () {
	# myinstall -m0644 src dest
	if ! test -d $(dirname $3); then
		mkdir -v -p $(dirname $3);
	fi
	install -v $1 $2 $3
}

# install headers
for hdr in $(cat libtensorflow.hdrs); do
	myinstall -m0644 $hdr $destdir/usr/include/$hdr
done

# install libtensorflow_framework.so and libtensorflow.so
for so in "libtensorflow_framework.so" "libtensorflow.so"; do
	fpath="$destdir/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/$so"
	myinstall -m0644 $so $fpath
	mv -v $fpath $fpath.$version
	ln -vsr $fpath.$version $fpath.$soversion
	ln -vsr $fpath.$version $fpath
done
