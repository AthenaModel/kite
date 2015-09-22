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
    <root>/test/<target>/all_tests.test.

    kite test
        Executes tests for all targets, and summarizes the results.
        To see the entire test log, enter 'kite -verbose test'.

    kite test <target> ?<option>...?
        Executes all tests for the named target; i.e., all tests in
        <root>/test/<target>.  Any options are passed along to tcltest(n).

    kite test <target> <module> ?<option>...?
        Executes all tests for the given module within the given target,
        i.e., <root>/test/<target>/<module>.test.  Any options are passed
        along to tcltest(n).

    For example,

    $ kite test                           - Runs all tests.
    $ kite test mylib                     - Runs tests for mylib(n)
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
        set arglist [list]
        set opts    [list]

        # FIRST, separate args from options
        foreach arg $argv {
            if {[string match "-*" $arg]} {
                lappend opts $arg
            } else {
                lappend arglist $arg
            }
        }

        # NEXT, extract target and module from arglist
        set target [GetTarget $arglist]
        set module [GetModule $arglist]

        if {$target ne ""} {
            TestTarget -verbose $target $module $opts 
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
            TestTarget -brief [file tail $dir] "" $opts 
        }

        puts ""
        puts "Use 'kite -verbose test' to see the full output,"
        puts "or view <root>/.kite/test.log."
    }

    # GetTarget arglist
    #
    # arglist   - a list of target/module, possibly
    #
    # This proc attempts to determine the target for the tests from the
    # contents of the arguments.  There are three possiblities:
    #
    #    * Empty list   - return empty string
    #    * One element  - if it's a test module, figure out target from it 
    #    * Two elements - the first element is the requested target 
    #
    # There is no error checking, that is done later downstream by the 
    # routine that attempts to actually perform the test. 

    proc GetTarget {arglist} {
        # FIRST, if nothing specified nothing to return
        if {[llength $arglist] == 0} {
            return ""
        }

        # NEXT, if there's two args, the first is the target, it'll get 
        # error checked later
        if {[llength $arglist] == 2} {
            return [lindex $arglist 0]
        }

        # NEXT, see if the arg is test target or test module
        set name [lindex $arglist 0]

        set testdir [project root test $name]
        if {[file isdirectory $testdir]} {
            return $name
        }

        # NEXT, if it is a test file determine the target from it's location
        if {[file extension $name] ne ".test"} {
            set name $name.test
        }

        # NEXT, go through test dirs in the project looking for the file
        set testDirs [glob -nocomplain [project root test *]]

        foreach dir $testDirs {
            # Skip any stray files
            if {![file isdirectory $dir]} {
                continue
            }

            if {[file isfile [file join $dir $name]]} {
                return [file tail $dir] 
            } 
        }

        # NEXT, could not find any targets for specified module 
        throw FATAL "Could not find valid test target for module: \"$name\""
    }

    # GetModule  arglist
    #
    # arglist   A list of target/module possibly
    #
    # This proc extracts the requested test module from a list of arguments.
    # There are three possiblities:
    #
    #    * Empty list   - return empty string
    #    * One element  - if it is a file that exists with ".test" as the
    #                     extention, it is the module
    #    * Two elements - it is the second element

    proc GetModule {arglist} {
        # FIRST, if nothing specified nothing to return
        if {[llength $arglist] == 0} {
            return ""
        }

        # NEXT, if there's two args the second is the module 
        if {[llength $arglist] == 2} {
            return [lindex $arglist 1]
        }

        # NEXT, the first arg may be a test module 
        set module [lindex $arglist 0]

        if {[file extension $module] ne ".test"} {
            set module $module.test
        }

        if {[file isfile [file join [pwd] $module]]} {
            return [lindex $arglist 0]
        }

        return ""
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






