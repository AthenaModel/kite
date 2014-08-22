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

        table puts [GetHelpers] -indent "    "
    }

    # GetHelpers
    #
    # Gets the helper information in a "table".

    proc GetHelpers {} {
        set table [list]

        lappend table [list t tclsh  p [plat pathto tclsh]]
        lappend table [list t tkcon  p [plat pathto tkcon]]
        lappend table [list t teacup p [plat pathto teacup]]

        return $table
    }
}






