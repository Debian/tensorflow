#!/bin/sh
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
set -e

BURDENS=$(find . -type f \( -name '*.bzl' \) -o \( -name 'BUILD' \))
NINJA_SYNTAX=debian/ninja_syntax.py

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

for helper in $(find debian/buildsys/ -type f -name 'ninja.py'); do
	target=${helper#debian/buildsys/}
	cat > $target <<EOF
#!/usr/bin/python3
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
import os, sys, re
from ninja_syntax import Writer
d = "$(dirname $target)"
f = Writer(open(f'{d}/build.ninja', 'wt'))
f.rule('PROTOC', 'protoc -I. -I.. -I../.. --cpp_out=. \$in')
f.rule('CXX', 'g++ -I. -O2 -fPIC -c -o \$out \$in')
EOF
	cat $helper >> $target
	cat >> $target <<EOF
f.close()
EOF
	echo "Generating $target ..."

	# unconditionally copy the ninja syntax
	mkdir -p $(dirname $target)
	cp $NINJA_SYNTAX $(dirname $target)/$(basename $NINJA_SYNTAX)
done
