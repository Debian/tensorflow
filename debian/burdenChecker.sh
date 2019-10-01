#!/bin/sh
set -e

BURDENS=$(fdfind '.bzl|BUILD')

for burden in $BURDENS; do
	dirname=$(dirname $burden)
	basename=$(basename $burden)
	target=debian/buildsys/$dirname/meson.build

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

	if ! test -r $target; then
		mkdir -p $(dirname $target)
		cp -v $burden $target
	fi
done
