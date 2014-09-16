# Project TODO List

## Next

* Define a macroset(i) interface.
  * Add macro(n) to kiteutils
  * Add ehtmlset(n) to kitedocs
  * Make kitedoc(n) use ehtmlset(n).
  * Make manpage(n) use ehtmlset(n).
  * Remove ehtml(n)
  * Rename ehtmlset(n) to ehtml(n)
  * Add <tag>, <xtag> to ehtml(n).
  * Move relevant macrosets to ehtml(n), for sharing.
  * Clean-up CSS.
  * Revise manpages:
    * ehtml(n)
    * macro(5)
    * ehtml(5)
    * kitedoc(5)
    * manpage(5)
  * Then, define a kite macroset, loaded by 'kite docs', that defines
    "withlib" and similar tools.


* Add %install target to dist; includes an installation script
  * a list of bash commands.
* Clean up "kite new" syntax.  
  * In particular, provide option for description.

* Test suite for table(n).
* Cleanup:
  * Define a notion of ehtml(n) macro sets.
  * Compare docs.tcl with tool_docs.tcl and make sure there's a clean
    division.
    * Add a call to docs.tcl indicating whether there are documents
      that will be processed.
    * Probably should support arbitrary depths.
  * Update help subsystem to support tree of topics.
  * Use smartinterp for parsing project.kite.
  * Work through code, looking for things to improve.
  * Pull "knowledge" into specific spots.
  * Rationalize "project" queries.
* Cross-platform builds
  * Need to manage Tcl version.
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

* Test suites
  * kitedoc(n)
  * manpage(n)
* To ponder
  * Consider using basekits from teapot.

# Remaining Gaps #

## For Athena

* "athena_test", which has needs beyond what [kite test] currently gives.


