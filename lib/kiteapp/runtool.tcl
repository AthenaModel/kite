#-----------------------------------------------------------------------
# TITLE:
#   runtool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "run" tool.  By default, this invokes the app/appkit's 
#   loader script.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(run) {
    arglist     {}
    package     kiteapp
    ensemble    ::kiteapp::runtool
    description "Run application"
    intree      yes
}

set ::khelp(run) {
    The "run" tool executes the user's app or appkit, i.e., it invokes
    the ./bin/<app>.tcl file, passing it any command line
    arguments.
}

#-----------------------------------------------------------------------
# runtool ensemble

snit::type ::kiteapp::runtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments, which are
    # passed along to the user's application.

    typemethod execute {argv} {
        # FIRST, is there an app/appkit?
        set script [project app loader]

        if {$script eq ""} {
            throw FATAL "The project.kite file doesn't define an application."
        }

        # NEXT, set up the library path.
        set ::env(TCLLIBPATH) [project libpath]

        # NEXT, set up the rest of command.
        lappend command \
            tclsh [project app loader] {*}$argv \
            >@ stdout 2>@ stderr

        # NEXT, execute it in the project root, in the background,
        # and exit.
        vputs "Executing <$command>"
        
        cd [project root]
        eval exec $command
    }    
}





