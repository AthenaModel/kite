# Teapot/Teacup Notes

This document contains notes on how Kite will make use of ActiveState's
teapot-related tools.

In particular, Kite will:

* Use teacup to pull dependencies (both packages and basekits) from 
  teapot.activestate.com.

* Use teacup to create a local repository in `~/.teapot`.

* Pull dependencies into `~/.teapot` rather than the default 
  `$TCL_HOME/lib/teapot`, since modifying that repository generally
  requires "sudo" on Linux and OSX.

* Package local libraries (e.g., Mars) for inclusion in a teapot
  repository using TDK's tclpe.

* Install local libraries into `~/.teapot`.

* Use tclapp to build starkits and starpacks, using the dependencies
  from `~/.teapot`.

Some of these steps are already well-understood; Athena's been building
starpacks for years and Kite can already build applications as starkits.
But some of the other steps require some research into how teapots work
and how the available tools work; and the fruits of that research will
be recorded here.

## Creating `~/.teapot`

This is trivially easy:

    teacup create ~/.teapot

