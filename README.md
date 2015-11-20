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

## License

This code has been open-sourced by the California Institute of Technology under JPL NTR-47857; see [LICENSE](LICENSE) for the license terms.
