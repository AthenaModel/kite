# Project TODO List

* Write test for kutils::interdict
* Test on Linux:
  * Install TDK
  * Build appkit
  * Build app
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
  * In project.kite:
    * make src/libFoo

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
* Ability to create .zip archives.

