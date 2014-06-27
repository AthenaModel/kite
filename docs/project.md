# project(5): project.kite file syntax

TODO: This should really be a mars_man(1) man page, but I'm not set up 
for that yet.

The `project.kite` file defines the project's name, version, external
dependencies, and build targets, and controls how Kite performs its tasks.
This document describes the required and optional contents of the 
`project.kite` file. 

Every `project.kite` file will begin with a `project` statement.  This
is typically followed by one or more build target statements, e.g.,
`appkit`.  And these are followed by one or more dependency
statements, which define the external software required to build the
build targets.

The project file is a Tcl script, and so follows Tcl quoting 
rules.

# Statements

## project _name version description_

**Required.** This statement names the project, its
current _version_, and a brief text _description_.  The project
name and version are usually defined to match the 
project's name in the VCS of choice.

For example,

    project athena-mars 3.0.0 "Mars Simulation Support Library"

The version number must be a valid Tcl package version number, as 
described on Tcl's package(n) man page, except that it may include
an optional suffix.  Tcl package version numbers should consist of two 
or more integers, separated by dots; the final dot may be replaced by
"a" or "b" indicated alpha or beta status.  The suffix, if given,
can be any word preceded by a hyphen.  Thus, the following are valid
project version numbers:

* "1.2"
* "1a2"
* "1.2b3"
* "1.2.3"
* "1.2.3-SUFFIX"

## appkit _name_
 