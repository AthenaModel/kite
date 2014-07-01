# Project TODO List

* Test Kite on Linux
* "kite deps" problem on OS X
  * Even with a local teapot in the user's home directory as the default
    teapot, you need to do "sudo" on "teacup install".
  * On the other hand, "sudo kite deps update" works fine.
  * And I can build console-mode exes on OSX, which I hadn't expected.
  * Try this on Linux.
* Consider getting rid of the .kite/teapot.  The only purpose to it is to
  avoid sudo (a good thing), and if teacup won't work nicely on Linux
  without sudo then there's no point in the extra trouble.
  * The only command it matters for is [kite deps update], and that's not
    such a big deal.
* kite test
  * Complete kite test suite.
* kite add appkit|lib
* Consider using basekits from teapot.

# Remaining Gaps #

The remaining major gaps in Kite's tool set:

* kite retest
  * Execute only tests that failed last time.
* kite add
  * Add libs or an app/appkit to an existing project.
  * Requires writing the project file, not just reading it.
* kite clean
  * Remove bin/*.kit, .kite/*, other kite artifacts.
* kite build
  * Building of docs
  * Building of teapot packages for libs.

The remaining major gaps in Kites feature set:

* Handling of .ehtml documentation.
* Plugins for building other build targets (e.g., HTML help)
* Handling of other build targets.
  * E.g., C libraries.
  * At least need to be able to specify them in project.kite 
    with shell commands to "make build" and "make clean".

What does Mars need that Kite doesn't yet offer?

* Building of documentation
* Building of "make" targets
  * E.g., C libs
* Teapot packaging of libs.
  * Pulling "require" dependencies into teapot.txt.
  * Install to local teapot
  * Install to kite server
* "kite clean"
* Version tagging
* Install to home page/kite server


What does Athena need that Kite doesn't yet offer?

* Building of documentation
* "athena_test", which has needs beyond what [kite test] currently gives.
* "kite clean"
* Version tagging
* Make tarballs
* Make installer
* Install to home page

