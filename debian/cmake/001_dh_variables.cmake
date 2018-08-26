# Copyright (C) 2018 Mo Zhou. MIT/Expat License.

# -- [ Export debhelper variables to cmake ]
execute_process(COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
	OUTPUT_VARIABLE DEB_HOST_MULTIARCH
	OUTPUT_STRIP_TRAILING_WHITESPACE)
