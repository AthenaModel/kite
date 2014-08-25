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
    # tclsh commands

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

}

