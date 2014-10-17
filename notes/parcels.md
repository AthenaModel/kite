# Kite Parcels Design

A parcel is a way to deliver a project's library code as a kind of package
of packages.  A parcel is a .zip file with the following contents:

* docs/index.html -- parcel documentation entry point
* docs/...        -- Other parcel documentation
* lib/{name}/...  -- Code for provide library {name}.
* libzips/...     -- Teapot .zip files for the provided libraries.
* parcel.txt      -- A manifest file?

A parcel file can be used in several ways.

* Manually, a programmer can open it and install the docs and libs where
  he likes: in a teapot or in a project or wherever.

* Via Kite, the libraries could be installed into a local teapot.

* Via Kite, the parcel could made available for inclusion in another
  Kite project.

* Parcels could be the basis for a next-generation teapot-style repository.

## Creating Parcels

A parcel is defined as a distribution set called "parcel" or 
"parcel-%platform"; this allows the developer to determine what goes in
the parcel easily.

The parcel file would then be called

    {project}-{version}-parcel-{platform}.zip

where {platform} is "tcl" for Pure-TCL parcels.

Alternatively, project(5) could define a separate "parcel" command; but
the file patterns would be similar.  The "%lib" and "lib/*" patterns might
taken for granted, and all .html files in the docs/ tree might be included
automatically as well.

## Manifest File

It might be useful to include some kind of manifest file that defines
parcel metadata:

* Project and version (though these are in the file name)
* Dependencies
  * These should be real dependencies, i.e., dependencies of the provided
    libraries, not just of the project as a whole.

## Installing Parcels

Kite would define a new global directory, ~/.kite/parcels.  Parcel files 
would be installed into this directory (i.e., saved there).  Kite would need a "kite parcel" command for displaying and managing the contents of this
directory.

The 'kite install' command would install the project's parcel into 
the parcel repository.

In addition, 'kite parcel import' would import a parcel file into the parcel
repository.

## Using Parcels in a Kite project

The project.kite file could contain a new statement, "use" or "include":

    include mars 3.0.5

would tell Athena to include the Mars v3.0.5 parcel into the Athena project
tree.

Including the parcel would involve unzipping it into the project tree in some
.gitignore'd place, or unzipping it and putting individual files in particular
places.

Kite would need to be able to maintain the included parcels, which would
include deleting out of date content when the parcel changes.

### Including Parcels: Option 1

Define a {root}/parcels directory.  Parcel {project}-{version}.zip is 
unzipped there as {root}/parcels/{project}-{version}.

Then, define "{project}:" as a document prefix for the including project's
documentation, so that (for example) "{project}:mymodule(n)" links to the
included project's mymodule(n) man page.

Further, add "{root}/parcels/{project}-{version}/lib" to the auto_path for
development use, and include the lib directory in the built application.

**Problems:** Initialization is slower the number of distinct lib parent
directories there are.  It might be wise to have all included parcels share
one lib directory.

### Including Parcels: Option 2

Assume that this project will never include parcels with overlapping 
library package names (which it won't because that's just too annoying).

Define a parcels/lib directory.  All library packages for all included
parcels have their libs installed under parcels/libs.  parcels/libs is then
included in tclapp builds.

Similarly, all parcel documentation goes on parcels/docs/{project}.

We might need a file, parcels/manifest.txt, that records what's gone in,
so that we know what to delete on update.

Note that none of this goes into github.

## Network Repositories

Boxkite can server as a poor man's parcel repository.

## Open Questions

**Q: When I create a parcel, do I include the parcels included by the project?**

A: I wouldn't think so.  A library doesn't usually include its dependent
libraries.

**Q: If a project has no applications, do parcels make sense?**

A: They pull the code and docs in, where you can look at it; and you can
include transient versions, and use them, without polluting the teapot.

**Q: Is this worth doing, or just an added complication?**

A: Good question.
