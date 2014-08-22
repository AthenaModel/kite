#-----------------------------------------------------------------------
# TITLE:
#   tool_new.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "new" tool.  This tool knows how to build project trees.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::NEW

tool define new {
    usage       {0 3 "<template> <project> ?<arg>...?"}
    description "Create a new project tree on the disk."
    intree      no
} {
    The 'kite new' tool is use to initialize new projects on the disk.  It
    takes the following arguments:

    <template>  - The project template, currently one of app, appkit or lib
    <project>   - The project name, e.g., "my-project"
    <arg>...    - Optional arguments, by template type.

    For example,

        $ cd ~/github
        $ kite new app my-project fred

    creates a complete project skeleton in "~/github/my-project".  The new
    project defines a skeleton application called "fred".

    Use 'kite help' to find out more about the available templates,
    e.g., 

        $ kite help app

    To add an application or library to an existing project, use the 
    'kite add' tool.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        lassign $argv template project targ

        if {[project intree]} {
            throw FATAL [outdent "
                The current working directory is part of a Kite project.
                Kite will not create a new project within an existing 
                project tree.
            "]
        }

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






