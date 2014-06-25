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

set ::khelp(new) {
    The "new" tool is use to initialize new projects on the disk.  It
    takes the following arguments:

    template   - The project template, one of: appkit
    project    - The project name, e.g., "my-project"
    arg...     - Optional arguments, by template type.

    For example,

        $ cd ~/github
        $ kite new appkit my-project

    creates a complete project skeleton in 

        ~/github/my-project

    Use "kite help" to find out more about the available templates.
}

set ::khelp(appkit) {
    The "appkit" project template is for pure-tcl applications that
    will be deployed as "starkit" files.  Appkits run against the 
    installed version of Tcl, and so are primarily useful for 
    developer tools.

    The template takes one optional argument, the root name of the 
    ".kit" file; this name defaults to the project name.  For example,

        $ kite new appkit my-project

    produces the appkit "<root>/bin/my-project.kit".  However,

        $ kite new appkit my-project mytool

    products the appkit "<root>/bin/mytool.kit".

    A project can define any number of appkits via the "appkit" statement
    in the project.kite file.  Each one of them requires a "main" script
    in <root>/bin/<kitname>.tcl.  For example, "mytool.kit" executes 
    the file "<root>/bin/mytool.tcl".

    This template also creates a Tcl package, core(n), in 
    "<root>/lib/core".  The usual practice is to put most of the
    appkit's code in core(n) (or other Tcl packages) and have 
    "<root>/bin/<kitname>.tcl" simply invoke it.
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
        checkargs new 0 3 {template project ?arg?} $argv

        lassign $argv template project targ

        if {$template eq ""} {
            puts "The following project templates may be used:"
            puts ""

            foreach name [trees types] {
                puts [format "%-10s - %s" $name [trees description $name]]
            }

            puts ""
            puts "Enter \"kite help <template>\" for more information."
            puts ""
            return
        }

        if {$template ni [trees types]} {
            set samples "should be one of: [join [trees types] {, }]"
            throw FATAL "No such project template: \"$template\"; $samples"
        }

        # TODO: Validate project completely
        if {$project eq ""} {
            throw FATAL "No project name was given."
        }
        
        set dirname [pwd]
        set projdir [file join $dirname $project]

        if {[file exists $projdir]} {
            throw FATAL \
                "A file called \"$project\" already exists in this directory."
        }

        # The existing templates all take the first three arguments
        # with an optional fourth argument.
        trees $template $dirname $project $targ
    }
    

}



