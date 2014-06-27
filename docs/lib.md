# Library Projects

A library project is a Kite project that exists to make one or more Tcl
packages available to other projects.

## Questions and Issues

**Q: Should we support multiple packages in one "lib" tree?**

Yes, certainly.  This will be common.  But they should all have the
same version number.

**Q: What needs to go into the project.kite file?**

For each library, 

    lib libname

where "libname" is both the package name and the "lib" subdirectory.

We might add additional arguments to customize how it's built, later.

**Q: What needs to be changed in a "lib" package when project.kite changes?**

Libs need their version number; and really, only as the normal package 
version.  I don't think lib projects need a kiteinfo.

**Q: How does a "lib" package know the version number from project.kite?**

Clearly, we need to update the pkgIndex.tcl and pkgModules.tcl files,
since that's where the version number goes.  My notion is this.  In 
pkgIndex.tcl, add comments:

```tcl
# -kite-ifneeded-start
package ifneeded ktools 1.0 [list source [file join $dir pkgModules.tcl]]
# -kite-ifneeded-end
```

and similarly, in pkgModules.tcl:

```tcl
# -kite-provide-start
package provide ktools 1.0
# -kite-provide-end
```

Kite can update these just as it updates kiteinfo; but instead of writing
the whole file, it needs to look for the markers and replace just the
given line, in such a way that the file content only changes if the 
version number changes.

**Q: What is the needed boilerplate for a "lib" project tree?**

We don't need a kiteinfo.  We need the directory itself, pkgIndex.tcl,
pkgModules.tcl, and the initial code file; and whatever is required to
support "kite shell".

**Q: What is required to support "kite shell"?**

The "kite shell" command should open up a tkcon in the project directory
with the project's lib directories on the auto_path.  Kite knows what 
libraries are available; and "kite shell" shouldn't require any of them
unless asked (that could be an option in project.kite).

So what "kite shell" should do is write a temporary file, ".kite/shell.tcl",
that extends auto_path, and then invoke tkcon.

Build logs should probably go in ".kite" as well.  And ".kite" should be
ignored.

**Q: How do we handle lib dependencies?**

We pull them into the local environment so that the lib can be used and
tested locally.

If we build teapot packages, we include the external dependencies in the
teapot.txt.  This pretty much requires that we not have any "include"'s.

For libs that will be "included" in other projects, it's up to that 
project to list any required external dependencies to its own 
project.kite file.

**Q: Do we want a "kite add lib" tool?**

Very possibly.


## Deployment Issues

In theory, we'd like to be able to create and package up projects for
inclusion in a teapot; this would be necessary for a publically 
available kite-like tool.  We aren't going to be submitting packages to
teapot.activestate.com, so what's the point?

If we have our packages in a local teapot, we can use them in any
Tcl script, transparently, and our other projects can treat them just
like any other external dependencies.  That's very nice.  The difficult
is populating that local teapot.

* We can run our own remote opaque teapot server on oak, and push our
  packages to it.  This makes them available to everyone on the team;
  but means we need to maintain the server process.  Also, JPL IT might
  make us shut it down.

* Each developer can individually build each version of each relevant 
  package and install it into a local teapot.  UGH!  Double UGH!  Not
  good.

The other alternative is placing the projects on GitHub or Subversion,
and letting projects pull them in as local "include"s.  That's simple.
It gives us versioning, it doesn't require any server we don't already
have, and doesn't require any additional work on the part of the developer.

And if we are using them as includes, we don't need to build anything.

ON THE OTHER HAND, it can be convenient for the developer to have 
locally-developed packages "just available".  So we'd like the ability
to package them up and install them into the local teapot anyway,
not as a general practice, but as a convenience to the developer.

## Conclusions

For now,

* Focus on making "lib" packages available as include's.
* Add a "lib" command to package.kite.  For now, it's just "lib name".
  There can be several. DONE
* Revise the lib template to include the markers in the "pkg*" files.
  DONE
* Only create kiteinfo if there's an appkit. DONE
* Update the "lib" pkg* files at the same time as kiteinfo. DONE
* Move build logs to ".kite", which is gitignored. DONE
* Support "kite shell" using a ".kite/shell.tcl" script. DONE
* Add a "shell" command to package.kite that defines a script to be 
  appended to the .kite/shell.tcl script.  It can require packages, 
  import names, etc. DONE.

Later,

* Add the ability to package libs for inclusion in a teapot repository.
* Add the ability to install them in ~/.kite/teapot.
* Consider using https://oak/kite as a kind of "kite server".
* Consider how to include teapot packages into a Kite project.
  Put them in lib/tm and add that to the tm::path?  That'd work....
* Consider how to associate documentation with a lib.
