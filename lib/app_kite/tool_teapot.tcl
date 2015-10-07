#-----------------------------------------------------------------------
# TITLE:
#   tool_teapot.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "teapot" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::TEAPOT

tool define teapot {
    usage       {0 1 "?create|link|list|remove?"}
    description "Create local teapot for Kite projects."
    needstree      no
} {
    The 'kite teapot' tool creates a local teapot repository in 
    ~/.kite/teapot to contain required teapot packages for Kite
    projects.  This is so that we do not need to use 'sudo' when
    updating required packages on Linux and OS X.

    In addition to creating the repository, the tool also links it
    to the current tclsh.

    kite teapot
        Display the status of the local teapot.  If there are problems,
        Kite will give directions for how to fix them.

    kite teapot fix
        Creates a local teapot at ~/.kite/teapot, if it doesn't already 
        exist, and outputs a script or batch file to make it the 
        "default" teapot.  This script usually requires "admin" or 
        "root" privileges; on Linux or OS X, it is generally run using 
        'sudo'. 

    kite teapot list
        Displays the content of the local teapot.
} {
    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays information about Kite and the current project
    # given the command line.

    typemethod execute {argv} {
        set sub [lindex $argv 0]

        switch -exact -- $sub {
            ""      { DisplayStatus }
            fix     { teapot fix    }
            list    { DisplayList   }
            default { throw FATAL "Unknown subcommand: \"$sub\""}
        }

        puts ""
    }    


    # DisplayStatus
    #
    # Displays the status of the local teapot.

    proc DisplayStatus {} {
        set state [teapot state]

        # TODO: Maybe should be [plat pathof teapot]
        puts "Local teapot: [teapot local]\n"

        switch -exact -- $state {
            missing {
                puts "Kite hasn't yet created its local teapot. Please use"
                puts "'kite teapot fix' to do so.  See 'kite help teapot'"
                puts "for details."
            }

            non-default {
                puts "Kite's local teapot isn't the default installation"
                puts "teapot.  Please use 'kite teapot fix' to make it"
                puts "so.  See 'kite help teapot' for details."
            }

            unlinked {
                puts "Kite's local teapot isn't linked to the development"
                puts "tclsh.  Please use 'kite teapot fix' to do so."
                puts "See 'kite help teapot' for details."
            }

            ok {
                puts "Kite's local teapot is ready for use."
            }

            default {
                error "Unknown teapot state: \"$state\""
            }
        }
    }

    # DisplayList
    #
    # List the packages contained in the local teapot.

    proc DisplayList {} {
        dictab puts [teacup list --at-default] -headers 
    }
}






