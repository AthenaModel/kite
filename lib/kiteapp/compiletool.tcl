#-----------------------------------------------------------------------
# TITLE:
#   compiletool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "compile" tool.  This compiles the project's make targets.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(compile) {
    arglist     {}
    package     kiteapp
    ensemble    compiletool
    description "Compile make directories"
    intree      yes
}

set ::khelp(compile) {
    The "compile" tool is experimental.
}

#-----------------------------------------------------------------------
# compiletool ensemble

snit::type compiletool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs compile 0 0 {} $argv

        # FIRST, set up environment
        SetUpProjectEnvironment


        # TODO: Build make targets
        foreach path [project make paths] {
            set dir [project root $path]

            puts "Making: $path"
            ExecuteScript $dir [project make cleanscript $path]
            ExecuteScript $dir [project make allscript $path]
        }
    }

    # SetUpProjectEnvironment
    #
    # Adds environment variables for use by Makefiles or other 
    # scripts.

    proc SetUpProjectEnvironment {} {
        set ::env(KITE_PROJECT_ROOT) [project root]
        set ::env(KITE_OS)           [plat id]
    }

    # ExecuteScript dir script
    #
    # dir     - The directory in which to execute it.
    # script  - A script of shell commands.
    #
    # Executes the commands one at a time, throwing FATAL on error.

    proc ExecuteScript {dir script} {
        foreach command [split $script \n] {
            if {[string trim $command] eq ""} {
                continue
            }

            ExecuteCommand $dir $command
        }
    }

    # ExecuteCommand dir command
    #
    # dir     - The directory in which to execute it
    # command - The command to execute.
    #
    # Executes the command in the directory, throwing FATAL
    # on error.

    proc ExecuteCommand {dir command} {
        cd $dir
        puts "$command"
        try {
            exec {*}$command >@ stdout 2>@ stderr 
        } on error {result} {
            throw FATAL "Error making: $path"
        }   
    }
}






