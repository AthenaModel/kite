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

## Statments

<dl>
<dt> <b><code>project <i>name version description</i></code></b>
<dd> <b>Required.</b>  This statement names the project, gives its
    current <i>version</i>, and a brief text description.  The project
    <i>name</i> and <i>version</i> are usually defined to match the 
    project's name in the VCS of choice.<p>

    For example,<p>

    <pre>project athena-mars 3.0.0 "Mars Simulation Support Library"</pre>

</dl>