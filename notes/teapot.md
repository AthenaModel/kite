# Teapot/Teacup Notes

This document contains notes on how Kite will make use of ActiveState's
teapot-related tools.

In particular, Kite will:

* Use teacup to pull dependencies (both packages and basekits) from 
  teapot.activestate.com.

* Use teacup to create a local repository in `~/.kite/teapot`.

* Pull dependencies into `~/.kite/teapot` rather than the default 
  `$TCL_HOME/lib/teapot`, since modifying that repository generally
  requires "sudo" on Linux and OSX.

* Package local libraries (e.g., Mars) for inclusion in a teapot
  repository using TDK's `teapot-pkg` application.

* Install local libraries into `~/.kite/teapot`.

* Use tclapp to build starkits and starpacks, using the dependencies
  from `~/.kite/teapot`.

Some of these steps are already well-understood; Athena's been building
starpacks for years and Kite can already build applications as starkits.
But some of the other steps require some research into how teapots work
and how the available tools work; and the fruits of that research will
be recorded here.

## A note on version numbers

The "1.2.3-SNAPSHOT" version numbering scheme used by Leiningen and Maven
won't work with Tcl packages; Tcl (and hence teacup/teapot) doesn't allow
the "-SNAPSHOT" suffix.  The closest we can get is "1.2a3" or "1.2b3"
indicating alpha or beta quality.  I would suggest using "1.2a3" format
for internal snapshots.  

For applications, we can use any version numbering scheme we like; we won't
be [package require]'ing them.

## Finding `teacup`

The `teacup` tool is installed with ActiveTcl and resides in the same
`bin/` directory as `tclsh` does.  This is important.

## Is a required package installed locally?

There's no easy way to find out whether a requirement is met locally or 
not.  Here's what you can do.

First, the following command will retrieve the list of versions of the
package that are installed locally, as a CSV table.

    teacup list --at-default --as csv <package>

Next, step through the rows in the CVS, finding whether there's an 
entry that [package vsatisfies] the required version.

## Creating `~/.kite/teapot`

This is trivially easy:

    teacup create ~/.kite/teapot

However, we will need to link this teapot to our development tclsh.
To do that:

    teacup link make ~/.kite/teapot `which tclsh`

If Tcl was installed as root on Linux or OSX, this is more complicated:

    sudo `which teacup` link make ~/.kite/teapot `which tclsh`

Finally, we will want to make ~/.kite/teapot the default teapot; on Linux
(and OSX) when Tcl is installed as root, this allows us to install things
into the repository without needing sudo:

    sudo `which teacup` default ~/.kite/teapot

If we leave the original teapot in place and linked, we should be fine.

## Installing a remote dependency into `~/.kite/teapot`

To install a package from `teapot.activestate.com`, use a command like
this:

    teacup install --at ~/.kite/teapot sqlite3 3.8.5

We may wish to use the `--with-recommends` option, which also installs all
of the package's required dependencies.

__Note on architectures:__ if you've not linked your development 
`tclsh` to `~/.kite/teapot` and
the package is a binary package, `teacup` will not be able to infer the
machine architecture, and you'll get an error.  You can force the
architecture using the `--arch` options.  The architectures we're likely
to need are:

* win32-ix86
* linux-*-ix86
* linux-*-x86_64
* macosx-*-x86-64

Note that pure-Tcl packages have an architecture of "tcl".

## Listing the packages in `~/.kite/teapot`

    teacup list ~/.kite/teapot

## Building starkits and starpacks against `~/.kite/teapot`

This is straightforward; at least, I think it is.

    tclapp ... -archive ~/.kite/teapot ...

## Preparing a local package for inclusion in ~/.kite/teapot

First, we can create Tcl modules (.tm's) or .zip archives.

Next, we need a `teapot.txt` file with
the required metadata.  It seems that the simplest we can use is

    Package fred 1.0
    Meta entrykeep 
    Meta included    *
    Meta platform    tcl

This tells teapot-pkg the package name and version, that we want to use
our own pkgIndex.tcl, and all files in the directory should be included
in the package, and that the package architecture is "tcl".

If we use "Meta entrysource pkgModules.tcl" instead of 
"Meta entrykeep" then `teapot-pkg` will generate its own pkgIndex.tcl.
We can also add a number of other descriptive metadata items, as shown
here:

    Meta category     GUI convenience library and widget set
    Meta description  The Mars GUI library
    Meta platform     tcl
    Meta require      {snit 2.3}
    Meta require      {Tcl 8.6}
    Meta require      {Tk 8.6}
    Meta summary      The Mars GUI library

Next, we can build the package as follows:

    teacup-pkg generate -t zip -o <output-dir> <package-dir>

This command will actually walk the _package-dir_ tree; a single
project could reasonable export multiple packages.  The created
package files go in the _output-dir_.

We can also use `-t tm` to create .tm modules; but .zip modules are 
more practical, as they can contain files other than .tcl code.

## Scanning automatically for packages

The command `teacup-pkg scan` can scan a directory tree and
build teapot.txt files, extracting dependencies automatically.  However,
it has problems for my purposes:

1. It misses the non-Tcl files (e.g., .sql files).
2. It extracts the dependencies; but I want to get those from the 
   project.kite file anyway.

These can be fixed, but they require adding obscure "pragmas" into the
package files, so I don't plan to use that.

## Installing a local package into ~/.kite/teapot

If I have a package file created by teapot-pkg, I can install it into
`~/.kite/teapot` using `teacup`:

    teacup install --at ~/.kite/teapot <package-file>

It can then be seen by any `tclsh` linked to the repository.

## Running a teapot server

The problem with installing local builds into the local `~/.kite/teapot` is
that every developer needs to do that.  I can build marsutil(n) 
and install it locally, but Dave would have to do the same on a regular
basis.

Another possiblity is to run a teapot server on oak.  We have the
code to do it; and I've tried it and it appears to work (modulo some odd
messages).  But we might get into trouble with JPL IT.