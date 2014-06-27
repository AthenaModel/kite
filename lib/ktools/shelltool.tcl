#-----------------------------------------------------------------------
# TITLE:
#   shelltool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "shell" tool.  By default, this invokes tkcon with the project
#   code.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(shell) {
    arglist     {}
    package     ktools
    ensemble    ::ktools::shelltool
    description "Open interactive Tcl shell"
    intree      yes
}

set ::khelp(shell) {
    The "shell" tool opens an interactive Tcl shell (tkcon) on the 
    project codebase.  If there is an app or appkit, the app's 
    loader script (e.g., bin/myapp.tcl) is loaded in interactive mode
    (the "main" is not called).  

    If there is no appkit, or if the "-plain" option is given, Kite simply 
    adds the project library directories to the auto_path.  In this case,
    the initial state of the shell can be further customized using the
    "shell" statement in the project.kite file.
}

#-----------------------------------------------------------------------
# shelltool ensemble

snit::type ::ktools::shelltool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs shell 0 1 {?-plain?} $argv
        set opt [lindex $argv 0]

        # FIRST, locate tkcon.
        set shellapp [FindTkCon]

        # NEXT, set up the rest of command.
        set command $shellapp

        if {[project apploader] ne "" && $opt ne "-plain"} {
            lappend command [project apploader]
        } else {
            set script [WriteShellInitializer]
            lappend command $script
        }

        lappend command &


        # NEXT, execute it in the project root, in the background,
        # and exit.
        vputs "Loading <$command>"
        cd [project root]
        eval exec $command
    }

    # FindTkCon
    #
    # Finds the tkcon app.
    #
    # NOTE: It appears that tkcon is only installed with ActiveTcl on
    # Windows, and so it isn't readily available.  For now I'll look
    # for it in the environment, but ultimately a shell will need to
    # be part of Kite.

    proc FindTkCon {} {
        set app [exec which tkcon]
        if {[file exists $app]} {
            return $app
        }

        set app [exec which tkcon.tcl]

        if {[file exists $app]} {
            return $app
        }

        throw FATAL "Please install the \"tkcon\" shell application."
    }
    
    # WriteShellInitializer
    #
    # Creates .kite/shell.tcl to set up auto_path.

    proc WriteShellInitializer {} {
        # FIRST, add the project's own libraries to the auto_path.
        append out \
            "# shell.tcl -- Kite shell initialization script\n" \
            "lappend auto_path [list [project root lib]]\n"

        # NEXT, add any include libraries to the auto_path
        foreach include [project include names] {
            set lib [project root includes $include lib]
            append out \
                "lappend auto_path [list $lib]\n"
        }

        # NEXT, add any "shell" script from project.kite
        append out "\n" [project shell] "\n"

        set script [project root .kite shell.tcl]
        writefile $script $out

        return $script
    }
    
}



