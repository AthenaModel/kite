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

    kite teapot create
        Creates the teapot at ~/.kite/teapot, if it doesn't already exist,
        and makes it the "default" teapot.

    kite teapot link
        Links the local teapot to the user's tclsh, so that it will load
        packages from the teapot automatically.

        On Linux and OS X, it may be necessary to use sudo with this command:

            $ sudo -E kite teapot link

    kite teapot list
        Displays the content of the local teapot.

    kite teapot remove
        Removes ~/.kite/teapot. Removing the local teapot may cause your 
        Kite projects to be unable to find their external dependencies.  

        Because this command unlinks the tclsh from the teapot, you may need
        to use 'sudo' on Linux or OS X, just as for 'kite teapot link'.
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
            create  { teapot create }
            link    { teapot link   }
            list    { DisplayList   }
            remove  { teapot remove }
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
                puts "'kite teapot create' to do so.  See 'kite help teapot'"
                puts "for details."
            }

            non-default {
                puts "Kite's local teapot isn't the default installation"
                puts "teapot.  Please use 'kite teapot create' to make it"
                puts "so.  See 'kite help teapot' for details."
            }

            unlinked {
                puts "Kite's local teapot isn't linked to the development"
                puts "tclsh.  Please use 'kite teapot link' to do so."
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
        table puts [teacup list --at-default] -headers 
    }
}






