#!/bin/sh

GREEN="\x1B[01;92m"
CLEAR="\x1B[0m"

set -e

function msg {
    printf "$GREEN==>$CLEAR $@\n"
}
function submsg {
    printf " $GREEN-->$CLEAR $@\n"
}

msg "Removing ${GREEN}llvm llvm_build${CLEAR}"
rm -rf llvm llvm_build
if [ ! -f llvm.tar.gz ]; then
    URL=http://foxling-clang.jeffhui.net/llvm.tar.gz
    msg "Downloading prebuilt LLVM & Clang binaries"
    submsg "$URL as llvm.tar.gz"
    curl -L $URL > llvm.tar.gz
fi
msg "Unpacking ${GREEN}llvm.tar.gz${CLEAR}"
tar -zxvf llvm.tar.gz

