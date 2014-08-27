# BUILD.md -- Building Kite

This file explains how to clone and build Kite.  This is the appropriate 
approach if you do not have a pre-built Kite executable available, if you 
will be working on Kite itself, or if you simply want to keep up with the 
latest snapshot.

## Bootstrapping Kite

If you have never run Kite on your system, and you need to build it from
scratch, do the following.

1. Install ActiveTcl 8.6.1 or later, so that its "tclsh" is on your path.

2. Install TclDevKit 5.0 or later, so that its "tclapp" is on your path.

3. Clone this project from github.jpl.nasa.gov into ~/github/athena-kite.

4. Switch to ~/github/athena-kite

5. Set up the local teapot repository; see "./bin/kite.tcl help teapot".
   On Linux and OS X, use "sudo -E" to run "kite.tcl teapot link"

    $ ./bin/kite.tcl teapot create
    $ ./bin/kite.tcl teapot link

6. Update Kite's dependencies. This will pull Snit and other required
   packages into the local teapot.

    $ ./bin/kite.tcl deps update

7. Build Kite.  This will run all tests, build all documentation, and so
   forth.

    $ ./bin/kite.tcl build all

8. Install Kite.  This will copy ./bin/kite-windows.exe (or whatever) 
   to ~/bin/kite, and install the Kite Tcl libraries into the local teapot.

    $ ./bin/kite.tcl install

9. Use Kite normally:

    $ kite help

## Building a new Kite executable

To build a new Kite executable given an existing Kite executable and 
Tcl development environment, do the following:

1. Switch to ~/github/athena-kite

2. Build Kite.  If there are any issues, follow Kite's instructions.

    $ kite build

3. Install Kite.

    $ ./bin/kite.tcl install

