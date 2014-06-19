#!/usr/bin/env bash

# build.sh --
#
# This file shows how to build Kite as kite.kit, which can be
# executed by arbitrary Tcl shells (or, at least, by arbitrary
# ActiveTcl shells).  It should then execute as is on any of our
# development platforms.  
#
# This file is a bootstrap; ultimately, kite.kit should be able to
# build an executable as a .kit, or as an .exe given a basekit; and
# then it can be self-hosting.

export TCL_HOME=C:/Tcl/AT8.6.1
export ARCHIVE=$TCL_HOME/lib/teapot
export TOP_DIR=~/github/athena-kite
export KITE_KIT=$TOP_DIR/bin/kite.kit

tclapp $TOP_DIR/bin/kite.tcl                  \
    -log $TOP_DIR/tclapp.log                  \
    -out $KITE_KIT                            \
    -archive $ARCHIVE                         \
    -follow                                     \
    -force                                      \
    -pkgref "snit      -require 2.3"

