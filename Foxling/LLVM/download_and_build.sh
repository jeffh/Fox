#!/bin/sh

LLVM_SVN_URL=http://llvm.org/svn/llvm-project/llvm/trunk
CLANG_SVN_URL=http://llvm.org/svn/llvm-project/cfe/trunk
CLANG_TOOLS_EXTRA_SVN_URL=http://llvm.org/svn/llvm-project/clang-tools-extra/trunk
COMPILER_RT_SVN_URL=http://llvm.org/svn/llvm-project/compiler-rt/trunk
LIBCXX_SVN_URL=http://llvm.org/svn/llvm-project/libcxx/trunk
LIBCXX_ABI_SVN_URL=http://llvm.org/svn/llvm-project/libcxxabi/trunk

VENDOR="Fox"
VENDOR_UTI=net.jeffhui.fox

GREEN="\x1B[01;92m"
CLEAR="\x1B[0m"

set -e

function msg {
    printf "$GREEN==>$CLEAR $@\n"
}
function submsg {
    printf " $GREEN-->$CLEAR $@\n"
}

function checkout {
    local url=$1
    local dest_dir=$2
    msg "svn checkout $GREEN$url$CLEAR -q"
    submsg "destination: $GREEN$dest_dir$CLEAR"
    mkdir -p `dirname "$dest_dir"`; true
    pushd `dirname "$dest_dir"`
    svn co "$url" "`basename "$dest_dir"`" -q
    popd
}

function download_and_extract {
    local url=$1
    local dest_dir=$2
    local filename_with_tar_xz=`basename "$url"`
    msg "Download & Untar $GREEN$filename_with_tar_xz$CLEAR"
    submsg "destination: $GREEN$dest_dir$CLEAR"
    pushd `dirname "$dest_dir"`
    curl -L "$url" | tar -xJ
    mv "${filename_with_tar_xz%.tar.xz}" `basename "$dest_dir"`
    popd
}

msg "Deleting ${GREEN}llvm llvm_build llvm_output$CLEAR"
rm -rf llvm llvm_build llvm_output; true

msg "Downloading bleeding edge..."
checkout "$LLVM_SVN_URL" llvm
checkout "$CLANG_SVN_URL" llvm/tools/clang
checkout "$CLANG_TOOLS_EXTRA_SVN_URL" llvm/tools/clang/tools/extra
checkout "$COMPILER_RT_SVN_URL" llvm/projects/compiler-rt
checkout "$LIBCXX_SVN_URL" llvm/projects/libcxx
checkout "$LIBCXX_ABI_SVN_URL" llvm/projects/libcxxabi

mkdir llvm_build

pushd llvm_build

msg "Configuring LLVM and Clang"
submsg "Vendor = $GREEN$VENDOR$CLEAR"
submsg "Vendor_UTI = $GREEN$VENDOR_UTI$CLEAR"
cmake ../llvm \
    -DCMAKE_BUILD_TYPE:STRING=Release                  \
    -DCLANG_BUILD_EXAMPLES:BOOL=ON                     \
    -DCLANG_PLUGIN_SUPPORT:BOOL=ON                     \
    -DLLVM_ENABLE_RTTI:BOOL=ON                         \
    -DCMAKE_INSTALL_PREFIX:STRING=`pwd`/../llvm_output \
    -DCLANG_VENDOR:STRING="$VENDOR"                    \
    -DCLANG_VENDOR_UTI:STRING="$VENDOR_UTI"            \
    -DLLVM_INSTALL_TOOLCHAIN_ONLY:BOOL=ON              \
    -DLLVM_ENABLE_LIBCXX:BOOL=ON                       \
    -DLIBCXXABI_ENABLE_SHARED:BOOL=OFF                 \
    -DLIBCXX_ENABLE_SHARED:BOOL=OFF

msg "Compiling LLVM and Clang"
make -j`sysctl -n hw.logicalcpu`

popd
