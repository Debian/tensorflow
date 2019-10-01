#!/bin/sh
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
set -e

BURDENS=$(fdfind '.bzl|BUILD')
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

	# unconditionally copy the ninja syntax
	cp $NINJA_SYNTAX $(dirname $target)/$(basename $NINJA_SYNTAX)

	# if it's a .bzl rules file
	if $(echo $burden | grep '.bzl$' >/dev/null 2>/dev/null); then
		mkdir -p $(dirname $target)
		cp $burden $(dirname $target)
	fi

	# use the bazel BUILD file as a template
	if ! test -r $target; then
		mkdir -p $(dirname $target)
		touch $target
		echo "#!/usr/bin/python3" >> $target
		echo "# Copyright (C) 2019 Mo Zhou <lumin@debian.org>" >> $target
		echo "import os, sys, re" >> $target
		echo "from ninja_syntax import Writer" >> $target
		echo "f = Writer(open('ninja.build', 'wt'))" >> $target
		echo "" >> $target
		echo "" >> $target
		cat $burden >> $target
		echo "" >> $target
		echo "" >> $target
		echo "f.close()" >> $target
		echo Unresolved burden: $burden
	fi
done

cp -av debian/buildsys/* .
