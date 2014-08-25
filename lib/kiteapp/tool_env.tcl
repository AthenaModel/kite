#-----------------------------------------------------------------------
# TITLE:
#   tool_env.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "env" tool.  Describes the development environment as Kite
#   sees it.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::ENV

tool define env {
    usage       {0 0 -}
    description "Describe development environment."
    needstree   no
} {
    The 'kite env' tool describes the development environment from 
    Kite's point of view, including the paths to all helper
    applications.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Describes the development environment.  

    typemethod execute {argv} {
        puts ""
        puts "Kite thinks it is running on [os name]."

        puts ""
        puts "Helpers:"

        table puts [GetPathsTo] -indent "  "

        puts ""
        puts "Directories:"
        table puts [GetPathsOf] -indent "  "
    }

    # GetPathsTo
    #
    # Gets the helper information in a "table".

    proc GetPathsTo {} {
        set table [list]

        # TODO: Provide "names" call?
        foreach t {
            tclsh
            tkcon
            teacup
        } {
            set p [plat pathto $t]

            if {$p eq ""} {
                set p "(NOT FOUND)"
            }

            lappend table [list t $t p $p]
        }

        return $table
    }

    # GetPathsOf
    #
    # Gets the helper information in a "table".

    proc GetPathsOf {} {
        set table [list]

        foreach t {
            tclhome
        } {
            set p [plat pathof $t]

            if {$p eq ""} {
                set p "(NOT FOUND)"
            }

            lappend table [list t $t p $p]
        }

        return $table
    }
}






