#-----------------------------------------------------------------------
# TITLE:
#   teapottool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: "teapot" tool
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(teapot) {
    usage       {0 1 "?create|link|remove?"}
    ensemble    teapottool
    description "Create local teapot for Kite projects."
    intree      no
}

set ::khelp(teapot) {
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

    kite teapot remove
        Removes ~/.kite/teapot. Removing the local teapot may cause your 
        Kite projects to be unable to find their external dependencies.  

        Because this command unlinks the tclsh from the teapot, you may need
        to use 'sudo' on Linux or OS X, just as for 'kite teapot link'.
}


#-----------------------------------------------------------------------
# tool::info ensemble

snit::type teapottool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays information about Kite and the current project
    # given the command line.

    typemethod execute {argv} {
        set sub [lindex $argv 0]

        switch -exact -- $sub {
            ""      { teapot status }
            create  { teapot create }
            link    { teapot link   }
            remove  { teapot remove }
            default { throw FATAL "Unknown subcommand: \"$sub\""}
        }

        puts ""
    }    
}






