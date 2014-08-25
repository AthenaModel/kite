#-----------------------------------------------------------------------
# TITLE:
#   tool_shell.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite "shell" tool.  By default, this invokes tkcon with the project
#   code.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# tool::SHELL

tool define shell {
    usage       {0 1 "?-plain?"}
    description "Open interactive Tcl shell"
    needstree      yes
} {
    The 'kite shell' tool opens an interactive Tcl shell (tkcon) on the 
    project codebase.  If the project defines any applications, the 
    primary application's loader script (e.g., bin/myapp.tcl) is loaded in 
    interactive mode (i.e., the "main" procedure is defined but not called).  

    If there are no applications, or if the "-plain" option is given, 
    Kite simply adds the project library directories to the auto_path.  
    No packages are loaded by default.  In this case, the initial state of 
    the shell can be further customized using the "shell" statement in the 
    project.kite file.
} {
    #-------------------------------------------------------------------
    # Execution 

    # execute argv
    #
    # Executes the tool given the command line arguments.

    typemethod execute {argv} {
        set opt [lindex $argv 0]

        # FIRST, get Tkcon.
        set tkcon [plat pathto tkcon -required]

        # NEXT, call it in the appropriate way.
        cd [project root]


        if {[project hasapp] && $opt ne "-plain"} {
            tclsh show $tkcon [project app loader [project app primary]]
        } else {
            set script [WriteShellInitializer]
            tclsh show $tkcon $script
        }
    }
    
    # WriteShellInitializer
    #
    # Creates .kite/shell.tcl to set up auto_path.

    proc WriteShellInitializer {} {
        # FIRST, add the project's own libraries to the auto_path.
        set out "# shell.tcl -- Kite shell initialization script\n"

        # NEXT, add any "shell" script from project.kite
        append out "\n" [project shell] "\n"

        set script [project root .kite shell.tcl]
        writefile $script $out

        return $script
    }
    
}






