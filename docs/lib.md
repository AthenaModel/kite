# Library Projects

A library project is a Kite project that exists to make one or more Tcl
packages available to other projects.

## Questions and Issues

**Q: What needs to be changed in a "lib" package when project.kite changes?**

**Q: How does a "lib" package know the version number from project.kite?**

**Q: What is the needed boilerplate for a "lib" project tree?**

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
