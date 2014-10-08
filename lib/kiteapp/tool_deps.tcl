#-----------------------------------------------------------------------
# TITLE:
#   tool_deps.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "deps" tool.  This tool reports on the state of the project
#   dependencies, and can update them.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::DEPS

tool define deps {
    usage       {0 2 "?update? ?<name>?"}
    description "Manage project dependencies"
    needstree      yes
} {
    The 'kite deps' tool manages the project's external dependencies.  
    There are two kinds of dependencies.  External "require" dependencies 
    are retrieved from teapot.activestate.com; and placed in the local
    teapot repository; locally-built "require" dependencies are tracked
    but not retrieved.

    kite deps
        Get the status of all dependencies.

    kite deps update
        Retrieve dependencies are are missing or are clearly out of date.

    kite deps update <name>
        Forces a fresh retrieval of the named dependency.

    When Kite fails to install a required teapot package,
    see the <project>/.kite/install_<package>.log file for details.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        # FIRST, if there are no arguments then just dump the dependency
        # status.
        set subc [lshift argv]

        if {$subc eq ""} {
            DisplayStatus
        } elseif {$subc eq "update"} {
            deps update [lshift argv]
        } else {
            throw FATAL "Unknown subcommand: \"$subc\""
        }

        puts ""
    }
    
    # DisplayStatus
    #
    # Displays the status of the project dependencies.

    proc DisplayStatus {} {
        # FIRST, is this even relevant?
        if {[llength [project require names]] == 0} {
            puts "The project has no required packages.\n"
            return
        }

        # NEXT, build the table.
        set table [list]
        set gotLocal 0

        foreach name [project require names] {
            set row [dict create]
            set version [project require version $name]

            dict set row nv "$name $version"

            if {[deps has $name $version]} {
                dict set row status "OK"
            } elseif {[project require islocal $name]} {
                dict set row status "Out-of-date, Local"
                set gotLocal 1
            } else {
                dict set row status "Out-of-date"
                set gotExtern 1
            }

            lappend table $row
        }

        puts "Required Package Status:\n"

        dictab puts $table -indent "   "

        puts "\nTo retrieve out-of-date or missing dependencies, use"
        puts "\"kite deps update\".  To force an update of a particular"
        puts "dependency, use \"kite deps update <name>\"."

        if {$gotLocal} {
            puts ""
            puts "At least one out-of-date dependency is locally built,"
            puts "and must be installed into the local teapot by the"
            puts "developer."
        }
    }
}






