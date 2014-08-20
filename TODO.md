# Project TODO List

## Next

* Improve 'kite add': options on additions, e.g., private libraries.
  * Options:
    * -private: Private library, not "provided".
    * -notest: Library has no test suite 
  * Constraints:
    * Can't add app if loader script or lib/nameapp already exists.
    * Can't add library if lib/name already exists.

## Notes

* Default teapot:
  * Making ~/.kite/teapot the default teapot means that
    different users are in contention.
  * Perhaps I should just make sure it's linked, and build
    against it.
  * Send note to Andreas: per-user teapots and links.
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
* As time permits/when needed
  * kite retest
    * Execute only tests that failed last time.
* User testing needed
  * Test on Linux
* To ponder
  * Consider using basekits from teapot.

# Remaining Gaps #

## For Mars

* Install code/docs to home page/kite server?

## For Athena

* "athena_test", which has needs beyond what [kite test] currently gives.
* Install to Athena home page


