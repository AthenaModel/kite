#-----------------------------------------------------------------------
# TITLE:
#   testtool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "test" tool.  This tool knows how to run the project test suite.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(test) {
    arglist     {?target module options...?}
    package     ktools
    ensemble    ::ktools::testtool
    description "Runs some or all of the project test suite."
    intree      yes
}

set ::khelp(test) {
    Usage: kite test ?target module options...?

    This tool executes some or all of the project's test suite.  The
    test suite consists of a number of "targets", each of which has a
    its own test subdirectory "<root>/test/<target>".  Usually there
    is one target for each package in "<root>/lib", plus one for the
    application (if any).  

    If no "target" is given, Kite executes tests for all targets; otherwise
    it runs the named target.  If "target" and "module" are both given,
    Kite runs the specific test module for the named target.  Any
    options are passed along to Tcltest. 

    Each target is presumed to have a top-level Tcltest script that
    runs all of the target's individual tests; it should be called
    "<root>/test/<target>/<target>.test".  

    For example,

    $ kite test                           - Runs all tests.
    $ kite test mylib                     - Runs tests for mylib(n)
    $ kite test mylib mymodule            - Runs mylib/mymodule.test
    $ kite test mylib -match mytest-1.*   - Runs tests matching a pattern
}


#-----------------------------------------------------------------------
# testtool ensemble

snit::type ::ktools::testtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs test 0 - {?target module options...?} $argv

        # Get target, if any, avoiding options
        if {![string match "-*" [lindex $argv 0]]} {
            set target [lshift argv]
        }

        # Get module, if any, avoiding options
        if {![string match "-*" [lindex $argv 0]]} {
            set module [lshift argv]
        }

        if {$target ne ""} {
            puts "Testing $target $module"
            TestTarget $target $module $argv
            return
        } 

        set testDirs [glob -nocomplain [project root test *]]

        if {[llength $testDirs] == 0} {
            throw FATAL "No test targets were found."
        }

        foreach dir $testDirs {
            # Skip any stray files
            if {![file isdirectory $dir]} {
                continue
            }
            TestTarget [file tail $dir] "" $argv
        }
    }
    
    # TestTarget target module optlist
    #
    # target   - A test target
    # module   - A module within that target, or ""
    # optlist  - Any Tcltest options
    #
    # Runs the tests for the given target.  If module is given, runs
    # only that module.

    proc TestTarget {target module optlist} {
        # FIRST, if there's no such test target, that's an error.
        set testdir [project root test $target]
        if {![file isdirectory $testdir]} {
            throw FATAL "\"$target\" is not a valid test target; see test/*."
        }

        # FIRST, get the script to execute.
        if {$module eq ""} {
            set module $target
        }

        set testfile [file join $testdir $module.test]

        if {![file isfile $testfile]} {
            throw FATAL "Cannot find \"$module.test\"."
        }

        # NEXT, set up the library path.
        set ::env(TCLLIBPATH) [project libpath]

        # NEXT, set up the command.
        lappend command \
            tclsh $testfile {*}$optlist \
                >@ stdout 2>@ stderr

        cd $testdir
        eval exec $command
    }
}



