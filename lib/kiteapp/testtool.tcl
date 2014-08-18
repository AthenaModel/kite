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
    package     kiteapp
    ensemble    testtool
    description "Runs some or all of the project test suite."
    usage       {?<target> ?<module>?? ?<option>...?}
    intree      yes
}

set ::khelp(test) {
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

snit::type testtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs test 0 - $argv

        set target ""
        set module ""

        # Get target, if any, avoiding options
        if {![string match "-*" [lindex $argv 0]]} {
            set target [lshift argv]
        }

        # Get module, if any, avoiding options
        if {![string match "-*" [lindex $argv 0]]} {
            set module [lshift argv]
        }

        puts "Tcltest options: $argv"

        if {$target ne ""} {
            puts "Testing $target $module"
            TestTarget -verbose $target $module $argv
            return
        } 

        set testDirs [glob -nocomplain [project root test *]]

        if {[llength $testDirs] == 0} {
            throw FATAL "No test targets were found."
        }

        puts "Running all tests..."
        foreach dir $testDirs {
            # Skip any stray files
            if {![file isdirectory $dir]} {
                continue
            }
            TestTarget -brief [file tail $dir] "" $argv
        }

        puts ""
        puts "Use 'kite -verbose test' to see the full output,"
        puts "or 'kite test <dir>' for a specific test directory."
    }
    
    # TestTarget -brief|-verbose target module optlist
    #
    # bopt     - -brief|-verbose
    # target   - A test target
    # module   - A module within that target, or ""
    # optlist  - Any Tcltest options
    #
    # Runs the tests for the given target.  If module is given, runs
    # only that module.

    proc TestTarget {bopt target module optlist} {
        # FIRST, if there's no such test target, that's an error.
        set testdir [project root test $target]
        if {![file isdirectory $testdir]} {
            throw FATAL "\"$target\" is not a valid test target; see test/*."
        }

        # NEXT, get the verbosity
        set verbose [expr {$bopt eq "-verbose" || $::kiteapp::verbose}]

        # NEXT, get the script to execute.
        if {$module eq ""} {
            set module "all_tests"
        }
        set testfile [file join $testdir $module.test]

        if {![file isfile $testfile]} {
            throw FATAL "Cannot find \"$module.test\"."
        }

        # NEXT, set up the library path.
        set ::env(TCLLIBPATH) [project libpath]

        # NEXT, set up the command.
        lappend command \
            tclsh $testfile {*}$optlist

        if {$verbose} {
            lappend command \
                >@ stdout 2>@ stderr
        } else {
            lappend command \
                2>@1
        }

        cd $testdir
        try {
            # There won't be any output unless -brief is given
            set output [eval exec $command]
        } on error {result} {
            throw FATAL "Error running tests: $result"
        }

        if {!$verbose} {
            set errCount [ShowStats $target $output]

            if {$errCount > 0} {
                puts ""
                throw FATAL "Test file errors: $errCount"
            }
        }
    }

    # ShowStats target output
    #
    # target   - The test target
    # output   - The tcltest output
    #
    # Parses throught the test output and finds just the stats.  Returns
    # the number of Test file error blocks found; these represent runtime
    # errors, not test failures.

    proc ShowStats {target output} {
        set inError 0
        set errCount 0
        foreach line [split $output \n] {
            if {[string match "Test file error:*" $line]} {
                incr errCount
                set inError 1
            }

            if {$inError} {
                puts $line
                if {[regexp {^\s*\w+\.test\s*$} $line]} {
                    set inError 0
                }
            }

            if {[regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed} $line]} {
                set pieces [split $line :]
                puts "$target: [lindex $pieces 1]"
            }
        }

        return $errCount
    }
}






