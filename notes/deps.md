# Dependency Management

A Kite project can have the following kinds of external dependency:

* teapot packages
  * From remote teapot repository
  * Locally built and installed
* basekits
  * For the current platform
  * With and without Tk

## Teapot Packages

A teapot package is a Tcl package installed in a remote or local "teapot"
repository, using the teapot-related tools that ship with ActiveTcl.

The user specifies dependencies on teapot packages in by adding `require`
statements to their `project.kite` file, e.g., 

    require snit 2.3

### Retrieving Teapot Packages from Remote Repositories

Projects will often require packages produced non-locally.  Kite will
attempt to retrieve these from a remote teapot repository, usually
http://teapot.activestate.com.  By default, every required package is
assumed to non-local.

### Locally-built Teapot Packages

A project may depend on library packages produced by other local projects.
It will retrieve these from the local teapot, just as for other external 
packages, and will track whether the local teapot contains the required
versions.  However, it will never attempt to retrieve them from a remote
teapot repository.

To mark a package as locally produced, use the `-local` flag:

    require kitedocs 1.0.0 -local

## Basekits

A basekit is a single-file Tcl interpreter that includes the necessary
additional libraries to support use as the "prefix" of a wrapped 
standalone executable.  As such, basekits are an implicit dependency of any 
project that builds standalone executables.  

ActiveState includes two basekits with the ActiveTcl installation, one that 
includes Tk and one that doesn't.  The non-Tk basekit is smaller, resulting
in smaller executables when Tk isn't required; but the distinction is
especially important on Windows systems, where Tk applications do not have
access to stdin, stdout, and stderr.

At present, Kite is delivered as a .kit, and is run using the development
Tcl installation; and finds the basekits for the current system relative
to that Tcl installation.  This means that Kite can only build executables
for the specific platform on which it is running.

Basekits can also be retrieved from http://teapot.activestate.com using the
`teacup` tool.  In the future, Kite may take advantage of this to support
cross-platform builds.

