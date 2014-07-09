# INSTALL.md -- Installation

If you have downloaded "kite", the executable starkit, you can install it
as follows:

1. Install ActiveTcl 8.6.1 or later, so that its "tclsh" is on your path.

2. Install TclDevKit 5.0 or later, so that its "tclapp" is on your path.
   You can do quite a lot with Kite without TclDevKit, but you will not
   be able to build starkits or starpacks without it.

3. Drop "kite" in your local ~/bin directory, and mark it executable.
   Kite is now installed.  To test it:

    $ kite

4. Initialize the local teapot repository.  This will allow Kite to 
   pull in external dependencies safely.  See 'kite help teapot'
   for details.