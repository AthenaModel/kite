#-----------------------------------------------------------------------
# TITLE:
#   main.tcl
#
# PROJECT:
#   athena-kite: Kite Build Manager for Tcl Projects
#
# PACKAGE:
#   kiteapp(n): Kite Application Package
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite main program, as called by the apploader script, kite.tcl.
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
# Main Program 

# main argv
#
# argv       Command line arguments
#
# This is the main program; it is invoked at the bottom of the file.
# It determines the application to invoke, and does so.

proc main {argv} {
    # FIRST, given no input display the help; help doesn't care whether
    # we're in a project tree or not.
    if {[llength $argv] == 0} {
        tool use help
        return
    }

    # NEXT, get any options
    foroption opt argv {
        -verbose { set ::kiteapp::verbose 1 }
    }

    # NEXT, if it's verbose output the auto_path.
    vputs "auto_path=<$::auto_path>"

    # NEXT, get the subcommand and see if we have a matching tool.
    # Alternatively, we might have a script file to run.
    set tool [lshift argv]
    set treeNeeded 0

    if {[file isfile $tool]} {
        set script [file normalize $tool]
        set tool "RunScript"
        set treeNeeded 1
    } elseif {[tool exists $tool]} {
        set treeNeeded [tool needstree $tool]
    } else {
        throw FATAL [outdent "
            '$tool' is neither the name of a Kite tool, nor the name of a
            TCL script to execute.  See 'kite help' for usage information.
        "]
    }

    # NEXT, find the root of the project tree, if any.
    project root

    # NEXT, check whether the tool in question requires a project tree
    # or not.  If it does, load the project metadata from project.kite.

    if {$treeNeeded} {
        if {![project intree]} {
            throw FATAL \
                "Could not find project.kite in this directory or its parents"
        }

        try {
            project load
        } trap SYNTAX {result} {
            throw FATAL "Could not load project file:\n--> $result"
        }
    }

    # NEXT, If we have a project tree, the project metadata might have
    # changed.  There are number of places in the project's code that
    # are automatically updated when metadata changes, notably the 
    # kiteinfo(n) package and version numbers of pkgIndex and pkgModules
    # files.  Save any changed data back into the project tree.
    #
    # NOTE: Care is taken that project file content changes only if 
    # metadata has actually changed.  This, we are guaranteed that the
    # code is always consistent with the metadata without generating a
    # stream of trivial changes into the VCS repository.

    if {[project hasinfo]} {
        metadata apply
    }

    # NEXT, either run the user's script or use the selected tool,
    # passing along the remaining arguments.
    if {$tool eq "RunScript"} {
        tclsh show $script {*}$argv >@ stdout 2>@ stderr
    } else {
        tool use $tool $argv
    }
}
