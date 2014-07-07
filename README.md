# athena-kite

Kite build tool for Athena Tcl projects.

## Introduction

See also [BUILD.md](./docs/BUILD.md) and [INSTALL.md](./docs/INSTALL.md).

The vision for Kite is to be a 
[Leiningen-like](https://github.jpl.nasa.gov/will/athena-kite.git)
tool for Tcl development.  The initial goals are these:

* Support Athena development
* Reduce the dependency on Makefiles, except for building C/C++ code.
* Manage the dependencies on Mars and on the required basekit explicitly,
  rather than relying on Subversion's svn:externals to pull them in.
  (This is in preparation for a move to git.)
* Abstract Subversion out of the formal build process, e.g., Kite should
  be able to build the application and tag it using the de facto CM tool.
* Allow greater modularization of the Mars and Athena codebase: instead 
  of two huge projects (Mars and Athena) allow a number of smaller,
  more easily manageable projects.  For example, the latlong conversion
  code could easily be a separate Tcl extension, CM'd separately,
  and only rebuilt as needed.

The initial priority is managing the choice of Mars and the basekit
to be used in Athena development, so that we no longer rely on 
svn:externals.

## Assumptions

Kite currently assumes the following things about the user's development environment:

* A version of ActiveTcl is installed on the system.
* The tclsh is on the path; it can be executed from the command line as "tclsh".
* The "teacup" app (installed with ActiveTcl) is also on the path.
* TclDevKit is installed on the system, and tclapp is on the path.

## Things to Try Later

We can try doing some of the following in order to simplify development.

* Run with basekits in development as well as run-time.  The base-kit then becomes the
  equivalent of clojure.jar for a Leiningen project.
* It seems to be possible to create starkits and starpacks as "zipkits" given AT 8.6 and
  vfs::zip without using tclapp.  This would be a major step forward, as we could then
  do without TDK, but would require pulling packages from a teapot into the local vfs.
* Installing local packages (libkits) into ~/.teapot, perhaps as .tms.
