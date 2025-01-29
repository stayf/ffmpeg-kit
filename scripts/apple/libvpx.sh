#!/bin/bash

# SET BUILD OPTIONS
TARGET=""
ASM_OPTIONS=""
case ${ARCH} in
armv7 | armv7s)
  TARGET="$(get_target_cpu)-darwin-gcc"
  ;;
arm64*)
  TARGET="arm64-darwin-gcc"
  ASM_OPTIONS="--disable-runtime-cpu-detect --enable-neon"
  ;;
i386)
  TARGET="x86-iphonesimulator-gcc"
  ;;
x86-64*)
  if [[ ${ARCH} == "x86-64-mac-catalyst" ]]; then
    TARGET="x86_64-macosx-gcc"
  else
    TARGET="x86_64-iphonesimulator-gcc"
  fi
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --target="${TARGET}" \
  --extra-cflags="${CFLAGS}" \
  --extra-cxxflags="${CXXFLAGS}" \
  --as=yasm \
  --log=yes \
  --enable-libs \
  --enable-install-libs \
  --enable-pic \
  --enable-optimizations \
  --enable-better-hw-compatibility \
  --enable-vp9-highbitdepth \
  ${ASM_OPTIONS} \
  --disable-vp8 \
  --disable-vp9-decoder \
  --enable-vp9-encoder \
  --enable-multithread \
  --enable-spatial-resampling \
  --enable-small \
  --enable-static \
  --disable-realtime-only \
  --disable-shared \
  --disable-debug \
  --disable-gprof \
  --disable-gcov \
  --disable-ccache \
  --disable-install-bins \
  --disable-install-srcs \
  --disable-install-docs \
  --disable-docs \
  --disable-tools \
  --disable-examples \
  --disable-unit-tests \
  --disable-decode-perf-tests \
  --disable-encode-perf-tests \
  --disable-codec-srcs \
  --disable-debug-libs \
  --disable-internal-stats || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
