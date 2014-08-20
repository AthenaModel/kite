# INSTALL.md -- Installation

To install Kite given an installation .zip file, do the following.

1. Install ActiveTcl 8.6.1 or later, so that its "tclsh" is on your path.

2. Install TclDevKit 5.0 or later, so that its "tclapp" is on your path.
   You can do quite a lot with Kite without TclDevKit, but you will not
   be able to build starkits or starpacks without it.

3. Unpack the installation zip file somewhere in your home directory, say
   in "~/kite/".

4. If desired, point your web browser at the <kite>/docs/index.html file, 
    and save a bookmark. 

5. In that directory, copy the executable to your ~/bin directory (or
   somewhere else on your PATH).

    $ cp <kite>/bin/kite.kit ~/bin/kite

6. Kite is now installed.  To test it:

    $ kite

7. Initialize the local teapot repository.  This will allow Kite to 
   pull in external dependencies safely.  See 'kite help teapot'
   for details.

8. If desired, install the Kite Tcl packages into the local teapot.
   In the Kite directory, e.g.,

    $ teacup install package-kiteutils-<version>-tcl.zip