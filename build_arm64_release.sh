#!/bin/bash

# Usage: 
#       chmod +x build_arm64_release.sh
#       ./build_arm64_release.sh

set -e

cmake -Bbuild3 -DLLDB_ENABLE_PYTHON=OFF -DLLVM_ENABLE_LIBXML2=OFF -DLLVM_ENABLE_ZLIB=OFF -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="AArch64" -DLLVM_ENABLE_PROJECTS="clang;lld" llvm
cmake --build build3 --config Release


