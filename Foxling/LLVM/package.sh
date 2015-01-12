#!/bin/sh

GREEN="\x1B[01;92m"
CLEAR="\x1B[0m"

set -e

function msg {
    printf "$GREEN==>$CLEAR $@\n"
}

msg "Packaging ${GREEN}llvm.tar.gz${CLEAR}"
rm -f llvm.tar.gz || true 2>&1 > /dev/null
tar --exclude '*.svn*' \
    --exclude '*.o' \
    --exclude '*CMakeFiles*' \
    --exclude '*.tmp' \
    --exclude '*.cmake' \
    -zvcf llvm.tar.gz \
    llvm/include \
    llvm/tools/clang/include \
    llvm_build/include \
    llvm_build/lib \
    llvm_build/tools/clang/include

