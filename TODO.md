# Project TODO List

## Next

* Cleanup:
  * Add "env" tool.
  * Flesh out the plat.tcl module.
    * tool::SHELL should use plat to find tkcon.
  * Update help subsystem to support tree of topics.
  * Use smartinterp for parsing project.kite.
  * Add a module for calling execute commands against known helpers, with
    options for logging.
  * project dump: use lmaxlen.
  * Work through code, looking for things to improve.
  * Pull "knowledge" into specific spots.
  * Better os/env support.
  * Rationalize "project" queries.
* Support for pulling external documents into the project tree for
  making distributions.
  * Could use a src directory, plus 'curl'
  * Or direct support.
* Improve 'kite add': options on additions, e.g., private libraries.
  * Options:
    * -private: Private library, not "provided".
    * -notest: Library has no test suite 
  * Constraints:
    * Can't add app if loader script or lib/nameapp already exists.
    * Can't add library if lib/name already exists.
* Testing of kiteapp modules.
  * Split between UI modules (e.g., <name>tool.tcl) and implementation
    modules (e.g., tool.tcl).
  * Can test each.
* Plug-in architecture.
  * A plugin defines a new tool.
  * It provides help, calling info, and so forth.
    * Provide cleaner interface for existing tools.
  * Can access "project" API, which will have to be documented.
  * Provide clean "project" API.
    * Pass project object into plugins?

## Notes

* Can create teapot zips directly, using zipfile::encode.
* Default teapot:
  * Making ~/.kite/teapot the default teapot means that
    different users are in contention.
  * Perhaps I should just make sure it's linked, and build
    against it.
* Test suites
  * kitedoc(n)
  * manpage(n)
* When new athena/kite web server is available
  * Support for "external documents"
    * MS Office documents and similar will reside on a separate web server;
      we'll update it as we change them.
    * project.kite will have an "xdoc" statement:
      * xdoc mag.docx http://...../mag3.5.docx
    * External docs can be pulled in using a kite command, so that they
      can be included in a build.
  * "Kite server" for locally built packages
* To ponder
  * Consider using basekits from teapot.

# Remaining Gaps #

## For Mars

* Install code/docs to home page/kite server?

## For Athena

* "athena_test", which has needs beyond what [kite test] currently gives.
* Install to Athena home page


