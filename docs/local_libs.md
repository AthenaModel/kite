# Notes on Local Dependencies

One of the big challenges for Kite is how to handle external dependencies
that are developed locally.  For example, Athena depends on Mars, as 
follows:

* On library packages, at run-time:
  * marsutil(n)
  * simlib(n)
  * marsgui(n)

* On development tools at build time:
  * mars_man(1)
  * mars_doc(1)
  * mars_link(1)

* On documentation at development time
  * mars/docs/*
  * Some things from mars/docs/* go into the build.

At present, we get these via `svn:externals`; the entire Mars build tree
is checked out as a subdirectory of athena/.  We want to change that;
and so the question is, how do we get access to these things when we 
need them? They aren't in the ActiveState teapot (and won't be) so 
whatever solution I implement for normal external dependencies doesn't
apply.

## Local Includes

To begin with, we'll implement the notion of "local includes".  We'll be
relying on teapot.activestate.com for truly external dependencies, but
local stuff will be in one CM repository or another.  So what we'll do
is this.

First, we'll add an `include` command to project.kite.  It can have a 
number of forms:

* `include svn mars https://oak.jpl.nasa.gov/svn/mars/tags/mars_2.34`
* `include git mars https://github.jpl.nasa.gov/athena/athena-mars v3.0.0`
* `include dir mars ~/mars`  

The latter would be for use as a temporary stop-gap, typically.

On `kite deps`, Kite will try to pull down all dependencies, including
these includes.  Included project "_project_" will go in the 
"_root_/includes/_project_/" directory.  The "includes" subdirectory will
be included in the default ".gitignore" file.

# Discussion

## Development Tools

The three development tools needed to build Athena are 
mars_man(1), mars_doc(1), and mars_link(1).  Of these, 
mars_link(1) is all about managing the svn:externals link to Mars;
thus, it's irrelevant to this discussion.

mars_man(1) and mars_doc(1) are both ehtml(5)-based documentation tools.
We run them from ~/athena/mars but could just as easily run them from
~/mars, or as just plain standalone .kits.  The one thing about them
that's a potential difficulty is that the processed man pages can 
bring in the project code, i.e, to auto-document enum types.  That 
argues for them being .kits running against the default `tclsh`.

We can clearly ensure that they can see project code without embedding
them in the Athena build tree.

Possibly, they should become part of Kite.

## Documentation

Originally, we shipped all of the Athena and Mars documentation out with
Athena in the Linux .tarball.  With Windows we ship only the athena(1) man
page, the AUG, the AAG, the Rules, and the MAG.  (And now, I guess, Bob's
CGE document).  

Therefore, all we need from Mars is the MAG, which is a .docx file.
We've already determined that .docx and .pptx files don't really
belong in git repositories; we're going to have to find another solution
for them anyway.  

Thus, the Mars documentation is not an issue so far as pulling local
dependencies in is concerned.

## Library Packages

Each of the three library packages is a simply one-directory package.
There are two ways we could get access to them.

One is discussed in [teapot.md](./teapot.md): build Mars independently,
and install it into the local `~/.teapot`.  Then, the Mars packages are
no different than any external dependency.  That's kind of nice.  However,
each user then needs to keep their local `~/.teapot` up to date, which
you'd want to automate.  (Alternative, we could install them into a 
true teapot server, which has its own headaches.)

Another possibility is to pull the package directories into the project
tree somewhere that's ignored by git, e.g.,

  gitlibs/mars/lib/mypackage/ 

We'd do that by specifying a git dependency in project.clj:

  require marsutil https://github.jpl.nasa.gov/will/mars-util

And then the gitlibs tree (or some subset of it) would get 
included in the starpack.  But this requires Kite knowing something
about git, and how to pull down specific tags.

(See above for how we decided to handle this.)