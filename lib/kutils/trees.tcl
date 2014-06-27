#-----------------------------------------------------------------------
# TITLE:
#   trees.tcl
#
# AUTHOR:
#   Will Duquette
#
# DESCRIPTION:
#   Kite: kutils(n) module for creating project trees.  This module
#   uses template files from kutils/templates and the [generate]
#   command to generate the trees.
#
#   The commands in this file build a project tree given the root
#   directory name.  They assume that the root directory does not
#   exist, and will happily overwrite anything there.  In other words,
#   it is the job of the "kite new" tool to check for problems.
#
#   TODO: Ultimately, we'd want a plugin mechanism for adding new
#   project trees.
#
#-----------------------------------------------------------------------

namespace eval ::kutils:: {
    namespace export trees
}

#-----------------------------------------------------------------------
# trees ensemble

snit::type ::kutils::trees {
    # Make it a singleton
    pragma -hasinstances no -hastypedestroy no

    #-------------------------------------------------------------------
    # Type Variables

    typevariable treetypes {
        appkit ".kit application template"
        lib    "Tcl library package template"
    }


    #-------------------------------------------------------------------
    # Public Queries

    # types
    #
    # Returns the list of tree types.

    typemethod types {} {
        return [dict keys $treetypes]
    }

    # description tree
    #
    # tree  - A tree type
    #
    # Returns the description of the tree type.

    typemethod description {tree} {
        return [dict get $treetypes $tree]
    }


    #-------------------------------------------------------------------
    # Project trees
    

    # appkit dirname projname kitname
    #
    # dirname  - The directory in which to create the new tree.
    # projname - The project name, e.g., "athena-mytool"
    # kitname  - The barename of the appkit to make, e.g., "mytool"
    #
    # Builds a default appkit template rooted at the given directory,
    # assuming that there is nothing there.

    typemethod appkit {dirname projname kitname} {
        if {$kitname eq ""} {
            set kitname $projname
        }
        
        puts "Making an appkit project tree for project \"$projname.\""
        puts "The application will be called \"$kitname.kit\"."

        # FIRST, create the project directory structure
        set root   [file join $dirname $projname]
        file mkdir $root

        set bin    [file join $root bin]
        set lib    [file join $root lib]
        set docs   [file join $root docs]

        # NEXT, create the mapping
        dict set mapping %project $projname
        dict set mapping %kitname $kitname
        dict set mapping %kitfile $kitname.kit
        dict set mapping %package core

        # NEXT, create the files.
        generate appkit_project $mapping $root project.kite
        generate project_readme $mapping $root README.md
        generate gitignore      {}       $root .gitignore
        generate appkit_main    $mapping $bin $kitname.tcl
        generate docs_index     $mapping $docs index.ehtml
        generate pkgIndex       $mapping $lib core pkgIndex.tcl
        generate pkgModules     $mapping $lib core pkgModules.tcl
        generate pkgFile        $mapping $lib core core.tcl


        # TODO: Add test tree!

        puts ""
    }

    # lib dirname projname libname
    #
    # dirname  - The directory in which to create the new tree.
    # projname - The project name, e.g., "athena-mylib"
    # libname  - The barename of the library package, e.g., "mylib"
    #
    # Builds a default library template rooted at the given directory,
    # assuming that there is nothing there.

    typemethod lib {dirname projname libname} {
        if {$libname eq ""} {
            set libname $projname
        }

        puts "Making an appkit project tree for project \"$projname.\""
        puts "The library package will be called ${libname}(n)."

        # FIRST, create the project directory structure
        set root   [file join $dirname $projname]
        file mkdir $root

        set lib    [file join $root lib]
        set docs   [file join $root docs]

        # NEXT, create the mapping
        dict set mapping %project $projname
        dict set mapping %package $libname

        # NEXT, create the files.
        generate lib_project    $mapping $root project.kite
        generate project_readme $mapping $root README.md
        generate gitignore      {}       $root .gitignore
        generate docs_index     $mapping $docs index.ehtml
        generate pkgIndex       $mapping $lib $libname pkgIndex.tcl
        generate pkgModules     $mapping $lib $libname pkgModules.tcl
        generate pkgFile        $mapping $lib $libname $libname.tcl


        # TODO: Add test tree!
        # TODO: man page

        puts ""
    }
}



