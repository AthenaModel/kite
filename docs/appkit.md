# Application Kits

An application kit, or "appkit", is a Tcl application packaged as a 
starkit using `tclapp`.  It can be run as an application on any system
that has ActiveTcl installed, with `tclsh` on the path.

The essential parts of appkit "mykit" are as follows:

* `bin/mykit.tcl` -- The application main routine.
* `lib/core/*` -- The application's core package.
* `lib/other/*` -- Any other packages in the lib directory.
* `includes/*/lib/*` -- Any included libraries
* Any `require`'d teapot dependencies.

When the project is built, is built, all of the above are wrapped up and 
placed in `mykit.kit`. 

## Issues and Questions

**Do we want to allow multiple appkits in one project?**

It's easy enough to build multiple appkits in one project; we simply need
a `bin/mykit.tcl` script for each one.  The difficulty is customizing the
dependencies for each appkit.  If we don't mind including all of the libs 
and all of the includes and (possibly) all of the teapot dependencies in 
each appkit, whether it needs it or not, then there's no problem.  But if
we want to tailor the payload for each appkit, then there is.

The maxim is that normal things should be simple, and rare things should 
be doable.  So we could add syntax allowing particular appkits to exclude
particular dependencies.

**Do we want to include teapot dependencies in the appkit?**

If it works, we probably do.  Then you can give a kit to another user on
another machine; they have to have the right tclsh installed, but they
don't have to have their teapot populated the way you do.

**Why would we want to have multiple appkits in one project?**

The alternative to having multiple appkits is to have a single appkit
with subcommands, as kite does.  Sometimes that's appropriate; and it
allows us to have a simpler project.  And in general, we're moving 
toward having more projects that are simpler rather than having a couple
of huge ones.  

On the other hand, Athena has the main executable, delivered as a starpack,
and a fair number of ancillary tools, like the celltool.  At present only
the Athena user can use these; they depend on the development environment.
But the celltool could have been useful to Bob Chamberlain, or ultimately
to Brian, or whoever helps us update the CGE.  If we can build them as
kits, we can give them to someone.

Athena currently has:

* athena_sim, the main executable
* athena_pbs, a prototype for doing mass runs on a cluster, which only
  we have ever used; and the relevant cluster is gone.  It's an
  athena.exe subcommand on Linux, which is appropriate.
* athena_ingest, a prototype ingestion tool.  It's temporary; the 
  code will ultimately be pulled into athena_sim(1) in some form.
* athena_cell, which could easily be a separate project.  
* athena_projinfo, which will be obsolesced by Kite.
* athena_version, which is obsolete and can be removed.
* app_help, which is a development tool for building the helpdb.
  It should probably be a separate project.

mars(1) is currently implemented as one app with multiple tools; it
should possibly be split into multiple tools:

* Some as mars(1)
* Some as part of Kite
* Some as separate projects

But clearly there is no real problem in the case of Mars with having one
appkit for the whole shebang.

**What should the appkit's core package be called?**

If we only allow one appkit per project, it doesn't matter; core is fine.
By definition, an appkit's core package isn't a lib to be shared with 
others.

If we allow multiple appkits per project, then each will need its own
core package, and they will need to have different names.  It would be
wise to give them distinct names from the get-go.

**Should we require specific core package names?**

That is, should we insist that an appkit's core package have a specific
name?  

On creation of an appkit, we do, because we want to set up the 
loader script to automatically require the core package.  Thus, if 
have a "kite add appkit" tool, it would create a core package with the
same name it puts in the loader script.

I can only see three reasons why we might want to insist on it later in
the lifecycle:

* If the multiple appkits could have different version numbers, so that
  their packages should have different version numbers.

* If we tried to auto-tailor what lib directories go into the .kit file
  on build, in which case it would be nice to be able to exclude 
  core packages for other kits.

* If I wanted to build the kite-info into the appkit's core package
  instead of making it a separate kiteinfo package.

It seems to me that even now, I should give the core package a 
unique name.

**What appkit files need to be updated on project.kite change?**

On project name, or (especially) version, the kiteinfo(n) package.

On appkit name, the appkit loader file and core package would probably
need to be renamed...but it's not at all clear to me that Kite can do
that automatically (unless we have something like "kite appkit rename").
But renaming files gets the VCS involved, and should be left to the 
developer.

**Should kiteinfo be built into the appkit's core package?**

No.  A single appkit can reasonably include multiple libraries;
and if we allow multiple appkits, they can reasonable share a kiteinfo;
and it means that we can update it without knowing anything about the
appkits.

## Conclusions ##

For now:

* Allow only one appkit.  Analysis shows we don't really need more than
  that for anything we're doing.

* Name the core package after the appkit, e.g., appkit_mykit, to allow
  for future growth.

* If it can be easily done, set the versions in the packages in the
  lib directory to the project version.

Assuming we do allow multiple appkits in one project:

* All will have the same version number, the project version number.
  * If you want distinct version numbers, create two projects.

* At first, all appkits get all of the dependencies.
  * When there's time, add an "exclude" capability.

