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
    arglist     {}
    package     kiteapp
    ensemble    ::kiteapp::teapottool
    description "Create local teapot for Kite projects."
    intree      no
}

set ::khelp(teapot) {
    The "teapot" tool creates a local teapot repository in 
    ~/.kite/teapot to contain required teapot packages for Kite
    projects.  This is so that we do not need to use "sudo" when
    updating required packages on Linux and OS X.

    In addition to creating the repository, the tool also links it
    to the current tclsh.

    To see the status of the local teapot,

        $ kite teapot

    To create the teapot and make it the default teapot,

        $ kite teapot create

    To link the teapot to your tclsh,

        $ kite teapot link

    On Linux and OS X, it may be necessary to use sudo to link your
    tclsh to the local teapot.

        $ sudo -E kite teapot link

    Removing the local teapot may cause your Kite projects to be unable
    to find their external dependencies.  However, should you need to
    do so, you can do this:

        $ kite teapot remove

    Because this command unlinks the tclsh from the teapot, you may need
    to use sudo on Linux or OS X, just as for "teapot link".
}


#-----------------------------------------------------------------------
# tool::info ensemble

snit::type ::kiteapp::teapottool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution

    # execute argv
    #
    # Displays information about Kite and the current project
    # given the command line.

    typemethod execute {argv} {
        checkargs teapot 0 1 {?create?} $argv

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





