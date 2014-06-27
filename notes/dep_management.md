# Dependency Management

Dependencies will be of three kinds:

* basekits
* teapot packages
* includes

The user specifies dependencies in their project.kite file.  Teapot packages
are pulled into a local teapot using the teacup tool.  Basekits are acquired
the same way, or for now from the tclsh installation.

The issues about the includes is that we don't want to pull them in unless
they've changed.  I think we have to assume that the user hasn't been
mucking around with them.  The difficulty is knowing whether the user
has edited the project.kite file or not, and so whether to do a 
"git pull/svn update" or a complete clone/checkout.

Probably the thing to do is write the include signature to the directory
as .kite_include.  If the signature on the disk matches the project.kite
file, we assume that it's up to date unless they use "kite deps" and
force it.  Then we can do a "git pull/svn update".

If the signature doesn't match, the easiest thing is to blow the directory
away and "git clone"/"svn checkout".