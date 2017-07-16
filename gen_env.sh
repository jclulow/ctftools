#!/bin/bash

cat <<EOF
export NIGHTLY_OPTIONS='-CimMNnt'
export CODEMGR_WS='$1'
export MAKEFLAGS='k'
export ROOT='$PWD/proto'
export MULTI_PROTO='no'
export NATIVE_ADJUNCT='/opt/local'
export SRC="\$CODEMGR_WS/usr/src"
export MACH="\$(uname -p)"

export MCS=/usr/bin/mcs
export STRIP=/usr/bin/strip
export LEX=/opt/local/bin/lex
export YACC=/opt/local/bin/yacc
export PYTHON=/opt/local/bin/python2.7
export RPCGEN=/opt/local/bin/rpcgen
export ELFDUMP=/usr/bin/elfdump

export LINT=/bin/true

export CW_NO_SHADOW=1
export BUILD_TOOLS="\$CODEMGR_WS/usr/src/tools/proto/root-\$MACH-nd/opt"
export GNU_ROOT='/opt/local'
export GCC_ROOT='/opt/local'
export CW_GCC_DIR="\$GCC_ROOT/bin"
export __GNUC=''
export __GNUC4=''

export ON_CLOSED_BINS="\$CODEMGR_WS/closed"
EOF
