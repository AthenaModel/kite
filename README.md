# athena-kite

Kite build tool for Athena Tcl projects.

## Introduction

See also [BUILD.md](./BUILD.md) and [INSTALL.md](./INSTALL.md).

The vision for Kite is to be a 
[Leiningen-like](https://github.jpl.nasa.gov/will/athena-kite.git)
tool for Tcl development.  

## Assumptions

Kite currently assumes the following things about the user's development environment:

* A version of ActiveTcl is installed on the system.
* The tclsh is on the path; it can be executed from the command line as "tclsh".
* The "teacup" app (installed with ActiveTcl) is also on the path.
* TclDevKit is installed on the system, and tclapp is on the path.

# Copyright

Copyright 2014-2015, by the California Institute of Technology. ALL RIGHTS
RESERVED.  United States Government Sponsorship acknowledged. Any
commercial use must be  negotiated with the Office of Technology Transfer
at the California Institute  of Technology.
 
This software may be subject to U.S. export control laws. By accepting this
software,  the user agrees to comply with all applicable U.S. export laws
and regulations. User  has the responsibility to obtain export licenses, or
other export authority as may be  required before exporting such
information to foreign countries or providing access to  foreign persons.
