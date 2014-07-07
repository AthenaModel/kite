# BUILD.md -- Building Kite

You can clone and build Kite as follows; this is the appropriate approach
if you do not have a pre-built Kite executable available, if you will
be working on Kite itself, or if you simply want to keep up with the 
latest snapshot.

1. Install ActiveTcl 8.6.1 or later, so that its "tclsh" is on your path.

2. Install TclDevKit 5.0 or later, so that its "tclapp" is on your path.

3. Clone this project from github.jpl.nasa.gov into ~/github/athena-kite.

4. Switch to ~/github/athena-kite

5. Update Kite's dependencies. This will clone athena-mars into 
   ~/git/athena-kite/includes.  You will  need to enter your GitHub 
   Enterprise password.

    $ ./bin/kite.tcl deps update


6. Build Kite

    $ ./bin/kite.tcl build

7. Install Kite.  This will copy ./bin/kite.kit to ~/bin/kite.

    $ ./bin/kite.tcl install

8. Use Kite normally:

    $ kite help
