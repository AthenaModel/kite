#-----------------------------------------------------------------------
# TITLE:
#   tool_test.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "test" tool.  This tool knows how to run the project test suite.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::TEST

tool define test {
    usage       {0 - "?<target> ?<module>?? ?<option>...?"}
    description "Runs some or all of the project test suite."
    needstree      yes
} {
    This tool executes some or all of the project's test suite.  The
    test suite consists of a number of "targets", each of which has a
    its own test subdirectory "<root>/test/<target>".  Kite assumes that 
    the target has a top-level tcltest(n) test script called 
    <root>/test/<target>/all_tests.test.   Individual test modules within
    a target can be executed without specifying the target.

    kite test
        Executes tests for all targets, and summarizes the results.
        To see the entire test log, enter 'kite -verbose test'.

    kite test <target> ?<option>...?
        Executes all tests for the named target; i.e., all tests in
        <root>/test/<target>.  Any options are passed along to tcltest(n).
    
    kite test <module>.test ?<option>...?
        Executes the tests found in the named test module in the current
        directory.

    kite test <target> <module>.test ?<option>...?
        Executes all tests for the given module within the given target,
        i.e., <root>/test/<target>/<module>.test.  The .test extension may
        be left off the module name.  Any options are passed along to 
        tcltest(n).

    For example,

    $ kite test                           - Runs all tests.
    $ kite test mylib                     - Runs tests for mylib(n)
    $ kite test mymodule.test             - Runs mymodule.test in current dir
    $ kite test mylib mymodule            - Runs mylib/mymodule.test
    $ kite test mylib -match mytest-1.*   - Runs tests matching a pattern
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        set target ""
        set module ""

        if {![string match "-*" [lindex $argv 0]]} {
            set target [lshift argv]

            if {[file extension $target] eq ".test"} {
                set module $target
                set target [FindTarget $module] 
            } elseif {![string match "-*" [lindex $argv 0]]} {
                set module [lshift argv]
            }
        }

        if {$target ne ""} {
            TestTarget -verbose $target $module $argv 
            return
        } 

        set testDirs [glob -nocomplain [project root test *]]

        if {[llength $testDirs] == 0} {
            throw FATAL "No test targets were found."
        }

        puts "Running all tests..."
        writefile [TestFile] ""

        foreach dir $testDirs {
            # Skip any stray files
            if {![file isdirectory $dir]} {
                continue
            }
            TestTarget -brief [file tail $dir] "" $argv 
        }

        puts ""
        puts "Use 'kite -verbose test' to see the full output,"
        puts "or view <root>/.kite/test.log."
    }

    # FindTarget module
    #
    # module  - a ".test" module 
    #
    # Returns a test module's parent directory, provided that the test module
    # exists.  Throws an error for a non-existent test module.

    proc FindTarget {module} {
        # FIRST, use the module to determine the target.  If the test file
        # does not exist, an error is thrown.
        set filepath [file normalize [file join [pwd] $module]]

        if {![file isfile $filepath]} {
            throw FATAL "Could not find valid test target for module: \"$module\""
        }

        return [file tail [pwd]]
    }

    # TestFile
    #
    # Returns the name of the test log file.

    proc TestFile {} {
        return [project root .kite test.log]
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
        set verbose [expr {$bopt eq "-verbose" || $::app_kite::verbose}]

        # NEXT, get the script to execute.
        if {$module eq ""} {
            set module "all_tests"
        }

        # NEXT if module is specified and does not have ".test" extension, 
        # add it.
        if {[file extension $module] ne ".test"} {
            set module $module.test
        }

        set testfile [file join $testdir $module]

        if {![file isfile $testfile]} {
            if {$module eq "all_tests.test"} {
                puts [normalize "
                    WARNING: skipping test directory \"$target\": 
                    no \"all_tests.test\" file.
                "]
                return
            } else {
                throw FATAL "Cannot find \"$module\"."
            }
        }

        # NEXT, Run the tests
        cd $testdir

        try {
            if {$verbose} {
                set output [tclsh show $testfile {*}$optlist]
            } else {
                set output [tclsh call $testfile {*}$optlist]
                appendfile [TestFile] "\n$output"
            }
        } on error {result} {
            throw FATAL "Error running tests: $result"
        }

        # NEXT, show summary of results unless output was verbose.
        if {!$verbose} {
            lassign [ShowStats $target $output] errCount failCount

            if {$errCount > 0} {
                puts ""
                throw FATAL "Test file errors: $errCount"
            }

            if {$failCount > 0} {
                puts ""
                throw FATAL "Test failures: $failCount"
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
    # errors, not test failures.  Also counts the number of test failures.
    # Returns a list {errCount failCount}.

    proc ShowStats {target output} {
        set inError 0
        set errCount 0
        set failCount 0
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
                incr failCount [lindex $pieces 1 7]
                puts "$target: [lindex $pieces 1]"
            }
        }

        return [list $errCount $failCount]
    }
}






