#-----------------------------------------------------------------------
# TITLE:
#   tool_add.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "add" tool.  This tool knows how add elements to existing
#   project trees.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::ADD

tool define add {
    usage       {2 - "<element> <name> ?<option>...?"}
    description "Add an app or library to the project tree."
    needstree      yes
} {
    The 'kite add' tool is use to add elements to existing Kite projects,
    i.e., to add a new application or library skeleton.  It take sthe
    following arguments:

    <element>   - The element type, "app" or "lib".
    <name>      - The element name.

    For example,

        $ kite add app fred

    will add the following files:

        <root>/bin/fred.tcl
        <root>/lib/fredapp/main.tcl        (plus boilerplate)
        <root>/test/fredapp/all_tests.tcl 

    Similarly,

        $ kite add lib george

    will add the following files:

        <root>/lib/george/george.tcl       (plus boilerplate)
        <root>/test/george/george.test     (plus boilerplate)

    In addition, the new element will be added to the project.kite file.

    The 'kite add app' command takes the same options as in
    'app' statement in project.kite; similarly, the 'kite add lib'
    command takes the same options as the 'provide' statement in
    project.kite.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        set etype [lshift argv]
        set name  [lshift argv]

        if {$etype ni {app lib}} {
            throw FATAL "No such element type: \"$etype\"."
        }


        switch -exact -- $etype {
            app { MakeApp $name $argv }
            lib { MakeLib $name $argv }

            default { 
                throw FATAL "No such element type: \"$etype\"."
            }
        }     

        project metadata save
        project kitefile save
    }
    
    # MakeApp name argv
    #
    # Makes an application template for an app called name.

    proc MakeApp {name argv} {
        # FIRST, add it to the project info.  This will throw an error
        # if the new app name or options are invalid.
        project add app $name {*}$argv 

        # NEXT, add the element.
        puts "Adding new application: $name"
        subtree app $name
    }

    # MakeLib name argv
    #
    # Makes an application template for an app called name.

    proc MakeLib {name argv} {
        # FIRST, add it to the project info.  This will throw an error
        # if the new lib name or options are invalid.
        project add lib $name {*}$argv 

        # NEXT, add the element.
        puts "Adding new library: $name"
        subtree pkg $name $name
    }
}






