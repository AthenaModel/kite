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
    package     ktools
    ensemble    ::ktools::teapottool
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

    To create the teapot if it's missing, or to link an existing 
    teapot to the current tclsh,

        $ kite teapot create

    On Linux and OS X, it may be necessary to use sudo:

        $ sudo kite teapot create

    To remove the local teapot, delete ~/.kite/teapot by hand.
}


#-----------------------------------------------------------------------
# tool::info ensemble

snit::type ::ktools::teapottool {
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

        set sub [lshift argv]

        if {$sub eq "create"} {
            teacup teapot create
        } else {
            teacup teapot status
        }

        puts ""
    }    
}



