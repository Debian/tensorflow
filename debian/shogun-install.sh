#!/bin/sh
# Shogun's installation helper
# Copyright (C) 2018 Mo Zhou <lumin@debian.org>, MIT/Expat license.
#set -x
set -e

dryrun=0
destdir="debian/tmp/"
version="1.10.1"
soversion="1.10"

# installation helper
myinstall () {
	# myinstall -m0644 src dest
	if ! test -d $(dirname $3); then
		if test $dryrun -eq 1; then
			echo mkdir -p $(dirname $3);
		else
			mkdir -v -p $3;
	   	fi
	fi
	if test $dryrun -eq 1; then
	   	echo install $1 $2 $3
	else
	   	install -v $1 $2 $3
	fi
}

# install headers
for hdr in $(cat libtensorflow.hdrs); do
	myinstall -m0644 $hdr $destdir/usr/include/$(dirname $hdr)
done

# install libtensorflow_framework.so and libtensorflow.so
for so in"libtensorflow_framework.so" "libtensorflow.so"; do
	fpath="$destdir/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/$so"
	myinstall -m0644 $so $(dirname $fpath)
	mv -v $fpath $fpath.$version
	ln -vsr $fpath.$version $fpath.$soversion
	ln -vsr $fpath.$version $fpath
done
