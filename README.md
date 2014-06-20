# athena-kite

Kite build tool for Athena Tcl projects.

## Introduction

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
* The tclsh's teapot repository is in the default place, e.g., <tcldir>/lib/teapot.
* TclDevKit is installed on the system, and tclapp is on the path.
