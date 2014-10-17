#-----------------------------------------------------------------------
# TITLE:
#    project_macros.tcl
#
# AUTHOR:
#    Will Duquette
#
# DESCRIPTION:
#    app_kite(n) Package: project_macros(5) macro set
#
#    This module implements a macroset(i) extension for use with
#    macro(n).
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# project_macros ensemble

snit::type project_macros {
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Lookup Tables

    # Standard definitions for [project tclsh] and related calls.

    typevariable tclshHeader {
        proc version {} { return "%version" }
        proc get {x} { return $x }
    }
    

    #-------------------------------------------------------------------
    # Public Methods

    # install macro
    #
    # macro   - The macro(n) instance
    #
    # Installs macros into the the macro(n) instance.

    typemethod install {macro} {
        # Project ensemble
        $macro ensemble project
        $macro smartalias {project name} 0 0 {} \
            [list project name]

        $macro smartalias {project version} 0 0 {} \
            [list project version]

        $macro smartalias {project description} 0 0 {} \
            [list project description]

        $macro smartalias {project tclsh} 1 1 {script} \
            [myproc ProjectTclsh]

        $macro smartalias {project expand} 1 1 {script} \
            [myproc ProjectExpand $macro]

        # fromproject

        $macro proc fromproject {script} {
            variable withProject

            # FIRST, save the user's script for later.
            if {[macro pass] == 1} {
                if {![info exists withProject(counter)]} {
                    set withProject(counter) 0
                    set withProject(scripts) [list]
                }

                set i [incr withProject(counter)]
                lappend withProject(scripts) \
                    [format {set ::withResult(%d) [%s]} $i $script]
                return
            }

            # NEXT, if this is the first call for pass == 2, we need to
            # execute the scripts.
            if {[macro pass] == 2 && [llength $withProject(scripts)] > 0} {
                set withProject(counter) 0
                lappend withProject(scripts) [list array get ::withResult]
                set theScript [join $withProject(scripts) \n]

                set withProject(scripts) [list]

                set gotResult [project tclsh $theScript]
                array set withProject $gotResult
            }

            # NEXT, return the result.
            set i [incr withProject(counter)]
            return $withProject($i)
        }

        # toproject
        
        $macro proc toproject {script} {
            fromproject $script
            return
        }
    }    

    # ProjectTclsh script
    #
    # script - Sends the script to the project tclsh, and returns
    # the result.  Defines the "version" and "get" commands.

    proc ProjectTclsh {script} {
        set map [list %version [project version]]
        set header [string map $map $tclshHeader]
        return [tclsh script "$header\n$script"]
    }

    # ProjectExpand macro script
    #
    # macro  - The macro processor
    # script - A script to send to the project tclsh.
    #
    # Sends the script and returns the expanded result.

    proc ProjectExpand {macro script} {
        return [$macro expandonce [ProjectTclsh $script]]
    }
}

