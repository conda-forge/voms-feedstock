#!/usr/bin/env bash
set -eu

if [[ "${build_platform}" != "${target_platform}" ]]; then
    echo "Cross-compiled builds fail with weird SSL errors"
    echo "Unfortunately it's not possible to test this failure in CI so we just fail"
    echo "Hopefully VOMS won't be used too much longer as tokens slowly take over"
    exit 1
fi

export LIBS="-lz"
./autogen.sh

# when cross-compiling we can't run host executables
if [[ "${build_platform}" == "${target_platform}" ]]; then
	EXE_PREFIX="${PREFIX}"
else
	EXE_PREFIX="${BUILD_PREFIX}"
fi

sed -i.bak "s#/usr/bin/soapcpp2#${EXE_PREFIX}/bin/soapcpp2#g" configure
rm configure.bak

./configure \
    --prefix="${PREFIX}" \
    --with-gsoap-wsdl2h="${EXE_PREFIX}/bin/wsdl2h"

make -j1
# make -j${CPU_COUNT}
make install
