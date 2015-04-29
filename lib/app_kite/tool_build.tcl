#-----------------------------------------------------------------------
# TITLE:
#   tool_build.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "build" tool.  This command builds the entire project, from
#   beginning to end.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::BUILD

tool define build {
    usage       {0 0 ""}
    description "Build the entire project."
    needstree   yes
} {
    The 'kite build' tool does a complete build of the project as defined
    in the project's project.kite file.  In particular, it is equivalent
    to:

        kite compile
        kite test
        kite docs
        kite wrap
        kite dist

    This command will halt if the external dependencies are not 
    up to date, or if an error occurs at any step of the process.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        # FIRST, check for dependencies.
        puts "Checking external dependencies..."
        set upToDate [deps uptodate]

        if {$upToDate} {
            puts "All external dependencies are up to date."
            puts ""
        } else {
            puts "WARNING: Some dependencies are not up-to-date."
            puts "Run \"kite deps\" for details."
            puts ""

            throw FATAL [outdent {
                Please resolve the out-of-date dependencies before
                using 'kite build all'
            }]
        }

        # NEXT, build everything, halting on any error.
        if {[got [project xfile paths]]} {
            header "Retrieving External Files"
            tool use xfiles {update all}
        }

        if {[got [project src names]]} {
            header "Compiling src directories"
            tool use compile
        }

        if {[got [project globdirs test *]]} {
            header "Running project tests."
            tool use test
        }

        if {[got [project globfiles docs *.ehtml]]     ||
            [got [project globfiles docs * *.ehtml]]   ||
            [got [project globfiles docs * * *.ehtml]]
        } {
            header "Building project documentation"
            tool use docs
        }

        if {[got [concat [project provide names] [project app names]]]} {
            header "Wrapping libraries and applications"
            tool use wrap
        }
            
        if {[got [project dist names]]} {
            header "Building distributions"
            tool use dist
        }
    }
    
    # header text
    #
    # text   - header text string
    #
    # Outputs a header.

    proc header {text} {
        puts ""
        puts [string repeat = 75]
        puts $text
        puts ""
    }

}






