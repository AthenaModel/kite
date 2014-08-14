#-----------------------------------------------------------------------
# TITLE:
#   infotool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "info" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(info) {
    arglist     {}
    package     kiteapp
    ensemble    infotool
    description "Display information about Kite and this project."
    intree      yes
}

set ::khelp(info) {
    The "info" tool displays information about the current project
    in human readable format.  Most of the information is from the 
    project.kite file.  In addition, the tool can return individual
    pieces of data given an option; this is useful in Makefiles and
    other scripts.

    The available options are as follows:

    -os        - The OS on which Kite is running: "linux", "osx", or 
                 "windows".
    -root      - The project root directory (i.e., the directory containing
                 the project.kite file).
    -tclhome   - The root of the TCL installation tree.
    -version   - The project version number.
}


#-----------------------------------------------------------------------
# tool::info ensemble

snit::type infotool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays information about Kite and the current project
    # given the command line.

    typemethod execute {argv} {
        checkargs info 0 1 {?option?} $argv

        set opt [lindex $argv 0]

        # FIRST, handle the default case.
        if {$opt eq ""} {
            project dumpinfo

            puts ""
            return            
        }

        # NEXT, handle the option.
        switch -exact -- $opt {
            -os      { set result [plat id]                        }
            -root    { set result [project root]                   }
            -tclhome { set result [plat pathof tclhome]            }
            -version { set result [project version]                }
            default  { throw FATAL "Unknown info option: \"$opt\"" }
        }

        puts $result
    }    
}






