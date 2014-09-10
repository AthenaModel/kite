#-----------------------------------------------------------------------
# TITLE:
#   tclsh.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kiteapp(n) tclsh proxy.  This module provides a proxy interface
#   to the tclsh executable, calling the tclsh safely and with the project's
#   context.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tclsh ensemble

snit::type tclsh {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Constants

    # blockCommand: a command that executes a script in the global
    # context and outputs the result to stdout.

    typevariable blockCommand {
        proc _outputBlock_ {script} {
            puts [uplevel #0 $script]
        }
    }
    

    #-------------------------------------------------------------------
    # tclsh commands

    # auto_path
    #
    # Returns the auto_path of the development Tcl shell in the project
    # context.

    typemethod auto_path {} {
        return [$type script {
            set auto_path
        }]
    }



    # show args
    #
    # Calls the tclsh executable with the args, throwing a fatal
    # error if tclsh cannot be found.  stdout and stderr
    # are output to the console.  Script errors propagate normally.

    typemethod show {args} {
        set ::env(TCLLIBPATH) [project libpath]
        set tclsh [plat pathto tclsh -required]
        return [exec $tclsh {*}$args >@ stdout 2>@ stderr]
    }

    # call args
    #
    # Calls the tclsh executable with the args, throwing a fatal
    # error if tclsh cannot be found.  stdout and stderr
    # are both returned.  Script errors propagate normally.

    typemethod call {args} {
        set ::env(TCLLIBPATH) [project libpath]
        set tclsh [plat pathto tclsh -required]
        return [exec $tclsh {*}$args 2>@1]
    }

    # script script
    #
    # script   - A Tcl script
    #
    # Executes the Tcl script in the context of the project, and
    # returns all output.  Errors propagate normally.

    typemethod script {script} {
        assert {[project intree]}

        # FIRST, run in project root folder.
        set chdir [list cd [project root]]

        append realScript \
            $chdir                      \n \
            $blockCommand               \n \
            [list _outputBlock_ $script] \n


        # NEXT, save the script.
        set sname [project root .kite tclscript.tcl]
        writefile $sname $realScript

        # NEXT, call it and return the result.
        return [$type call $sname]
    }

}

