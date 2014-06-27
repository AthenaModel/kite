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

## Statements

### project _name version description_

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

### appkit _name_

This statement tells Kite that the project builds an application as a ".kit"
file.  A .kit contains an application that needs to run against a local 
installation of Tcl.

A project file may contain at most one `app` or `appkit` statement.

The appkit's main routine must be found in "<i>root</i>/bin/<i>name</i>.tcl";
it will be built as "<i>root</i>/bin/<i>name</i>.kit".

The easiest way to create a new appkit is via the `kite new appkit` or 
`kite add appkit` commands.

### lib _name_

This statement tells Kite that the project defines a Tcl library package
intended for use by other projects.  The package will be called _name_;
it must reside in "<i>root</i>/lib/<i>name</i>", and will always have the 
same version number as the project as a whole.

A project may contain any number of library packages.  Note that only
packages intended for export need to be declared with "lib"; a project
defining an appkit will often contain a number of packages intended for
use only by the application itself, and these need not be declared.

### include _name vcs url tag_

This statement tells Kite that this project depends on another project 
called _name_, and directs Kite to pull the other project's code from its
VCS repository into the "<i>root</i>/includes/<i>name</i>" directory
so that this project can make use of it.

The _vcs_ may be **git** or **svn**.  The _url_ is the base URL of the 
project in the Git or Subversion repository.  The _tag_ is the specific
version of the project to retrieve.  For Git, the _tag_ can be a 
branch or tag name; for Subversion, the _tag_ will simply be added to
the _url_ as _url/tag_.

Kite assumes that the included project contains one or more Tcl
packages in its "lib" directory, and thus adds 
"<i>root</i>/includes/<i>name</i>/lib" to the auto_path.

When an app or appkit is built, the included projects will be built into it.
For lib-only projects, the included projects are available for testing, but
will not be built into the exported packages.

### shell _script_

The _script_ will be automatically loaded in the Tcl shell produced
by the `kite shell` command for "lib-only" projects or if 
`kite shell -plain` is used.  This allows the project to customize
which packages are required by default.
