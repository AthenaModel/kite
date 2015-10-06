#-----------------------------------------------------------------------
# TITLE:
#   teapot.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: app_kite(n) teapot module.  This module manages the local teapot,
#   ensuring that Kite can easily use it to access its external dependencies.
#
#   This module is responsible for the local teapot as a whole; see 
#   deps.tcl for code relating to a project's external dependencies.
#   Also, teacup.tcl is a proxy to the teacup.exe program.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# teapot ensemble

snit::type teapot {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    # local
    #
    # Returns the name of the local teapot Kite uses if the default
    # ActiveTcl teapot is read-only.

    typemethod local {} {
        return [file normalize [file join ~ .kite teapot]]
    }

    # fix
    #
    # Creates the Kite teapot, if need be, and does everything
    # else it can without requiring admin privileges.  Emits a 
    # script the user can execute that does the rest

    typemethod fix {} {
        # FIRST, if everything's OK there's nothing to be done.
        if {[$type state] eq "ok"} {
            puts "The local teapot appears to be in working order already."
            return
        }

        # NEXT, create the teapot if it doesn't exist.
        if {[$type state] eq "missing"} {
            puts "Creating teapot at [teapot local]..."
            teacup create [teapot local]
        }

        # NEXT, output the script.
        if {[os flavor] eq "windows"} {
            EmitBatchFile
        } else {
            EmitBashScript
        }
    }

    # EmitBatchFile
    #
    # Outputs the script for Windows users.

    proc EmitBatchFile {} {
        set filename [file join ~ .kite fixteapot.bat]

        puts [outdent "
            Kite has created a teapot repository in your home directory.
            It needs to be linked to the tclsh you are using; and it 
            appears that this will require admin privileges.  Kite is
            about to write a batch file that you (or someone who has
            admin privileges) can use to take care of this.

            The script is here:
                $filename

            Run it, and then run 'kite teapot' to check the results.
        "]

        writefile $filename [::teapot::FixTeapotBat]
    }

    # EmitBashScript
    #
    # Outputs the script for Windows users.

    proc EmitBashScript {} {
        set filename [file join ~ .kite fixteapot]

        if {[os username] eq ""} {
            throw FATAL [outdent "
                Kite cannot determined your user name; none of the usual
                environment variables are set.  Please set USER to your
                user name, and try again.
            "]
        }

        puts [outdent "
            Kite has created a teapot repository in your home directory.
            It needs to be linked to the tclsh you are using; and it 
            appears that this will require superuser privileges.  Kite is
            about to write a bash script that you (or someone who has
            superuser privileges) can use to take care of this.

            The script is here:
                $filename

            Run it, and then run 'kite teapot' to check the results.
        "]

        writefile $filename [::teapot::FixTeapotBash]
    }

    #-------------------------------------------------------------------
    # Determining the state of the local teapot.
    
    # state
    #
    # Verifies whether we have a Kite teapot or not.  Returns one 
    # of the following:
    #
    # ok          - Project teapot exists and is linked to tclsh
    # non-default - Project teapot isn't the default teapot.
    # unlinked    - Project teapot exists but is not linked to tclsh
    # missing     - Project teapot does not exist

    typemethod state {} {
        if {![file exists [teapot local]]} {
            return "missing"
        }

        if {[teapot local] ne [teacup default]} {
            return "non-default"
        }

        if {![TeapotIsLinked]} {
            return "unlinked"
        }

        return "ok"
    }

    # TeapotIsLinked
    #
    # The teapot is linked if both of the following are true:
    #
    # * The teapot knows that it is linked to the current tclsh
    # * The current tclsh knows that it is linked to the teapot.

    proc TeapotIsLinked {} {
        expr {
            [teapot local]     in [LinkedTeapots] &&
            [plat pathto tclsh]  in [LinkedShells]            
        }
    }

    # LinkedShells
    #
    # Retrieves the shells linked to the local teapot

    proc LinkedShells {} {
        set links [teacup link info [teapot local]]

        foreach {dummy path} $links {
            set newpath [file normalize $path]
            lappend result $newpath
        }

        return $result
    }

    # LinkedTeapots
    #
    # Retrieves the teapots linked to the current tclsh.

    proc LinkedTeapots {} {
        set links [teacup link info [plat pathto tclsh]]

        foreach {dummy path} $links {
            set newpath [file normalize $path]
            lappend result $newpath
        }

        return $result
    }

}

# TBD: Fix the queries!

codeblock teapot::FixTeapotBat {} {
    set teacup    [plat pathto teacup -required]
    set kitepath  [teapot local]
    set tclsh     [plat pathto tclsh -required]
} {
    %teacup default %kitepath
    %teacup link make %kitepath %tclsh
}


codeblock teapot::FixTeapotBash {} {
    set teacup     [plat pathto teacup -required]
    set kitepath   [teapot local]
    set tclsh      [plat pathto tclsh -required]
    set indexcache [plat pathof indexcache -required]
    set user       [os username]
} {
    %teacup default %kitepath
    %teacup link make %kitepath %tclsh
    chown -R %user %indexcache
    chown -R %user %kitepath
}