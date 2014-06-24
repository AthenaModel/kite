#-----------------------------------------------------------------------
# TITLE:
#   newtool.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "new" tool.  This tool knows how to build project trees.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Registration

set ::ktools(new) {
    arglist     {template project ?arg?}
    package     ktools
    ensemble    ::ktools::newtool
    description "Create a new project tree on the disk."
    intree      no
}

#-----------------------------------------------------------------------
# newtool ensemble

snit::type ::ktools::newtool {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        checkargs new 2 3 {template project ?arg?} $argv

        lassign $argv template project targ

        # TODO: Validate project
        
        if {$template ni [trees types]} {
            set samples "should be one of: [join [trees types] {, }]"
            throw FATAL "No such project template: \"$template\"; $samples"
        }

        set dirname [pwd]
        set projdir [file join $dirname $project]

        if {[file exists $projdir]} {
            throw FATAL \
                "A file called \"$project\" already exists in this directory."
        }

        switch -exact -- $template {
            appkit {
                set kitname [expr {$targ ne "" ? $targ : $project}]

                trees appkit $dirname $project $kitname
            }
        }
    }
    

}



