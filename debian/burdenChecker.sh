#!/bin/sh
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
set -e

BURDENS=$(find . -type f \( -name '*.bzl' \) -o \( -name 'BUILD' \))
NINJA_SYNTAX=debian/ninja_syntax.py

scan(){
for burden in $BURDENS; do
	dirname=$(dirname $burden)
	basename=$(basename $burden)
	target=debian/buildsys/$dirname/ninja.py

	# any "contrib" stuff is not officially supported by TensorFlow
	if $(echo $burden | grep 'contrib/' >/dev/null 2>/dev/null); then continue; fi

	# we don't build these
	if $(echo $burden | grep 'lite/' >/dev/null 2>/dev/null); then continue; fi
	if $(echo $burden | grep 'java/' >/dev/null 2>/dev/null); then continue; fi
	if $(echo $burden | grep 'tpu/' >/dev/null 2>/dev/null); then continue; fi

	# we omit the distro-unfriendly stuff
	if $(echo $burden | grep 'third_party/' >/dev/null 2>/dev/null); then continue; fi

	# if it's a .bzl rules file
	if $(echo $burden | grep '.bzl$' >/dev/null 2>/dev/null); then
		mkdir -p $(dirname $target)
		cp $burden $(dirname $target)
	fi

	# use the bazel BUILD file as a template
	if ! test -r $target; then
		mkdir -p $(dirname $target)
		cp -v $burden $target
	fi
done
}

copy(){
for helper in $(find debian/buildsys/ -type f -name 'ninja.py'); do
	target=${helper#debian/buildsys/}
	cat > $target <<EOF
#!/usr/bin/python3
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
import os, sys, re
from ninja_syntax import Writer
d = "$(dirname $target)"
f = Writer(open(f'{d}/build.ninja', 'wt'))

def protoGroup(name: str, paths: list):
    f.variable(name+'_obj', [x.replace('.proto', '.pb.o') for x in paths])
    f.build(name+'_obj', 'phony', [x.replace('.proto', '.pb.o') for x in paths])
    f.variable(name+'_cc', [x.replace('.proto', '.pb.cc') for x in paths])
    f.build(name+'_cc', 'phony', [x.replace('.proto', '.pb.cc') for x in paths])
    f.variable(name+'_h', [x.replace('.proto', '.pb.h') for x in paths])
    f.build(name+'_h', 'phony', [x.replace('.proto', '.pb.h') for x in paths])
    for x in paths:
        f.build([x.replace('.proto', '.pb.h'), x.replace('.proto', '.pb.cc')], 'PROTOC', x)
        f.build(x.replace('.proto', '.pb.o'), 'CXX', x.replace('.proto', '.pb.cc'), implicit=name+'_cc')

if '.' == d:
	f.rule('PROTOC', 'protoc -I. --cpp_out=. \$in')
	f.rule('CXX', 'ccache g++ -I. -O2 -fPIC -c -o \$out \$in')
EOF
	cat $helper >> $target
	cat >> $target <<EOF
f.close()
EOF
	mkdir -p $(dirname $target)
	cp $NINJA_SYNTAX $(dirname $target)/$(basename $NINJA_SYNTAX)

	echo "Generating ${target%ninja.py}build.ninja ..."
	python3 $target
done
}

embedded(){
	tar xf debian/embedded/43ef2148c0936ebf7cb4be6b19927a9d9d145b8f.tar.gz --strip-components=1 -C.
}

build(){
	NINJA_STATUS="[1;36m[%es (%p) %f/%t][0;m " ninja -v
}

case $1 in
	scan)
		scan;;
	copy)
		copy;;
	b)
		embedded
		copy
		build
		;;

	*)
		embedded
		copy;;
esac
