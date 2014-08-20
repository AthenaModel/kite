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
    usage       {0 - "?<name>...?"}
    ensemble    compiletool
    description "Compile \"src\" directories"
    intree      yes
}

set ::khelp(compile) {
    The 'kite compile' tool compiles the contents of the project's 
    "src" directories, as defined by the "src" statement in 
    project.kite.  By default, all such directories are compiled.  
    Alternatively, the user may specify a list of names.  Note that
    directories are always compiled in the order in which they are
    defined in project.kite.

    For example, to compile the contents of the <root>/src/fred and
    <root>/src/george directories,

        $ kite compile fred george

    See the discussion of the "src" statement in the project(5) manpage
    for more information.
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
        if {[llength $argv] > 0} {
            foreach name $argv {
                if {$name ni [project src names]} {
                    throw FATAL "Unknown src directory: \"$name\""
                }
            }
            set toCompile $argv
        } else {
            set toCompile [project src names]
        }

        foreach name [project src names] {
            if {$name ni $toCompile} {
                continue
            }

            set dir [project root src $name]

            puts ""
            puts [string repeat - 75]
            puts "Making: src/$name"
            puts ""
            ExecuteScript $dir [project src build $name]
        }
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
            throw FATAL "Error making: $dir"
        }   
    }

    #-------------------------------------------------------------------
    # Clean Up

    # clean
    #
    # Cleans all compiled build products.

    typemethod clean {} {
        if {![got [project src names]]} {
            return
        }
        puts "Cleaning src directories..." 
        foreach name [project src names] {
            set dir [project root src $name]

            puts ""
            puts [string repeat - 75]
            puts "Cleaning: src/$name"
            puts ""
            ExecuteScript $dir [project src clean $name]
        }
       
    }
    
}






