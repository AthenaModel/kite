# BUILD.md -- Building Kite

This file explains how to clone and build Kite.  This is the appropriate 
approach if you do not have a pre-built Kite executable available, if you 
will be working on Kite itself, or if you simply want to keep up with the 
latest snapshot.

## Bootstrapping Kite

If you have never run Kite on your system, and you need to build it from
scratch, do the following.

1. Install ActiveTcl 8.6.4 or later, so that its "tclsh" is on your path.

2. Install TclDevKit 5.1 or later, so that its "tclapp" is on your path.

3. Clone this project from github.jpl.nasa.gov into ~/github/kite, and
   add ~/github/kite/bin to your path.  Verify that you can run Kite
   as a Tcl script:

```
     $ kite.tcl version
     Kite 0.5.0
     $
```

   If you cannot, then check your Tcl installation.

4. Switch to ~/github/kite

5. Set up the local teapot repository; see "kite.tcl help teapot".

```
    $ kite.tcl teapot fix
```

6. Kite will create the local teapot directory in ~/.kite/teapot; however,
   it will also need to link it to your "tclsh", which requires admin 
   privileges.  Consequently, it will create a script, "~/.kite/fixteapot"
   ("~/.kite/fixteapot.bat" on Windows) that takes the necessary steps.
   Run this script.

   On Linux and OSX, you will usually need to run it using "sudo":

```
     $ chmod +x ~/.kite/fixteapot
     $ sudo ~/.kite/fixteapot
```

   On Windows, just run the batch file:

```
     C:\> .kite/fixteapot.bat
```

   Verify that the work is complete:

```
     $ kite.tcl teapot
     Local teapot: /home/will/.kite/teapot

     Kite's local teapot is ready for use.
     $
```

7. Update Kite's dependencies. This will pull Snit and other required
   packages into the local teapot.

```
    $ kite.tcl deps update
```

8. Build Kite.  This will run all tests, build all documentation, and so
   forth.

```
    $ kite.tcl build
```

9. Install Kite.  This will copy ./bin/kite-<version>-<platform>.exe 
   (or whatever) to ~/bin/kite, and install the Kite Tcl libraries into the 
   local teapot.

```
    $ kite.tcl install
```

   NOTE: When installing a new build of Kite, always use kite.tcl to do
   do the installation, rather than a previously installed Kite executable.
   If you say

```
    $ kite install                    DON'T DO THIS
```

   then ~/bin/kite will try to overwrite itself with the new executable.
   This is known not to work on Windows systems.

   The 'kite install' form works just fine for other projects.

10. Add ~/bin to your execution path.

11. Use Kite normally:

```
    $ kite version
    Kite 0.5.0
    $
```

## Installing Kite

Building Kite creates an installation .zip file for the current platform.
See INSTALL.md for instructions on how to install Kite given the installation
.zip file.

## Building a new Kite executable

To build a new Kite executable given an existing Kite executable and 
Tcl development environment, do the following:

1. Switch to ~/github/kite

2. Build Kite.  If there are any issues, follow Kite's instructions.

```
    $ kite build
```

3. Install Kite.

```
    $ kite.tcl install
```

Note that it isn't necessary to build Kite to test changes; just use
`kite.tcl` instead of `kite` to run with your modifications.