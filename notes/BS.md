# Brainstorming File

Take nothing in this file too seriously; it's either wrong or about to
be overtaken by events.

## Questions ###

**Q: Do we want to have a Kite command for initializing new packages in
the project?**

Yes, I think we do.  There's a basic template, and in lib projects, at
least, we want to keep the package version numbers consistent with the
project's version number.

**Q: Should kiteinfo be a package?**

The kiteinfo package could simply be a global variable, ::kiteinfo,
inserted into the app's loader script just like the version number is
inserted into each package's pkg*.tcl files.  Would this be better?

Probably not; we have the possibility of moving code from the load script
template into kiteinfo, and so simplifying the loader script.  Also,
it leaves the actual content of the loader script upto the user.