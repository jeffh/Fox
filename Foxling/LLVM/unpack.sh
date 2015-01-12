#!/bin/sh

GREEN="\x1B[01;92m"
CLEAR="\x1B[0m"

set -e

function msg {
    printf "$GREEN==>$CLEAR $@\n"
}

msg "Removing ${GREEN}llvm llvm_build${CLEAR}"
rm -rf llvm llvm_build
msg "Unpacking ${GREEN}llvm.tar.gz${CLEAR}"
tar -zxvf llvm.tar.gz

